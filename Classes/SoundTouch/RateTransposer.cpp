////////////////////////////////////////////////////////////////////////////////
/// 
/// Sample rate transposer. Changes sample rate by using linear interpolation 
/// together with anti-alias filtering (first order interpolation with anti-
/// alias filtering should be quite adequate for this application)
///
/// Author        : Copyright (c) Olli Parviainen
/// Author e-mail : oparviai 'at' iki.fi
/// SoundTouch WWW: http://www.surina.net/soundtouch
///
////////////////////////////////////////////////////////////////////////////////
//
// Last changed  : $Date$
// File revision : $Revision: 4 $
//
// $Id$
//
////////////////////////////////////////////////////////////////////////////////
//
// License :
//
//  SoundTouch audio processing library
//  Copyright (c) Olli Parviainen
//
//  This library is free software; you can redistribute it and/or
//  modify it under the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either
//  version 2.1 of the License, or (at your option) any later version.
//
//  This library is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public
//  License along with this library; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
////////////////////////////////////////////////////////////////////////////////

#include <memory.h>
#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdexcept>
#include "RateTransposer.h"
#include "AAFilter.h"

using namespace std;
using namespace soundtouch;


/// A linear samplerate transposer class that uses integer arithmetics.
/// for the transposing.
class RateTransposerInteger : public RateTransposer
{
protected:
    int iSlopeCount;
    int iRate;
    SAMPLETYPE sPrevSampleL, sPrevSampleR;

    virtual void resetRegisters();

    virtual uint transposeStereo(SAMPLETYPE *dest, 
                         const SAMPLETYPE *src, 
                         uint numSamples);
    virtual uint transposeMono(SAMPLETYPE *dest, 
                       const SAMPLETYPE *src, 
                       uint numSamples);

public:
    RateTransposerInteger();
    virtual ~RateTransposerInteger();

    /// Sets new target rate. Normal rate = 1.0, smaller values represent slower 
    /// rate, larger faster rates.
    virtual void setRate(float newRate);

};


/// A linear samplerate transposer class that uses floating point arithmetics
/// for the transposing.
class RateTransposerFloat : public RateTransposer
{
protected:
    float fSlopeCount;
    SAMPLETYPE sPrevSampleL, sPrevSampleR;

    virtual void resetRegisters();

    virtual uint transposeStereo(SAMPLETYPE *dest, 
                         const SAMPLETYPE *src, 
                         uint numSamples);
    virtual uint transposeMono(SAMPLETYPE *dest, 
                       const SAMPLETYPE *src, 
                       uint numSamples);

public:
    RateTransposerFloat();
    virtual ~RateTransposerFloat();
};




// Operator 'new' is overloaded so that it automatically creates a suitable instance 
// depending on if we've a MMX/SSE/etc-capable CPU available or not.
void * RateTransposer::operator new(size_t s)
{
    throw runtime_error("Error in RateTransoser::new: don't use \"new TDStretch\" directly, use \"newInstance\" to create a new instance instead!");
    return NULL;
}


RateTransposer *RateTransposer::newInstance()
{
#ifdef SOUNDTOUCH_INTEGER_SAMPLES
    return ::new RateTransposerInteger;
#else
    return ::new RateTransposerFloat;
#endif
}


// Constructor
RateTransposer::RateTransposer() : FIFOProcessor(&outputBuffer)
{
    numChannels = 2;
    bUseAAFilter = TRUE;
    fRate = 0;

    // Instantiates the anti-alias filter with default tap length
    // of 32
    pAAFilter = new AAFilter(32);
}



RateTransposer::~RateTransposer()
{
    delete pAAFilter;
}



/// Enables/disables the anti-alias filter. Zero to disable, nonzero to enable
void RateTransposer::enableAAFilter(BOOL newMode)
{
    bUseAAFilter = newMode;
}


/// Returns nonzero if anti-alias filter is enabled.
BOOL RateTransposer::isAAFilterEnabled() const
{
    return bUseAAFilter;
}


AAFilter *RateTransposer::getAAFilter()
{
    return pAAFilter;
}



// Sets new target iRate. Normal iRate = 1.0, smaller values represent slower 
// iRate, larger faster iRates.
void RateTransposer::setRate(float newRate)
{
    double fCutoff;

    fRate = newRate;

    // design a new anti-alias filter
    if (newRate > 1.0f) 
    {
        fCutoff = 0.5f / newRate;
    } 
    else 
    {
        fCutoff = 0.5f * newRate;
    }
    pAAFilter->setCutoffFreq(fCutoff);
}


