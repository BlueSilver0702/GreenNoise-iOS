//
//  AppDelegate.h
//  medical-local
//
//  Created by Rose Jiang on 3/21/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class ViewController;
@class VideoIntroViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    MPMoviePlayerController *mMoviewPlayer;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) VideoIntroViewController *videoIntroViewController;

@property(strong, nonatomic) NSDictionary *m_twoDim_ringtone_sounds;
@property(strong, nonatomic) NSDictionary *m_twoDim_ringtone_images;


@end
