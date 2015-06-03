/*
 
    File: AQPlayer.mm
Abstract: n/a
 Version: 2.4

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2009 Apple Inc. All Rights Reserved.

 
*/


#include "AQPlayer.h"

void AQPlayer::AQBufferCallback(void *					inUserData,
								AudioQueueRef			inAQ,
								AudioQueueBufferRef		inCompleteAQBuffer) 
{
    if( inUserData == NULL || inAQ == NULL || inCompleteAQBuffer == NULL )
        return;
    
	AQPlayer *THIS = (AQPlayer *)inUserData;

	if (THIS->mIsDone) return;

    UInt32 nBufSize = inCompleteAQBuffer->mAudioDataBytesCapacity / 4;
    UInt32 nNumFrames = nBufSize / THIS->mOutputFormat.mBytesPerFrame;
    
    AudioBufferList fillBufList;
    fillBufList.mNumberBuffers = 1;
    fillBufList.mBuffers[0].mNumberChannels = THIS->mOutputFormat.mChannelsPerFrame;
    fillBufList.mBuffers[0].mDataByteSize = nBufSize;
    fillBufList.mBuffers[0].mData = inCompleteAQBuffer->mAudioData;
    
    CMutex	__mutex(THIS->m_mutex);
    do
    {
        if( THIS->mIsReverse )
        {
            int nSeekOffset = nNumFrames * THIS->mDataFormat.mSampleRate / THIS->mOutputFormat.mSampleRate;
            SInt64 curFrameOffset;
            OSStatus error = ExtAudioFileTell( THIS->mAudioFile, &curFrameOffset );
            if( curFrameOffset > nSeekOffset * 2 )
                curFrameOffset -= nSeekOffset * 2;
            else if( curFrameOffset > nSeekOffset )
                curFrameOffset = 0;
            else
            {
                if (THIS->IsLooping())
                {
                    ExtAudioFileSeek( THIS->mAudioFile, THIS->mTotalFrames - nSeekOffset );
                    THIS->mCurrentPacket = 0;
                    AQBufferCallback(inUserData, inAQ, inCompleteAQBuffer);
                }
                else
                {
                    // stop
                    THIS->mIsDone = true;
                    AudioQueueStop(inAQ, false);
                }
                
                break;
            }

            if( curFrameOffset % THIS->mDataFormat.mFramesPerPacket != 0 )
                curFrameOffset = curFrameOffset / THIS->mDataFormat.mFramesPerPacket * THIS->mDataFormat.mFramesPerPacket;
            error = ExtAudioFileSeek( THIS->mAudioFile, curFrameOffset );
        }
        
        SInt64 nFrameOffset = 0;
        ExtAudioFileTell( THIS->mAudioFile, &nFrameOffset );
        THIS->m_nSeekPercent = (int)(100 * (float)nFrameOffset / (float)THIS->mTotalFrames);
        [[NSNotificationCenter defaultCenter] postNotificationName: @"soundUpdatePosition" object: nil];
        
        if( nFrameOffset >= THIS->mPlayEndFrameIndex )
        {
            THIS->mIsDone = true;
            AudioQueueStop(inAQ, false);
            ExtAudioFileSeek( THIS->mAudioFile, 0 );
            break;
        }
        
        OSStatus result = ExtAudioFileRead( THIS->mAudioFile, &nNumFrames, &fillBufList );
        if (result)
            printf("AudioFileReadPackets failed: %d", (int)result);
        if (nNumFrames > 0) {
            // add by RSI
            SAMPLETYPE* pSamples = new SAMPLETYPE[nNumFrames * 2];
            
            SInt16* pBuffer = (SInt16*)inCompleteAQBuffer->mAudioData;
            
            THIS->m_fPeekValue = 0;
#ifndef SOUNDTOUCH_INTEGER_SAMPLES
            double dScale = 1.0 / 32768.0;
            for( int nIndex = 0; nIndex < nNumFrames * 2; nIndex++ )
            {
                if( THIS->mIsReverse )
                    pSamples[nIndex] = (float)(dScale * pBuffer[nNumFrames * 2 - nIndex]);
                else
                    pSamples[nIndex] = (float)(dScale * pBuffer[nIndex]);
            }
            THIS->m_fPeekValue = pSamples[0];
#else
            for( int nIndex = 0; nIndex < nNumFrames * 2; nIndex++ )
            {
                if( THIS->mIsReverse )
                    pSamples[nIndex] = pBuffer[nNumFrames * 2 - nIndex];
                else
                    pSamples[nIndex] = pBuffer[nIndex];
            }
            THIS->m_fPeekValue = (float)pSamples[0] / 32768.0f;
#endif
            
            [[NSNotificationCenter defaultCenter] postNotificationName: @"soundUpdateGraph" object: nil];
            THIS->m_soundTouch.putSamples( pSamples, nNumFrames );
            
            inCompleteAQBuffer->mAudioDataByteSize = 0;
            
            int nRetSamples = 0;
            do {
                nRetSamples = THIS->m_soundTouch.receiveSamples( pSamples, nNumFrames );
 
#ifndef SOUNDTOUCH_INTEGER_SAMPLES
                for( int nIndex = 0; nIndex < nRetSamples * 2; nIndex++ )
                {
                    int iTemp = (int)( 32768.0f * pSamples[nIndex] );
                    if( iTemp < -32768 ) iTemp = -32768;
                    if( iTemp > 32767 ) iTemp = 32767;
                    
                    *pBuffer++ = (short)iTemp;
                }
#else
                for( int nIndex = 0; nIndex < nRetSamples * 2; nIndex++ )
                {
                    int iTemp = pSamples[nIndex];
                    if( iTemp < -32768 ) iTemp = -32768;
                    if( iTemp > 32767 ) iTemp = 32767;
                    
                    *pBuffer++ = (short)iTemp * THIS->m_nVolume / 100;
                }
#endif
                inCompleteAQBuffer->mAudioDataByteSize += nRetSamples * 2 * sizeof(SInt16);
                
            } while (nRetSamples != 0);
            
            delete[] pSamples;

            inCompleteAQBuffer->mPacketDescriptionCount = inCompleteAQBuffer->mAudioDataByteSize / ( 2 * sizeof(SInt16) );
            AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer, 0, NULL);
            THIS->mCurrentPacket = (THIS->GetCurrentPacket() + nNumFrames);
            if( inCompleteAQBuffer->mAudioDataByteSize > 0 )
                break;
/*          if( THIS->mIsReverse )
            {
                SInt32* pSrc = (SInt32*)inCompleteAQBuffer->mAudioData;
                SInt32* pTemp = new SInt32[nNumFrames];
                for( int nIndex = 0; nIndex < nNumFrames; nIndex++ )
                    pTemp[nIndex] = pSrc[nNumFrames - nIndex];
                memcpy( inCompleteAQBuffer->mAudioData, pTemp, nNumFrames * 2 * sizeof(SInt16) );
            }
            inCompleteAQBuffer->mAudioDataByteSize = nNumFrames * 2 * sizeof(SInt16);
            inCompleteAQBuffer->mPacketDescriptionCount = nNumFrames;
            AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer, 0, NULL);
            THIS->mCurrentPacket = (THIS->GetCurrentPacket() + nNumFrames);
            if( inCompleteAQBuffer->mAudioDataByteSize > 0 )
                break;*/
        } 
        else 
        {
            if (THIS->IsLooping())
            {
                ExtAudioFileSeek( THIS->mAudioFile, 0 );
                THIS->mCurrentPacket = 0;
                AQBufferCallback(inUserData, inAQ, inCompleteAQBuffer);
            }
            else
            {
                // stop
                THIS->mIsDone = true;
                AudioQueueStop(inAQ, false);
                ExtAudioFileSeek( THIS->mAudioFile, 0 );
            }
            
            break;
        }

    } while (TRUE );
}