// Outputs as many samples of the 'outputBuffer' as possible, and if there's
// any room left, outputs also as many of the incoming samples as possible.
// The goal is to drive the outputBuffer empty.
//
// It's allowed for 'output' and 'input' parameters to point to the same
// memory position.
/*
void RateTransposer::flushStoreBuffer()
{
    if (storeBuffer.isEmpty()) return;

    outputBuffer.moveSamples(storeBuffer);
}
*/


// Adds 'nSamples' pcs of samples from the 'samples' memory position into
// the input of the object.
void RateTransposer::putSamples(const SAMPLETYPE *samples, uint nSamples)
{
    processSamples(samples, nSamples);
}



// Transposes up the sample rate, causing the observed playback 'rate' of the
// sound to decrease
void RateTransposer::upsample(const SAMPLETYPE *src, uint nSamples)
{
    uint count, sizeTemp, num;

    // If the parameter 'uRate' value is smaller than 'SCALE', first transpose
    // the samples and then apply the anti-alias filter to remove aliasing.

    // First check that there's enough room in 'storeBuffer' 
    // (+16 is to reserve some slack in the destination buffer)
    sizeTemp = (uint)((float)nSamples / fRate + 16.0f);

    // Transpose the samples, store the result into the end of "storeBuffer"
    count = transpose(storeBuffer.ptrEnd(sizeTemp), src, nSamples);
    storeBuffer.putSamples(count);

    // Apply the anti-alias filter to samples in "store output", output the
    // result to "dest"
    num = storeBuffer.numSamples();
    count = pAAFilter->evaluate(outputBuffer.ptrEnd(num), 
        storeBuffer.ptrBegin(), num, (uint)numChannels);
    outputBuffer.putSamples(count);

    // Remove the processed samples from "storeBuffer"
    storeBuffer.receiveSamples(count);
}


// Transposes down the sample rate, causing the observed playback 'rate' of the
// sound to increase
void RateTransposer::downsample(const SAMPLETYPE *src, uint nSamples)
{
    uint count, sizeTemp;

    // If the parameter 'uRate' value is larger than 'SCALE', first apply the
    // anti-alias filter to remove high frequencies (prevent them from folding
    // over the lover frequencies), then transpose.

    // Add the new samples to the end of the storeBuffer
    storeBuffer.putSamples(src, nSamples);

    // Anti-alias filter the samples to prevent folding and output the filtered 
    // data to tempBuffer. Note : because of the FIR filter length, the
    // filtering routine takes in 'filter_length' more samples than it outputs.
    assert(tempBuffer.isEmpty());
    sizeTemp = storeBuffer.numSamples();

    count = pAAFilter->evaluate(tempBuffer.ptrEnd(sizeTemp), 
        storeBuffer.ptrBegin(), sizeTemp, (uint)numChannels);

	if (count == 0) return;

    // Remove the filtered samples from 'storeBuffer'
    storeBuffer.receiveSamples(count);

    // Transpose the samples (+16 is to reserve some slack in the destination buffer)
    sizeTemp = (uint)((float)nSamples / fRate + 16.0f);
    count = transpose(outputBuffer.ptrEnd(sizeTemp), tempBuffer.ptrBegin(), count);
    outputBuffer.putSamples(count);
}


// Transposes sample rate by applying anti-alias filter to prevent folding. 
// Returns amount of samples returned in the "dest" buffer.
// The maximum amount of samples that can be returned at a time is set by
// the 'set_returnBuffer_size' function.
void RateTransposer::processSamples(const SAMPLETYPE *src, uint nSamples)
{
    uint count;
    uint sizeReq;

    if (nSamples == 0) return;
    assert(pAAFilter);

    // If anti-alias filter is turned off, simply transpose without applying
    // the filter
    if (bUseAAFilter == FALSE) 
    {
        sizeReq = (uint)((float)nSamples / fRate + 1.0f);
        count = transpose(outputBuffer.ptrEnd(sizeReq), src, nSamples);
        outputBuffer.putSamples(count);
        return;
    }

    // Transpose with anti-alias filter
    if (fRate < 1.0f) 
    {
        upsample(src, nSamples);
    } 
    else  
    {
        downsample(src, nSamples);
    }
}


// Transposes the sample rate of the given samples using linear interpolation. 
// Returns the number of samples returned in the "dest" buffer
inline uint RateTransposer::transpose(SAMPLETYPE *dest, const SAMPLETYPE *src, uint nSamples)
{
    if (numChannels == 2) 
    {
        return transposeStereo(dest, src, nSamples);
    } 
    else 
    {
        return transposeMono(dest, src, nSamples);
    }
}


