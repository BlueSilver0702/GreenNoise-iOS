//
//  ZASoundPlayer.m
//  ZenAwake
//
//  Created by Rose Jiang on 13-03-22.
//  Copyright 2013 Rose Jiang. All rights reserved.

#import "ZASoundPlayer.h"
#import "AppDelegate.h"

@interface ZASoundPlayer()
{
    SystemSoundID mySound;
    AVAudioPlayer *player;
    NSMutableArray *alarmQueue;
    AVAudioPlayer *sound1Player;
    AVAudioPlayer *sound2Player;
    AVAudioPlayer *sound3Player;
    AVAudioPlayer *sound4Player;
    AVAudioPlayer *sound5Player;
    
    id<ZASoundPlayerDelegate> delegate;
}
@property (nonatomic, assign) SystemSoundID mySound;
@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, retain) NSMutableArray *alarmQueue;
@property (nonatomic, retain) AVAudioPlayer *sound1Player;
@property (nonatomic, retain) AVAudioPlayer *sound2Player;
@property (nonatomic, retain) AVAudioPlayer *sound3Player;
@property (nonatomic, retain) AVAudioPlayer *sound4Player;
@property (nonatomic, retain) AVAudioPlayer *sound5Player;

/*
//- (void)playAlarm;
+ (NSArray*)heavyQueue;
+ (NSArray*)normalQueue;
+ (NSArray*)lightQueue;
+ (NSMutableArray*)silenceQueue:(int) seconds;
+ (NSMutableArray*)alarmQueue:(int)seconds;
*/
- (AVAudioPlayer *)audioPlayerWithContentsOfURL:(NSURL *)theURL;
- (void)timedAlarm:(int)seconds withSound:(NSString*)soundName;
@end

@implementation ZASoundPlayer
@synthesize mySound;
@synthesize player;
@synthesize delegate;
@synthesize alarmQueue;
@synthesize sound1Player;
@synthesize sound2Player;
@synthesize sound3Player;
@synthesize sound4Player;
@synthesize sound5Player;

#pragma mark -
#pragma mark Singleton Methods

static ZASoundPlayer *sharedInstance = nil; 