void AQPlayer::isRunningProc (  void *              inUserData,
								AudioQueueRef           inAQ,
								AudioQueuePropertyID    inID)
{
	AQPlayer *THIS = (AQPlayer *)inUserData;
	UInt32 size = sizeof(THIS->mIsRunning);
	OSStatus result = AudioQueueGetProperty (inAQ, kAudioQueueProperty_IsRunning, &THIS->mIsRunning, &size);
    
	if ((result == noErr) && (!THIS->mIsRunning))
		[[NSNotificationCenter defaultCenter] postNotificationName: @"soundQueueStopped" object: nil];
}

void AQPlayer::CalculateBytesForTime (CAStreamBasicDescription & inDesc, UInt32 inMaxPacketSize, Float64 inSeconds, UInt32 *outBufferSize, UInt32 *outNumPackets)
{
	// we only use time here as a guideline
	// we're really trying to get somewhere between 16K and 64K buffers, but not allocate too much if we don't need it
	static const int maxBufferSize = 0x10000; // limit size to 64K
	static const int minBufferSize = 0x4000; // limit size to 16K
	
	if (inDesc.mFramesPerPacket) {
		Float64 numPacketsForTime = inDesc.mSampleRate / inDesc.mFramesPerPacket * inSeconds;
		*outBufferSize = numPacketsForTime * inMaxPacketSize;
	} else {
		// if frames per packet is zero, then the codec has no predictable packet == time
		// so we can't tailor this (we don't know how many Packets represent a time period
		// we'll just return a default buffer size
		*outBufferSize = maxBufferSize > inMaxPacketSize ? maxBufferSize : inMaxPacketSize;
	}
	
	// we're going to limit our size to our default
	if (*outBufferSize > maxBufferSize && *outBufferSize > inMaxPacketSize)
		*outBufferSize = maxBufferSize;
	else {
		// also make sure we're not too small - we don't want to go the disk for too small chunks
		if (*outBufferSize < minBufferSize)
			*outBufferSize = minBufferSize;
	}
	*outNumPackets = *outBufferSize / inMaxPacketSize;
}