// Sets the number of channels, 1 = mono, 2 = stereo
void RateTransposer::setChannels(int nChannels)
{
    assert(nChannels > 0);
    if (numChannels == nChannels) return;

    assert(nChannels == 1 || nChannels == 2);
    numChannels = nChannels;

    storeBuffer.setChannels(numChannels);
    tempBuffer.setChannels(numChannels);
    outputBuffer.setChannels(numChannels);

    // Inits the linear interpolation registers
    resetRegisters();
}


// Clears all the samples in the object
void RateTransposer::clear()
{
    outputBuffer.clear();
    storeBuffer.clear();
}


// Returns nonzero if there aren't any samples available for outputting.
int RateTransposer::isEmpty() const
{
    int res;

    res = FIFOProcessor::isEmpty();
    if (res == 0) return 0;
    return storeBuffer.isEmpty();
}


//////////////////////////////////////////////////////////////////////////////
//
// RateTransposerInteger - integer arithmetic implementation
// 

/// fixed-point interpolation routine precision
#define SCALE    65536

// Constructor
RateTransposerInteger::RateTransposerInteger() : RateTransposer()
{
    // Notice: use local function calling syntax for sake of clarity, 
    // to indicate the fact that C++ constructor can't call virtual functions.
    RateTransposerInteger::resetRegisters();
    RateTransposerInteger::setRate(1.0f);
}


RateTransposerInteger::~RateTransposerInteger()
{
}


void RateTransposerInteger::resetRegisters()
{
    iSlopeCount = 0;
    sPrevSampleL = 
    sPrevSampleR = 0;
}



// Transposes the sample rate of the given samples using linear interpolation. 
// 'Mono' version of the routine. Returns the number of samples returned in 
// the "dest" buffer
uint RateTransposerInteger::transposeMono(SAMPLETYPE *dest, const SAMPLETYPE *src, uint nSamples)
{
    unsigned int i, used;
    LONG_SAMPLETYPE temp, vol1;

    if (nSamples == 0) return 0;  // no samples, no work

	used = 0;    
    i = 0;

    // Process the last sample saved from the previous call first...
    while (iSlopeCount <= SCALE) 
    {
        vol1 = (LONG_SAMPLETYPE)(SCALE - iSlopeCount);
        temp = vol1 * sPrevSampleL + iSlopeCount * src[0];
        dest[i] = (SAMPLETYPE)(temp / SCALE);
        i++;
        iSlopeCount += iRate;
    }
    // now always (iSlopeCount > SCALE)
    iSlopeCount -= SCALE;

    while (1)
    {
        while (iSlopeCount > SCALE) 
        {
            iSlopeCount -= SCALE;
            used ++;
            if (used >= nSamples - 1) goto end;
        }
        vol1 = (LONG_SAMPLETYPE)(SCALE - iSlopeCount);
        temp = src[used] * vol1 + iSlopeCount * src[used + 1];
        dest[i] = (SAMPLETYPE)(temp / SCALE);

        i++;
        iSlopeCount += iRate;
    }
end:
    // Store the last sample for the next round
    sPrevSampleL = src[nSamples - 1];

    return i;
}


// Transposes the sample rate of the given samples using linear interpolation. 
// 'Stereo' version of the routine. Returns the number of samples returned in 
// the "dest" buffer
uint RateTransposerInteger::transposeStereo(SAMPLETYPE *dest, const SAMPLETYPE *src, uint nSamples)
{
    unsigned int srcPos, i, used;
    LONG_SAMPLETYPE temp, vol1;

    if (nSamples == 0) return 0;  // no samples, no work

    used = 0;    
    i = 0;

    // Process the last sample saved from the sPrevSampleLious call first...
    while (iSlopeCount <= SCALE) 
    {
        vol1 = (LONG_SAMPLETYPE)(SCALE - iSlopeCount);
        temp = vol1 * sPrevSampleL + iSlopeCount * src[0];
        dest[2 * i] = (SAMPLETYPE)(temp / SCALE);
        temp = vol1 * sPrevSampleR + iSlopeCount * src[1];
        dest[2 * i + 1] = (SAMPLETYPE)(temp / SCALE);
        i++;
        iSlopeCount += iRate;
    }
    // now always (iSlopeCount > SCALE)
    iSlopeCount -= SCALE;

    while (1)
    {
        while (iSlopeCount > SCALE) 
        {
            iSlopeCount -= SCALE;
            used ++;
            if (used >= nSamples - 1) goto end;
        }
        srcPos = 2 * used;
        vol1 = (LONG_SAMPLETYPE)(SCALE - iSlopeCount);
        temp = src[srcPos] * vol1 + iSlopeCount * src[srcPos + 2];
        dest[2 * i] = (SAMPLETYPE)(temp / SCALE);
        temp = src[srcPos + 1] * vol1 + iSlopeCount * src[srcPos + 3];
        dest[2 * i + 1] = (SAMPLETYPE)(temp / SCALE);

        i++;
        iSlopeCount += iRate;
    }
end:
    // Store the last sample for the next round
    sPrevSampleL = src[2 * nSamples - 2];
    sPrevSampleR = src[2 * nSamples - 1];

    return i;
}