- (void)playSoundId:(kSoundValue)soundId
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    DLog(@"Play sound ID: %d", soundId);
    switch (soundId) 
    {
        case kSoundValue01:
        {
            if (self.sound1Player) {
                [self stopSoundId:soundId];
            }else {
            
                NSURL *soundUrl = [NSURL fileURLWithPath:
                               [NSString stringWithFormat:@"%@/%@", 
                                [[NSBundle mainBundle] resourcePath], 
                                [appDelegate.soundNames objectAtIndex:soundId]]];
                self.sound1Player = [self audioPlayerWithContentsOfURL:soundUrl];
            
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
                //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];    
                [[AVAudioSession sharedInstance] setActive: YES error: nil];
                [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            
                sound1Player.numberOfLoops=0;
                sound1Player.delegate = self;
                [sound1Player prepareToPlay];
                [sound1Player setVolume:1];
            
                [sound1Player play];
            }
            
            break;
        }
        case kSoundValue02:
        {
            
            if (self.sound2Player) {
                [self stopSoundId:soundId];
            }else {
                NSURL *soundUrl = [NSURL fileURLWithPath:
                               [NSString stringWithFormat:@"%@/%@", 
                                [[NSBundle mainBundle] resourcePath], 
                                [appDelegate.soundNames objectAtIndex:soundId]]];
                self.sound2Player = [self audioPlayerWithContentsOfURL:soundUrl];
            
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
                //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];    
                [[AVAudioSession sharedInstance] setActive: YES error: nil];
                [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            
                sound2Player.numberOfLoops=0;
                sound2Player.delegate = self;
                [sound2Player prepareToPlay];
                [sound2Player setVolume:1];
            
                [sound2Player play];
            }
            break;
        }
        case kSoundValue03:
        {
            if (self.sound3Player) {
                [self stopSoundId:soundId];
            }else {
                NSURL *soundUrl = [NSURL fileURLWithPath:
                               [NSString stringWithFormat:@"%@/%@", 
                                [[NSBundle mainBundle] resourcePath], 
                                [appDelegate.soundNames objectAtIndex:soundId]]];
                self.sound3Player = [self audioPlayerWithContentsOfURL:soundUrl];
            
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
                //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];    
                [[AVAudioSession sharedInstance] setActive: YES error: nil];
                [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            
                sound3Player.numberOfLoops=0;
                sound3Player.delegate = self;
                [sound3Player prepareToPlay];
                [sound3Player setVolume:1];
            
                [sound3Player play];
            }
            break;
        }
        case kSoundValue04:
        {
            if (self.sound4Player) {
                [self stopSoundId:soundId];
            }else {
                NSURL *soundUrl = [NSURL fileURLWithPath:
                               [NSString stringWithFormat:@"%@/%@",
                                [[NSBundle mainBundle] resourcePath],
                                [appDelegate.soundNames objectAtIndex:soundId]]];
                self.sound4Player = [self audioPlayerWithContentsOfURL:soundUrl];
            
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
                //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                [[AVAudioSession sharedInstance] setActive: YES error: nil];
                [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            
                sound4Player.numberOfLoops=0;
                sound4Player.delegate = self;
                [sound4Player prepareToPlay];
                [sound4Player setVolume:1];
            
                [sound4Player play];
            }
            break;
        }
        case kSoundValue05:
        {
            if (self.sound5Player) {
                [self stopSoundId:soundId];
            }else {
                NSURL *soundUrl = [NSURL fileURLWithPath:
                               [NSString stringWithFormat:@"%@/%@",
                                [[NSBundle mainBundle] resourcePath],
                                [appDelegate.soundNames objectAtIndex:soundId]]];
                self.sound5Player = [self audioPlayerWithContentsOfURL:soundUrl];
            
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
                //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                [[AVAudioSession sharedInstance] setActive: YES error: nil];
                [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            
                sound5Player.numberOfLoops=0;
                sound5Player.delegate = self;
                [sound5Player prepareToPlay];
                [sound5Player setVolume:1];
            
                [sound5Player play];
            }
            break;
        }            
        default:
            break;
    }

}

- (void)stopSoundId:(kSoundValue)soundId
{
    DLog(@"Stop sound ID: %d", soundId);
    switch (soundId) 
    {
        case kSoundValue01:
        {
//            if (sound1Player.volume > 0.05)
//            {
//                [sound1Player setVolume:(sound1Player.volume - 0.1)];
//                [self performSelector:@selector(stopSoundId:) withObject:soundId afterDelay:0.01];           
//            } 
//            else
            {
                // Stop and get the sound ready for playing again
                [sound1Player stop];
                [sound1Player setCurrentTime:0.0];
                
                [sound1Player release];
                sound1Player = nil;
                //[lightPlayer setVolume:1.0];
            }
            break;
        }
        case kSoundValue02:
        {
//            if (sound2Player.volume > 0.05)
//            {
//                [sound2Player setVolume:(sound2Player.volume - 0.1)];
//                [self performSelector:@selector(stopSoundId:) withObject:soundId afterDelay:0.01];           
//            } 
//            else 
            {
                // Stop and get the sound ready for playing again
                [sound2Player stop];
                [sound2Player setCurrentTime:0.0];
                //[normalPlayer setVolume:1.0];
                
                [sound2Player release];
                sound2Player = nil;
            }
            break;
        }
        case kSoundValue03:
        {
//            if (sound3Player.volume > 0.05)
//            {
//                [sound3Player setVolume:(sound3Player.volume - 0.1)];
//                [self performSelector:@selector(stopSoundId:) withObject:soundId afterDelay:0.01];           
//            } 
//            else 
            {
                // Stop and get the sound ready for playing again
                [sound3Player stop];
                [sound3Player setCurrentTime:0.0];
                //[heavyPlayer setVolume:1.0];
                
                [sound3Player release];
                sound3Player = nil;
            }
            break;
        }
        case kSoundValue04:
        {
//            if (sound4Player.volume > 0.05)
//            {
//                [sound4Player setVolume:(sound4Player.volume - 0.1)];
//                [self performSelector:@selector(stopSoundId:) withObject:soundId afterDelay:0.01];
//            }
//            else
            {
                // Stop and get the sound ready for playing again
                [sound4Player stop];
                [sound4Player setCurrentTime:0.0];
                //[heavyPlayer setVolume:1.0];
                
                [sound4Player release];
                sound4Player = nil;
            }
            break;
        }
        case kSoundValue05:
        {
//            if (sound5Player.volume > 0.05)
//            {
//                [sound5Player setVolume:(sound5Player.volume - 0.1)];
//                [self performSelector:@selector(stopSoundId:) withObject:soundId afterDelay:0.01];
//            }
//            else
            {
                // Stop and get the sound ready for playing again
                [sound5Player stop];
                [sound5Player setCurrentTime:0.0];
                //[heavyPlayer setVolume:1.0];
                
                [sound5Player release];
                sound5Player = nil;
            }
            break;
        }
        default:
            break;
    }

}

- (void)playSound:(kSoundValue)soundId
{
    //DLog(@"Play sound name: %@", soundName);
    /*
     AudioServicesDisposeSystemSoundID(mySound);
     mySound = [AppDelegate createSoundID:soundName];
     AudioServicesPlaySystemSound(mySound);
     */
    /*
    CFStringRef state; 
    UInt32 propertySize = sizeof(CFStringRef); 
    AudioSessionInitialize(NULL, NULL, NULL, NULL); 
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &state); 
    if(CFStringGetLength(state) == 0)
    { //SILENT
        NSLog(@"Silent switch is on");
        //create vibrate 
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        //this 2 line below use to play audio even in silent/vibrator mode too      
        UInt32 audioCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty( kAudioSessionProperty_AudioCategory, sizeof(UInt32), &audioCategory);
        AudioServicesDisposeSystemSoundID(mySound);
        mySound = [AppDelegate createSoundID:soundName];
        AudioServicesPlaySystemSound(mySound);
    }
    else 
    { //NOT SILENT
        NSLog(@"Silent switch is off");
        AudioServicesDisposeSystemSoundID(mySound);
        mySound = [AppDelegate createSoundID:soundName];
        AudioServicesPlaySystemSound(mySound);
    }
    */
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //Stop first and then play
    if (self.player)
    {
        while (self.player.volume>0.05)
        {
            [player setVolume:(player.volume - 0.001)];
        }
        [self.player stop];
        [self.player setCurrentTime:0.0];
        [self.player setVolume:1.0];
        [self.player release];
        self.player = nil;

        
    }

    NSURL *soundUrl = [NSURL fileURLWithPath:
                       [NSString stringWithFormat:@"%@/%@",
                        [[NSBundle mainBundle] resourcePath],
                        [appDelegate.soundNames objectAtIndex:soundId]]];

    self.player = [self audioPlayerWithContentsOfURL:soundUrl];
    
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];    
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    self.player.numberOfLoops=0;
    self.player.delegate = self;
    [self.player prepareToPlay];
    
    [self.player setVolume:1.0]; // iPHTechnologies
    [self.player play];
}

- (AVAudioPlayer *)audioPlayerWithContentsOfURL:(NSURL *)theURL 
{
    NSData *audioData = [NSData dataWithContentsOfURL:theURL];
    AVAudioPlayer *audioPlayer = [AVAudioPlayer alloc];
    if([audioPlayer initWithData:audioData error:NULL] == nil)
    {
        [audioPlayer release];
        audioPlayer = nil;

    }
//    {
//        [audioPlayer autorelease];
//    } 
//    else 
//    {
//        [audioPlayer release];
//        audioPlayer = nil;
//    }
    return audioPlayer;
}

- (void)stopSound
{
    //DLog(@"Stop sound name: %@", soundName);
    //AudioServicesDisposeSystemSoundID(mySound);
    
//    if (self.player.volume > 0.05) 
//    {
//        [self.player setVolume:(player.volume - 0.1)];
//        [self performSelector:@selector(stopSound:) withObject:nil afterDelay:0.01];           
//    } 
//    else 
    {
        // Stop and get the sound ready for playing again
        [self.player stop];
        [self.player setCurrentTime:0.0];
        [self.player setVolume:1.0];
        
        [self.player release];
        self.player = nil;
        
    }
    
}

- (void)soundFinishPlaying
{
    //[self playAlarm];
}

- (void)cancelAlarm
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)createAlarm:(int)seconds
{
//    NSString *soundName = [AppDelegate sharedAppDelegate].alarm.soundName;
//    
//    [self timedAlarm:seconds withSound:soundName];
//    [self timedAlarm:seconds+228 withSound:soundName];
//    [self timedAlarm:seconds+369 withSound:soundName];    
//    [self timedAlarm:seconds+457 withSound:soundName];    
//    [self timedAlarm:seconds+511 withSound:soundName];    
//    [self timedAlarm:seconds+545 withSound:soundName];    
//    [self timedAlarm:seconds+566 withSound:soundName];    
//    [self timedAlarm:seconds+579 withSound:soundName];    
//    [self timedAlarm:seconds+587 withSound:soundName];    
//    [self timedAlarm:seconds+600 withSound:kPulseSound];
    /*
    for (int i=1; i<=54; i++) 
    {
        [self timedAlarm:seconds+600+(28*i) withSound:kPulseSound];
        //[self performSelector:@selector(playSound:) withObject:kPulseSound afterDelay:seconds+600+(28*i)];
    }
    */
}

- (void)timedAlarm:(int)seconds withSound:(NSString*)soundName
{
//    //NSString *alertMessage = @"Wake up!";
//    UILocalNotification *notif = [[UILocalNotification alloc] init];
//    notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:seconds];
//    notif.timeZone = [NSTimeZone defaultTimeZone];
//    //notif.alertBody = alertMessage;
//    //notif.alertAction = @"Show me";
//    notif.soundName = soundName;
//    notif.applicationIconBadgeNumber = 0;
//    NSDictionary *userDict = [NSDictionary dictionaryWithObject:soundName forKey:kCurrentSound];
//    notif.userInfo = userDict;
//    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
//    [notif release];
}

/*
- (void)playAlarm
{
    if (alarmQueue.count>0) 
    {
        [self playSound:[alarmQueue objectAtIndex:0]];
        DLog(@"Playing sound: %@", [alarmQueue objectAtIndex:0]);
        [alarmQueue removeObjectAtIndex:0];
    }
}
*/
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)paramPlayer successfully:(BOOL)flag
{
    DLog(@"Sound finish playing");
    
    [paramPlayer release];
    paramPlayer = nil;
    
    [delegate soundFinishPlaying];
}

+ (void)initialize
{
    if (sharedInstance == nil)
        sharedInstance = [[self alloc] init];
}

+ (id)sharedInstance
{
    //Already set by +initialize.
    [ZASoundPlayer initialize];
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone*)zone
{
    //Usually already set by +initialize.
    if (sharedInstance) {
        //The caller expects to receive a new object, so implicitly retain it
        //to balance out the eventual release message.
        return [sharedInstance retain];
    } else {
        //When not already set, +initialize is our caller.
        //It's creating the shared instance, let this go through.
        return [super allocWithZone:zone];
    }
}

- (id)init
{
    NSURL *soundUrl;
    
    //If sharedInstance is nil, +initialize is our caller, so initialize the instance.
    //If it is not nil, simply return the instance without re-initializing it.
    if (sharedInstance == nil) 
    {
        self = [super init];
        if (self) 
        {
            if (LITE_VER) {
                //Initialize the instance here.
               soundUrl = [NSURL fileURLWithPath:
                                   [NSString stringWithFormat:@"%@/%@",
                                    [[NSBundle mainBundle] resourcePath], kFreeSound01]];
            }else
            {
                //Initialize the instance here.
               soundUrl = [NSURL fileURLWithPath:
                                   [NSString stringWithFormat:@"%@/%@",
                                    [[NSBundle mainBundle] resourcePath], kPaidSound01]];
            }
#if 0
            self.player = [self audioPlayerWithContentsOfURL:soundUrl];
            player.numberOfLoops=0;
            player.delegate = self;
            [player prepareToPlay];
            
            self.sound1Player = [self audioPlayerWithContentsOfURL:soundUrl];
            sound1Player.numberOfLoops=0;
            sound1Player.delegate = self;
            [sound1Player prepareToPlay];
            
            self.sound2Player = [self audioPlayerWithContentsOfURL:soundUrl];
            sound2Player.numberOfLoops=0;
            sound2Player.delegate = self;
            [sound2Player prepareToPlay];
            
            self.sound3Player = [self audioPlayerWithContentsOfURL:soundUrl];
            sound3Player.numberOfLoops=0;
            sound3Player.delegate = self;
            [sound3Player prepareToPlay];
            
            self.sound4Player = [self audioPlayerWithContentsOfURL:soundUrl];
            sound4Player.numberOfLoops=0;
            sound4Player.delegate = self;
            [sound4Player prepareToPlay];
            
            self.sound5Player = [self audioPlayerWithContentsOfURL:soundUrl];
            sound5Player.numberOfLoops=0;
            sound5Player.delegate = self;
            [sound5Player prepareToPlay];
#endif
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}
- (id)retain
{
    return self;
}
- (unsigned)retainCount
{
    return UINT_MAX; // denotes an object that cannot be released
}
- (oneway void)release
{
    // do nothing 
}
- (id)autorelease
{
    return self;
}

#pragma mark -
#pragma mark Custom Methods

// Add your custom methods here
/*
+ (NSMutableArray*)alarmQueue:(int)seconds
{
    NSMutableArray *queue = [NSMutableArray arrayWithArray:[ZASoundPlayer silenceQueue:seconds]];
    switch ([AppDelegate sharedAppDelegate].soundLevel) 
    {
        case kZASoundValueLight:
            [queue addObjectsFromArray:[ZASoundPlayer lightQueue]];
            break;
        case kZASoundValueNormal:
            [queue addObjectsFromArray:[ZASoundPlayer normalQueue]];
            break;
        case kZASoundValueHeavly:
            [queue addObjectsFromArray:[ZASoundPlayer heavyQueue]];
            break;
    }
    return queue;
}


+ (NSArray*)heavyQueue
{
    return [NSArray arrayWithObjects:
            kHeavySound, kSilenceSound60, kSilenceSound60, kSilenceSound60, kSilenceSound10, kSilenceSound10, kSilenceSound02, 
            kHeavySound, kSilenceSound60, kSilenceSound10, kSilenceSound10, kSilenceSound10, kSilenceSound10, kSilenceSound10, kSilenceSound03, kSilenceSound02,
            kHeavySound, kSilenceSound60, kSilenceSound02,
            kHeavySound, kSilenceSound10, kSilenceSound10, kSilenceSound10, kSilenceSound05, kSilenceSound03,
            kHeavySound, kSilenceSound05, kSilenceSound03,
            kHeavySound21, 
            kHeavySound13, 
            kHeavySound08, 
            kPulseSound,
            nil];
}

+ (NSArray*)normalQueue
{
    return [NSArray arrayWithObjects:
            kNormalSound, kSilenceSound60, kSilenceSound60, kSilenceSound60, kSilenceSound10, kSilenceSound10, kSilenceSound02, kSilenceSound03, kSilenceSound03, kSilenceSound03,
            kNormalSound, kSilenceSound60, kSilenceSound10, kSilenceSound10, kSilenceSound10, kSilenceSound10, kSilenceSound10, kSilenceSound03, kSilenceSound02, kSilenceSound03, kSilenceSound03, kSilenceSound03,
            kNormalSound, kSilenceSound60, kSilenceSound02, kSilenceSound03, kSilenceSound03, kSilenceSound03,
            kNormalSound, kSilenceSound10, kSilenceSound10, kSilenceSound10, kSilenceSound05, kSilenceSound03, kSilenceSound03, kSilenceSound03, kSilenceSound03,
            kNormalSound, kSilenceSound05, kSilenceSound03, kSilenceSound03, kSilenceSound03, kSilenceSound03,
            kNormalSound, kSilenceSound02, kSilenceSound03,
            kNormalSound13, 
            kNormalSound08, 
            kPulseSound,
            nil];
}

+ (NSArray*)lightQueue
{
    return [NSArray arrayWithObjects:
            kLightSound, kSilenceSound60, kSilenceSound60, kSilenceSound60, kSilenceSound10, kSilenceSound10, kSilenceSound02, kSilenceSound10,
            kLightSound, kSilenceSound60, kSilenceSound10, kSilenceSound10, kSilenceSound10, kSilenceSound10, kSilenceSound10, kSilenceSound03, kSilenceSound02, kSilenceSound10,
            kLightSound, kSilenceSound60, kSilenceSound02, kSilenceSound10,
            kLightSound, kSilenceSound10, kSilenceSound10, kSilenceSound10, kSilenceSound05, kSilenceSound03, kSilenceSound10,
            kLightSound, kSilenceSound05, kSilenceSound03, kSilenceSound10,
            kLightSound, kSilenceSound05,
            kLightSound13, 
            kLightSound08, 
            kPulseSound,
            nil];
}

+ (NSMutableArray*)silenceQueue:(int) seconds
{
    NSMutableArray *result = [NSMutableArray array];
    int numElements60 = seconds/60;
    int remainOf60 = seconds%60;
    int numElements10 = remainOf60/10;
    int remainOf10 = remainOf60%10;
    int numElements2 = remainOf10/2;
    int remainOf2 = remainOf10%2;
    
    int numElements3 = remainOf2==0?0:1;
    numElements2 += remainOf2==0?0:-1;
    
    for (int i = 0; i<numElements60; i++) 
    {
        [result addObject:kSilenceSound60];
    }
    for (int i = 0; i<numElements10; i++) 
    {
        [result addObject:kSilenceSound10];
    }
    for (int i = 0; i<numElements2; i++) 
    {
        [result addObject:kSilenceSound02];
    }
    for (int i = 0; i<numElements3; i++) 
    {
        [result addObject:kSilenceSound03];
    }
    return result;
}
*/

@end