AQPlayer::AQPlayer() :
	mQueue(0),
	mAudioFile(0),
	mFilePath(NULL),
	mIsRunning(false),
	mIsInitialized(false),
    mTotalFrames(0),
	mNumPacketsToRead(0),
	mCurrentPacket(0),
	mIsDone(false),
	mIsLooping(false),
    mIsReverse(false),
    m_nKey(0),
    m_nPitch(0),
    m_nTempo(100),
    m_fPeekValue(0) { }

AQPlayer::~AQPlayer() 
{
	DisposeQueue(true);
}

OSStatus AQPlayer::StartQueue(BOOL inResume, int nSecond, int nDuration)
{	
	// if we have a file but no queue, create one now
	if ((mQueue == NULL) && (mFilePath != NULL))
		CreateQueueForFile(mFilePath);
	
	mIsDone = false;
	
	// if we are not resuming, we also should restart the file read index
	if (!inResume)
	{
        mCurrentPacket = 0;
        if( mIsReverse )
            ExtAudioFileSeek( mAudioFile, mTotalFrames );
        else
        {
            if( nSecond != 0 )
                setSeekSecond( nSecond );
            else
                ExtAudioFileSeek( mAudioFile, 0 );
        }
    }
    
    if( nDuration == 0 )
        mPlayEndFrameIndex = mTotalFrames;
    else
    {
        int nEndSecond = nSecond + nDuration;
        mPlayEndFrameIndex = mDataFormat.mSampleRate * nEndSecond;
    }
    
	// prime the queue with some data before starting
	for (int i = 0; i < kNumberBuffers; ++i) {
		AQBufferCallback (this, mQueue, mBuffers[i]);			
	}
    
	return AudioQueueStart(mQueue, NULL);
}

OSStatus AQPlayer::StopQueue()
{
	OSStatus result = AudioQueueStop(mQueue, true);
	if (result) printf("ERROR STOPPING QUEUE!\n");

	return result;
}

OSStatus AQPlayer::PauseQueue()
{
	OSStatus result = AudioQueuePause(mQueue);

	return result;
}