// Sets new target iRate. Normal iRate = 1.0, smaller values represent slower 
// iRate, larger faster iRates.
void RateTransposerInteger::setRate(float newRate)
{
    iRate = (int)(newRate * SCALE + 0.5f);
    RateTransposer::setRate(newRate);
}


//////////////////////////////////////////////////////////////////////////////
//
// RateTransposerFloat - floating point arithmetic implementation
// 
//////////////////////////////////////////////////////////////////////////////

// Constructor
RateTransposerFloat::RateTransposerFloat() : RateTransposer()
{
    // Notice: use local function calling syntax for sake of clarity, 
    // to indicate the fact that C++ constructor can't call virtual functions.
    RateTransposerFloat::resetRegisters();
    RateTransposerFloat::setRate(1.0f);
}


RateTransposerFloat::~RateTransposerFloat()
{
}


void RateTransposerFloat::resetRegisters()
{
    fSlopeCount = 0;
    sPrevSampleL = 
    sPrevSampleR = 0;
}



// Transposes the sample rate of the given samples using linear interpolation. 
// 'Mono' version of the routine. Returns the number of samples returned in 
// the "dest" buffer
uint RateTransposerFloat::transposeMono(SAMPLETYPE *dest, const SAMPLETYPE *src, uint nSamples)
{
    unsigned int i, used;

    used = 0;    
    i = 0;

    // Process the last sample saved from the previous call first...
    while (fSlopeCount <= 1.0f) 
    {
        dest[i] = (SAMPLETYPE)((1.0f - fSlopeCount) * sPrevSampleL + fSlopeCount * src[0]);
        i++;
        fSlopeCount += fRate;
    }
    fSlopeCount -= 1.0f;

    if (nSamples > 1)
    {
        while (1)
        {
            while (fSlopeCount > 1.0f) 
            {
                fSlopeCount -= 1.0f;
                used ++;
                if (used >= nSamples - 1) goto end;
            }
            dest[i] = (SAMPLETYPE)((1.0f - fSlopeCount) * src[used] + fSlopeCount * src[used + 1]);
            i++;
            fSlopeCount += fRate;
        }
    }
end:
    // Store the last sample for the next round
    sPrevSampleL = src[nSamples - 1];

    return i;
}


// Transposes the sample rate of the given samples using linear interpolation. 
// 'Mono' version of the routine. Returns the number of samples returned in 
// the "dest" buffer
uint RateTransposerFloat::transposeStereo(SAMPLETYPE *dest, const SAMPLETYPE *src, uint nSamples)
{
    unsigned int srcPos, i, used;

    if (nSamples == 0) return 0;  // no samples, no work

    used = 0;    
    i = 0;

    // Process the last sample saved from the sPrevSampleLious call first...
    while (fSlopeCount <= 1.0f) 
    {
        dest[2 * i] = (SAMPLETYPE)((1.0f - fSlopeCount) * sPrevSampleL + fSlopeCount * src[0]);
        dest[2 * i + 1] = (SAMPLETYPE)((1.0f - fSlopeCount) * sPrevSampleR + fSlopeCount * src[1]);
        i++;
        fSlopeCount += fRate;
    }
    // now always (iSlopeCount > 1.0f)
    fSlopeCount -= 1.0f;

    if (nSamples > 1)
    {
        while (1)
        {
            while (fSlopeCount > 1.0f) 
            {
                fSlopeCount -= 1.0f;
                used ++;
                if (used >= nSamples - 1) goto end;
            }
            srcPos = 2 * used;

            dest[2 * i] = (SAMPLETYPE)((1.0f - fSlopeCount) * src[srcPos] 
                + fSlopeCount * src[srcPos + 2]);
            dest[2 * i + 1] = (SAMPLETYPE)((1.0f - fSlopeCount) * src[srcPos + 1] 
                + fSlopeCount * src[srcPos + 3]);

            i++;
            fSlopeCount += fRate;
        }
    }
end:
    // Store the last sample for the next round
    sPrevSampleL = src[2 * nSamples - 2];
    sPrevSampleR = src[2 * nSamples - 1];

    return i;
}

