//
//  VideoIntroViewController.h
//  local-database
//
//  Created by Nam Hyok on 4/18/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class ViewController;

@interface VideoIntroViewController : UIViewController {
    
    NSURL *mMovieURL;
    MPMoviePlayerController *mMoviewPlayer;
}
@property (strong, nonatomic) ViewController *viewController;


- (IBAction)click_test:(id)sender;

@end