void AQPlayer::CreateQueueForFile(CFStringRef inFilePath) 
{	
	CFURLRef sndFile = NULL; 

	try {					
		if (mFilePath == NULL)
		{
			mIsLooping = false;
			
			sndFile = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, inFilePath, kCFURLPOSIXPathStyle, false);
			if (!sndFile) { printf("can't parse file path\n"); return; }
			
			XThrowIfError(ExtAudioFileOpenURL (sndFile, &mAudioFile), "can't open file");
		
            AudioConverterRef acRef;
            UInt32 acrsize = sizeof(AudioConverterRef);
            XThrowIfError( ExtAudioFileGetProperty(mAudioFile, kExtAudioFileProperty_AudioConverter, &acrsize, &acRef), "kExtAudioFileProperty_AudioConverter" );
            
            AudioConverterPrimeInfo primeInfo;
            UInt32 piSize = sizeof(AudioConverterPrimeInfo);
            OSStatus err = AudioConverterGetProperty( acRef, kAudioConverterPrimeInfo, &piSize, &primeInfo );
            if(err != kAudioConverterErr_PropertyNotSupported) // Only if decompressing
            {
//                XThrowIfError(err, "kAudioConverterPrimeInfo");
            }
            
//            XThrowIfError(ExtAudioFileSeek( mAudioFile, (SInt64)segmentStart + headerFrames ), "ExtAudioFileSeek");

			UInt32 size = sizeof(mDataFormat);
			XThrowIfError(ExtAudioFileGetProperty(mAudioFile,
                                                  kExtAudioFileProperty_FileDataFormat,
                                                  &size,
                                                  &mDataFormat),
                          "couldn't get file's data format");
            
            size = sizeof(mTotalFrames);
			XThrowIfError(ExtAudioFileGetProperty(mAudioFile,
                                                  kExtAudioFileProperty_FileLengthFrames,
                                                  &size,
                                                  &mTotalFrames),
                          "couldn't get file's length in frames");
            
            mOutputFormat.mSampleRate = 44100.f;
            mOutputFormat.mFormatID = kAudioFormatLinearPCM;
            mOutputFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
            mOutputFormat.mBytesPerPacket = 4;
            mOutputFormat.mFramesPerPacket = 1;
            mOutputFormat.mBytesPerFrame = 4;
            mOutputFormat.mChannelsPerFrame = 2;
            mOutputFormat.mBitsPerChannel = 16;
            
            size = sizeof(mOutputFormat);
            XThrowIfError( ExtAudioFileSetProperty( mAudioFile,
                                            kExtAudioFileProperty_ClientDataFormat,
                                            size,
                                            &mOutputFormat),
                          "ExtAudioFileSetProperty error" );

			mFilePath = CFStringCreateCopy(kCFAllocatorDefault, inFilePath);
		}
        
		SetupNewQueue();
		setupSoundTouch();
	}
	catch (CAXException e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
	}
	if (sndFile)
		CFRelease(sndFile);
    
    m_fPeekValue = 0;
}

void AQPlayer::SetupNewQueue() 
{
	XThrowIfError(AudioQueueNewOutput(&mOutputFormat, 
                                      AQPlayer::AQBufferCallback, 
                                      this, 
                                      CFRunLoopGetCurrent(), //NULL, //
                                      kCFRunLoopCommonModes, 
                                      0, 
                                      &mQueue), 
                  "AudioQueueNew failed");
	
	XThrowIfError(AudioQueueAddPropertyListener(mQueue, kAudioQueueProperty_IsRunning, isRunningProc, this), "adding property listener");
	
	for (int i = 0; i < kNumberBuffers; ++i) {
		XThrowIfError(AudioQueueAllocateBufferWithPacketDescriptions(mQueue, 32768, 0, &mBuffers[i]), "AudioQueueAllocateBuffer failed");
	}	

	// set the volume of the queue
	XThrowIfError (AudioQueueSetParameter(mQueue, kAudioQueueParam_Volume, 1.0), "set queue volume");
	
	mIsInitialized = true;
}