#if 0

long TDStretchMMX::calcCrossCorrStereo(const short *pV1, const short *pV2) const
{
    const __m64 *pVec1, *pVec2;
    __m64 shifter;
    __m64 accu, normaccu;
    long corr, norm;
    int i;
    
    pVec1 = (__m64*)pV1;
    pVec2 = (__m64*)pV2;
    
    shifter = _m_from_int(overlapDividerBits);
    normaccu = accu = _mm_setzero_si64();
    
    // Process 4 parallel sets of 2 * stereo samples each during each
    // round to improve CPU-level parallellization.
    for (i = 0; i < overlapLength / 8; i ++)
    {
        __m64 temp, temp2;
        
        // dictionary of instructions:
        // _m_pmaddwd   : 4*16bit multiply-add, resulting two 32bits = [a0*b0+a1*b1 ; a2*b2+a3*b3]
        // _mm_add_pi32 : 2*32bit add
        // _m_psrad     : 32bit right-shift
        
        temp = _mm_add_pi32(_mm_madd_pi16(pVec1[0], pVec2[0]),
                            _mm_madd_pi16(pVec1[1], pVec2[1]));
        temp2 = _mm_add_pi32(_mm_madd_pi16(pVec1[0], pVec1[0]),
                             _mm_madd_pi16(pVec1[1], pVec1[1]));
        accu = _mm_add_pi32(accu, _mm_sra_pi32(temp, shifter));
        normaccu = _mm_add_pi32(normaccu, _mm_sra_pi32(temp2, shifter));
        
        temp = _mm_add_pi32(_mm_madd_pi16(pVec1[2], pVec2[2]),
                            _mm_madd_pi16(pVec1[3], pVec2[3]));
        temp2 = _mm_add_pi32(_mm_madd_pi16(pVec1[2], pVec1[2]),
                             _mm_madd_pi16(pVec1[3], pVec1[3]));
        accu = _mm_add_pi32(accu, _mm_sra_pi32(temp, shifter));
        normaccu = _mm_add_pi32(normaccu, _mm_sra_pi32(temp2, shifter));
        
        pVec1 += 4;
        pVec2 += 4;
    }
    
    // copy hi-dword of mm0 to lo-dword of mm1, then sum mmo+mm1
    // and finally store the result into the variable "corr"
    
    accu = _mm_add_pi32(accu, _mm_srli_si64(accu, 32));
    corr = _m_to_int(accu);
    
    normaccu = _mm_add_pi32(normaccu, _mm_srli_si64(normaccu, 32));
    norm = _m_to_int(normaccu);
    
    // Clear MMS state
    _m_empty();
    
    // Normalize result by dividing by sqrt(norm) - this step is easiest
    // done using floating point operation
    if (norm == 0) norm = 1;    // to avoid div by zero
    return (long)((double)corr * USHRT_MAX / sqrt((double)norm));
    // Note: Warning about the missing EMMS instruction is harmless
    // as it'll be called elsewhere.
}



void TDStretchMMX::clearCrossCorrState()
{
    // Clear MMS state
    _m_empty();
    //_asm EMMS;
}



