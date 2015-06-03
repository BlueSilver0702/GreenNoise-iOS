//
//  AppDelegate.m
//  medical-local
//
//  Created by Rose Jiang on 3/21/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "Flurry.h"
#import "Appirater.h"

@implementation AppDelegate

@synthesize m_twoDim_ringtone_images;
@synthesize m_twoDim_ringtone_sounds;

- (void)dealloc
{
    [_window release];
    //[_viewController release];
    [_videoIntroViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    // Initialize ringtone sounds.    
    m_twoDim_ringtone_sounds = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"11.mp3", @"1011",
                                @"12.mp3", @"1012",
                                @"13.mp3", @"1013",
                                @"14.mp3", @"1014",
                                @"15.mp3", @"2015",
                                @"16.mp3", @"2016",
                                @"17.mp3", @"2017",
                                @"18.mp3", @"2018",
                                @"21.mp3", @"1021",
                                @"22.mp3", @"1022",
                                @"23.mp3", @"1023",
                                @"24.mp3", @"1024",
                                @"25.mp3", @"2025",
                                @"26.mp3", @"2026",
                                @"27.mp3", @"2027",
                                @"28.mp3", @"2028",
                                @"31.mp3", @"1031",
                                @"32.mp3", @"1032",
                                @"33.mp3", @"1033",
                                @"34.mp3", @"1034",
                                @"35.mp3", @"2035",
                                @"36.mp3", @"2036",
                                @"37.mp3", @"2037",
                                @"38.mp3", @"2038",
                                @"41.mp3", @"1041",
                                @"42.mp3", @"1042",
                                @"43.mp3", @"1043",
                                @"44.mp3", @"1044",
                                @"45.mp3", @"2045",
                                @"46.mp3", @"2046",
                                @"47.mp3", @"2047",
                                @"48.mp3", @"2048",
                                nil];
    
    // Initialize ringtone images.
    m_twoDim_ringtone_images = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"11_display.jpg", @"1011",
                                @"12_display.jpg", @"1012",
                                @"13_display.jpg", @"1013",
                                @"14_display.jpg", @"1014",
                                @"15_display.jpg", @"2015",
                                @"16_display.jpg", @"2016",
                                @"17_display.jpg", @"2017",
                                @"18_display.jpg", @"2018",
                                @"21_display.jpg", @"1021",
                                @"22_display.jpg", @"1022",
                                @"23_display.jpg", @"1023",
                                @"24_display.jpg", @"1024",
                                @"25_display.jpg", @"2025",
                                @"26_display.jpg", @"2026",
                                @"27_display.jpg", @"2027",
                                @"28_display.jpg", @"2028",
                                @"31_display.jpg", @"1031",
                                @"32_display.jpg", @"1032",
                                @"33_display.jpg", @"1033",
                                @"34_display.jpg", @"1034",
                                @"35_display.jpg", @"2035",
                                @"36_display.jpg", @"2036",
                                @"37_display.jpg", @"2037",
                                @"38_display.jpg", @"2038",
                                @"41_display.jpg", @"1041",
                                @"42_display.jpg", @"1042",
                                @"43_display.jpg", @"1043",
                                @"44_display.jpg", @"1044",
                                @"45_display.jpg", @"2045",
                                @"46_display.jpg", @"2046",
                                @"47_display.jpg", @"2047",
                                @"48_display.jpg", @"2048",
                                nil];       
    
    [self setupMovie];
    
    // Flurry setup.
    [Flurry startSession:@"BJ9W7T422TRDVNHFGZS5"];
    [Flurry setEventLoggingEnabled:YES];
    
    // App rate.
    [Appirater setAppId:@"641206638"];
    [Appirater appLaunched:YES];
    
    //self.window.rootViewController = self.videoIntroViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // App rate.
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setupMovie {
    
    NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"AppIntroV3-square" ofType:@"mp4"];
    NSURL *mMovieURL = [NSURL fileURLWithPath:moviePath];
    
    mMoviewPlayer = [[MPMoviePlayerController alloc] initWithContentURL:mMovieURL];
    mMoviewPlayer.scalingMode = MPMovieScalingModeFill;
    mMoviewPlayer.controlStyle = MPMovieControlStyleNone;    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:mMoviewPlayer];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    [mMoviewPlayer.view setCenter:CGPointMake(screenSize.width/2, screenSize.height/2)];
    //[mMoviewPlayer.view setTransform:CGAffineTransformMakeRotation(-M_PI/2)];
    [mMoviewPlayer.view setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    [self.window addSubview:mMoviewPlayer.view];
    [mMoviewPlayer play];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    
    [mMoviewPlayer.view removeFromSuperview];
       
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
    self.window.rootViewController = self.viewController;
    //[self.window addSubview:self.viewController.view];

}

@end