void AQPlayer::DisposeQueue(Boolean inDisposeFile)
{
	if (mQueue)
	{
		XThrowIfError(AudioQueueDispose(mQueue, true), "AudioQueueDispose error");
		mQueue = NULL;
	}
	if (inDisposeFile)
	{
		if (mAudioFile)
		{
			XThrowIfError(ExtAudioFileDispose(mAudioFile), "ExtAudioFileDispose error");
			mAudioFile = 0;
		}
		if (mFilePath)
		{
			CFRelease(mFilePath);
			mFilePath = NULL;
		}
	}
	mIsInitialized = false;
}

// Add by RSI
void AQPlayer::setSeekPos(int nNewSeekPercent)
{
    if( nNewSeekPercent < 0 )
        nNewSeekPercent = 0;
    
    if( nNewSeekPercent > 100 )
        nNewSeekPercent = 100;
    
    CMutex	__mutex(m_mutex);
    SInt64 nNewSeekFramePos = mTotalFrames * (float)nNewSeekPercent / 100.f;
    ExtAudioFileSeek( mAudioFile, nNewSeekFramePos );
}

void AQPlayer::setSeekSecond(int nSeekSecond)
{
    if( nSeekSecond < 0 )
        nSeekSecond = 0;
    
    if( nSeekSecond > getDuration() )
        nSeekSecond = getDuration();
    
    CMutex	__mutex(m_mutex);
    SInt64 nNewSeekFramePos = nSeekSecond * mDataFormat.mSampleRate;
    ExtAudioFileSeek( mAudioFile, nNewSeekFramePos );
}

int AQPlayer::getSeekSecond()
{
    if( mAudioFile == nil )
        return 0;
    CMutex	__mutex(m_mutex);
    SInt64 nCurSeekFramePos;
    ExtAudioFileTell( mAudioFile, &nCurSeekFramePos );
    
    return nCurSeekFramePos / mDataFormat.mSampleRate;
}

void AQPlayer::setKey(int nNewKey)
{
    // Check value
    if( nNewKey < -12 || nNewKey > 12 )
        return;
    
//    PauseQueue();
    CMutex	__mutex(m_mutex);
    m_nKey = nNewKey;
    float dNewPitch = m_nKey + ((float)m_nPitch) / 100.f;
    m_soundTouch.setPitchSemiTones( (float)dNewPitch );
//    StartQueue( TRUE );
}

void AQPlayer::setPitch(int nNewPitch)
{
    // Check value
    if( nNewPitch < -100 || nNewPitch > 100 )
        return;
    
//    PauseQueue();
    CMutex	__mutex(m_mutex);
    m_nPitch = nNewPitch;
    float dNewPitch = m_nKey + ((float)m_nPitch) / 100.f;
    m_soundTouch.setPitchSemiTones( (float)dNewPitch );
//    StartQueue( TRUE );
}

void AQPlayer::setTempo(int nNewTempo)
{
    // Check value
    if( nNewTempo < 50 || nNewTempo > 200 )
        return;
    
//    PauseQueue();
    CMutex	__mutex(m_mutex);
    m_nTempo = nNewTempo;
    m_soundTouch.setTempo( ((float)m_nTempo) / 100.0f );
//    StartQueue( TRUE );
}

void AQPlayer::setupSoundTouch()
{
    m_soundTouch.setSampleRate( mOutputFormat.mSampleRate );
    m_soundTouch.setChannels( mOutputFormat.mChannelsPerFrame );

    m_nKey = 0;
    m_nPitch = 0;
    m_nTempo = 100;

    m_soundTouch.setTempo( 1.0f );
    m_soundTouch.setPitch( 1.0f );
    m_soundTouch.setRate( 1.0f );
    
    m_soundTouch.setSetting( SETTING_USE_QUICKSEEK, 1 );
    m_soundTouch.setSetting( SETTING_USE_AA_FILTER, 1 );
}

int AQPlayer::getDuration()
{
    if( mAudioFile == nil )
        return 0;
    
    if( mDataFormat.mSampleRate == 0 )
        return 0;
    
    return mTotalFrames / mDataFormat.mSampleRate;
}