// MMX-optimized version of the function overlapStereo
void TDStretchMMX::overlapStereo(short *output, const short *input) const
{
    const __m64 *pVinput, *pVMidBuf;
    __m64 *pVdest;
    __m64 mix1, mix2, adder, shifter;
    int i;
    
    pVinput  = (const __m64*)input;
    pVMidBuf = (const __m64*)pMidBuffer;
    pVdest   = (__m64*)output;
    
    // mix1  = mixer values for 1st stereo sample
    // mix1  = mixer values for 2nd stereo sample
    // adder = adder for updating mixer values after each round
    
    mix1  = _mm_set_pi16(0, overlapLength,   0, overlapLength);
    adder = _mm_set_pi16(1, -1, 1, -1);
    mix2  = _mm_add_pi16(mix1, adder);
    adder = _mm_add_pi16(adder, adder);
    
    // Overlaplength-division by shifter. "+1" is to account for "-1" deduced in
    // overlapDividerBits calculation earlier.
    shifter = _m_from_int(overlapDividerBits + 1);
    
    for (i = 0; i < overlapLength / 4; i ++)
    {
        __m64 temp1, temp2;
        
        // load & shuffle data so that input & mixbuffer data samples are paired
        temp1 = _mm_unpacklo_pi16(pVMidBuf[0], pVinput[0]);     // = i0l m0l i0r m0r
        temp2 = _mm_unpackhi_pi16(pVMidBuf[0], pVinput[0]);     // = i1l m1l i1r m1r
        
        // temp = (temp .* mix) >> shifter
        temp1 = _mm_sra_pi32(_mm_madd_pi16(temp1, mix1), shifter);
        temp2 = _mm_sra_pi32(_mm_madd_pi16(temp2, mix2), shifter);
        pVdest[0] = _mm_packs_pi32(temp1, temp2); // pack 2*2*32bit => 4*16bit
        
        // update mix += adder
        mix1 = _mm_add_pi16(mix1, adder);
        mix2 = _mm_add_pi16(mix2, adder);
        
        // --- second round begins here ---
        
        // load & shuffle data so that input & mixbuffer data samples are paired
        temp1 = _mm_unpacklo_pi16(pVMidBuf[1], pVinput[1]);       // = i2l m2l i2r m2r
        temp2 = _mm_unpackhi_pi16(pVMidBuf[1], pVinput[1]);       // = i3l m3l i3r m3r
        
        // temp = (temp .* mix) >> shifter
        temp1 = _mm_sra_pi32(_mm_madd_pi16(temp1, mix1), shifter);
        temp2 = _mm_sra_pi32(_mm_madd_pi16(temp2, mix2), shifter);
        pVdest[1] = _mm_packs_pi32(temp1, temp2); // pack 2*2*32bit => 4*16bit
        
        // update mix += adder
        mix1 = _mm_add_pi16(mix1, adder);
        mix2 = _mm_add_pi16(mix2, adder);
        
        pVinput  += 2;
        pVMidBuf += 2;
        pVdest   += 2;
    }
    
    _m_empty(); // clear MMS state
}


//////////////////////////////////////////////////////////////////////////////
//
// implementation of MMX optimized functions of class 'FIRFilter'
//
//////////////////////////////////////////////////////////////////////////////

#include "FIRFilter.h"


FIRFilterMMX::FIRFilterMMX() : FIRFilter()
{
    filterCoeffsUnalign = NULL;
}


FIRFilterMMX::~FIRFilterMMX()
{
    delete[] filterCoeffsUnalign;
}


// (overloaded) Calculates filter coefficients for MMX routine
void FIRFilterMMX::setCoefficients(const short *coeffs, uint newLength, uint uResultDivFactor)
{
    uint i;
    FIRFilter::setCoefficients(coeffs, newLength, uResultDivFactor);
    
    // Ensure that filter coeffs array is aligned to 16-byte boundary
    delete[] filterCoeffsUnalign;
    filterCoeffsUnalign = new short[2 * newLength + 8];
    filterCoeffsAlign = (short *)(((ulong)filterCoeffsUnalign + 15) & -16);
    
    // rearrange the filter coefficients for mmx routines
    for (i = 0;i < length; i += 4)
    {
        filterCoeffsAlign[2 * i + 0] = coeffs[i + 0];
        filterCoeffsAlign[2 * i + 1] = coeffs[i + 2];
        filterCoeffsAlign[2 * i + 2] = coeffs[i + 0];
        filterCoeffsAlign[2 * i + 3] = coeffs[i + 2];
        
        filterCoeffsAlign[2 * i + 4] = coeffs[i + 1];
        filterCoeffsAlign[2 * i + 5] = coeffs[i + 3];
        filterCoeffsAlign[2 * i + 6] = coeffs[i + 1];
        filterCoeffsAlign[2 * i + 7] = coeffs[i + 3];
    }
}



