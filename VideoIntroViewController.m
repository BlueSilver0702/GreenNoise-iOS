//
//  VideoIntroViewController.m
//  local-database
//
//  Created by Nam Hyok on 4/18/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import "VideoIntroViewController.h"
#import "ViewController.h"

@interface VideoIntroViewController ()

@end

@implementation VideoIntroViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    NSBundle *bundle = [NSBundle mainBundle];
    if (bundle) {
        NSString *moviePath = [bundle pathForResource:@"AppIntroV3-960" ofType:@"mp4"];
        if (moviePath) {
            mMovieURL = [NSURL fileURLWithPath:moviePath];
            [mMovieURL retain];
        }
    }
    
    mMoviewPlayer = [[MPMoviePlayerController alloc] initWithContentURL:mMovieURL];
    [mMovieURL release];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:mMoviewPlayer];
    [mMoviewPlayer play];

}

//- (void)viewDidAppear:(BOOL)animated {
//    
//    mMoviewPlayer = [[MPMoviePlayerController alloc] initWithContentURL:mMovieURL];
//    [mMovieURL release];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:mMoviewPlayer];
//    //[mMoviewPlayer play];
//}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    
    [mMoviewPlayer release];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenSize.height > 480.0f) {
            /*Do iPhone 5 stuff here.*/
            self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iphone5" bundle:nil] autorelease];
            
        } else {
            /*Do iPhone Classic stuff here.*/
            self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iphone4" bundle:nil] autorelease];            
        }
    }
    [self presentModalViewController:self.viewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
