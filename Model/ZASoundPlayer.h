//
//  ZASoundPlayer.h
//  ZenAwake
//
//  Created by Tuyen Nguyen on 12-02-18.
//  Copyright 2012 Tuyen Nguyen. All rights reserved.

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioServices.h>

typedef enum
{
    kSoundValue01 = 0,
    kSoundValue02 = 1,
    kSoundValue03 = 2,
    kSoundValue04 = 3,
    kSoundValue05 = 4,
    kSoundValueTotal = 5
}kSoundValue;

@protocol ZASoundPlayerDelegate <NSObject>

- (void)soundFinishPlaying;

@end

@interface ZASoundPlayer : NSObject< AVAudioPlayerDelegate, ZASoundPlayerDelegate>

@property (nonatomic, assign) id<ZASoundPlayerDelegate> delegate;
+ (ZASoundPlayer*) sharedInstance;
- (void)playSound:(kSoundValue)soundId;
- (void)stopSound;
- (void)createAlarm:(int)seconds;
- (void)cancelAlarm;

- (void)playSoundId:(kSoundValue)soundId;
- (void)stopSoundId:(kSoundValue)soundId;
@end