// mmx-optimized version of the filter routine for stereo sound
uint FIRFilterMMX::evaluateFilterStereo(short *dest, const short *src, uint numSamples) const
{
    // Create stack copies of the needed member variables for asm routines :
    uint i, j;
    __m64 *pVdest = (__m64*)dest;
    
    if (length < 2) return 0;
    
    for (i = 0; i < (numSamples - length) / 2; i ++)
    {
        __m64 accu1;
        __m64 accu2;
        const __m64 *pVsrc = (const __m64*)src;
        const __m64 *pVfilter = (const __m64*)filterCoeffsAlign;
        
        accu1 = accu2 = _mm_setzero_si64();
        for (j = 0; j < lengthDiv8 * 2; j ++)
        {
            __m64 temp1, temp2;
            
            temp1 = _mm_unpacklo_pi16(pVsrc[0], pVsrc[1]);  // = l2 l0 r2 r0
            temp2 = _mm_unpackhi_pi16(pVsrc[0], pVsrc[1]);  // = l3 l1 r3 r1
            
            accu1 = _mm_add_pi32(accu1, _mm_madd_pi16(temp1, pVfilter[0]));  // += l2*f2+l0*f0 r2*f2+r0*f0
            accu1 = _mm_add_pi32(accu1, _mm_madd_pi16(temp2, pVfilter[1]));  // += l3*f3+l1*f1 r3*f3+r1*f1
            
            temp1 = _mm_unpacklo_pi16(pVsrc[1], pVsrc[2]);  // = l4 l2 r4 r2
            
            accu2 = _mm_add_pi32(accu2, _mm_madd_pi16(temp2, pVfilter[0]));  // += l3*f2+l1*f0 r3*f2+r1*f0
            accu2 = _mm_add_pi32(accu2, _mm_madd_pi16(temp1, pVfilter[1]));  // += l4*f3+l2*f1 r4*f3+r2*f1
            
            // accu1 += l2*f2+l0*f0 r2*f2+r0*f0
            //       += l3*f3+l1*f1 r3*f3+r1*f1
            
            // accu2 += l3*f2+l1*f0 r3*f2+r1*f0
            //          l4*f3+l2*f1 r4*f3+r2*f1
            
            pVfilter += 2;
            pVsrc += 2;
        }
        // accu >>= resultDivFactor
        accu1 = _mm_srai_pi32(accu1, resultDivFactor);
        accu2 = _mm_srai_pi32(accu2, resultDivFactor);
        
        // pack 2*2*32bits => 4*16 bits
        pVdest[0] = _mm_packs_pi32(accu1, accu2);
        src += 4;
        pVdest ++;
    }
    
    _m_empty();  // clear emms state
    
    return (numSamples & 0xfffffffe) - length;
}

FIRFilter::FIRFilter()
{
    resultDivFactor = 0;
    resultDivider = 0;
    length = 0;
    lengthDiv8 = 0;
    filterCoeffs = NULL;
}


FIRFilter::~FIRFilter()
{
    delete[] filterCoeffs;
}

// Usual C-version of the filter routine for stereo sound
uint FIRFilter::evaluateFilterStereo(SAMPLETYPE *dest, const SAMPLETYPE *src, uint numSamples) const
{
    uint i, j, end;
    LONG_SAMPLETYPE suml, sumr;
#ifdef SOUNDTOUCH_FLOAT_SAMPLES
    // when using floating point samples, use a scaler instead of a divider
    // because division is much slower operation than multiplying.
    double dScaler = 1.0 / (double)resultDivider;
#endif
    
    assert(length != 0);
    assert(src != NULL);
    assert(dest != NULL);
    assert(filterCoeffs != NULL);
    
    end = 2 * (numSamples - length);
    
    for (j = 0; j < end; j += 2)
    {
        const SAMPLETYPE *ptr;
        
        suml = sumr = 0;
        ptr = src + j;
        
        for (i = 0; i < length; i += 4)
        {
            // loop is unrolled by factor of 4 here for efficiency
            suml += ptr[2 * i + 0] * filterCoeffs[i + 0] +
            ptr[2 * i + 2] * filterCoeffs[i + 1] +
            ptr[2 * i + 4] * filterCoeffs[i + 2] +
            ptr[2 * i + 6] * filterCoeffs[i + 3];
            sumr += ptr[2 * i + 1] * filterCoeffs[i + 0] +
            ptr[2 * i + 3] * filterCoeffs[i + 1] +
            ptr[2 * i + 5] * filterCoeffs[i + 2] +
            ptr[2 * i + 7] * filterCoeffs[i + 3];
        }
        
#ifdef SOUNDTOUCH_INTEGER_SAMPLES
        suml >>= resultDivFactor;
        sumr >>= resultDivFactor;
        // saturate to 16 bit integer limits
        suml = (suml < -32768) ? -32768 : (suml > 32767) ? 32767 : suml;
        // saturate to 16 bit integer limits
        sumr = (sumr < -32768) ? -32768 : (sumr > 32767) ? 32767 : sumr;
#else
        suml *= dScaler;
        sumr *= dScaler;
#endif // SOUNDTOUCH_INTEGER_SAMPLES
        dest[j] = (SAMPLETYPE)suml;
        dest[j + 1] = (SAMPLETYPE)sumr;
    }
    return numSamples - length;
}




// Usual C-version of the filter routine for mono sound
uint FIRFilter::evaluateFilterMono(SAMPLETYPE *dest, const SAMPLETYPE *src, uint numSamples) const
{
    uint i, j, end;
    LONG_SAMPLETYPE sum;
#ifdef SOUNDTOUCH_FLOAT_SAMPLES
    // when using floating point samples, use a scaler instead of a divider
    // because division is much slower operation than multiplying.
    double dScaler = 1.0 / (double)resultDivider;
#endif
    
    
    assert(length != 0);
    
    end = numSamples - length;
    for (j = 0; j < end; j ++)
    {
        sum = 0;
        for (i = 0; i < length; i += 4)
        {
            // loop is unrolled by factor of 4 here for efficiency
            sum += src[i + 0] * filterCoeffs[i + 0] +
            src[i + 1] * filterCoeffs[i + 1] +
            src[i + 2] * filterCoeffs[i + 2] +
            src[i + 3] * filterCoeffs[i + 3];
        }
#ifdef SOUNDTOUCH_INTEGER_SAMPLES
        sum >>= resultDivFactor;
        // saturate to 16 bit integer limits
        sum = (sum < -32768) ? -32768 : (sum > 32767) ? 32767 : sum;
#else
        sum *= dScaler;
#endif // SOUNDTOUCH_INTEGER_SAMPLES
        dest[j] = (SAMPLETYPE)sum;
        src ++;
    }
    return end;
}


// Set filter coeffiecients and length.
//
// Throws an exception if filter length isn't divisible by 8
void FIRFilter::setCoefficients(const SAMPLETYPE *coeffs, uint newLength, uint uResultDivFactor)
{
    assert(newLength > 0);
    if (newLength % 8) throw std::runtime_error("FIR filter length not divisible by 8");
    
    lengthDiv8 = newLength / 8;
    length = lengthDiv8 * 8;
    assert(length == newLength);
    
    resultDivFactor = uResultDivFactor;
    resultDivider = (SAMPLETYPE)::pow(2.0, (int)resultDivFactor);
    
    delete[] filterCoeffs;
    filterCoeffs = new SAMPLETYPE[length];
    memcpy(filterCoeffs, coeffs, length * sizeof(SAMPLETYPE));
}


uint FIRFilter::getLength() const
{
    return length;
}



// Applies the filter to the given sequence of samples.
//
// Note : The amount of outputted samples is by value of 'filter_length'
// smaller than the amount of input samples.
uint FIRFilter::evaluate(SAMPLETYPE *dest, const SAMPLETYPE *src, uint numSamples, uint numChannels) const
{
    assert(numChannels == 1 || numChannels == 2);
    
    assert(length > 0);
    assert(lengthDiv8 * 8 == length);
    if (numSamples < length) return 0;
    if (numChannels == 2)
    {
        return evaluateFilterStereo(dest, src, numSamples);
    } else {
        return evaluateFilterMono(dest, src, numSamples);
    }
}


// Operator 'new' is overloaded so that it automatically creates a suitable instance
// depending on if we've a MMX-capable CPU available or not.
void * FIRFilter::operator new(size_t s)
{
    // Notice! don't use "new FIRFilter" directly, use "newInstance" to create a new instance instead!
    throw std::runtime_error("Error in FIRFilter::new: Don't use 'new FIRFilter', use 'newInstance' member instead!");
    return NULL;
}


FIRFilter * FIRFilter::newInstance()
{
    uint uExtensions;
    
    uExtensions = detectCPUextensions();
    
    // Check if MMX/SSE instruction set extensions supported by CPU
    
#ifdef SOUNDTOUCH_ALLOW_MMX
    // MMX routines available only with integer sample types
    if (uExtensions & SUPPORT_MMX)
    {
        return ::new FIRFilterMMX;
    }
    else
#endif // SOUNDTOUCH_ALLOW_MMX
        
#ifdef SOUNDTOUCH_ALLOW_SSE
        if (uExtensions & SUPPORT_SSE)
        {
            // SSE support
            return ::new FIRFilterSSE;
        }
        else
#endif // SOUNDTOUCH_ALLOW_SSE
            
        {
            // ISA optimizations not supported, use plain C version
            return ::new FIRFilter;
        }
}


#endif

