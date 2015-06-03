//
//  AboutViewController.m
//  local-database
//
//  Created by Nam Hyok on 4/11/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import "AboutViewController.h"


#define TAG_ABOUT_SCROLL    500




@interface AboutViewController ()

@end

@implementation AboutViewController

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
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Check if this orientation is portrait mode or lancscape mode.
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
        // Landscape mode.       
        
        // Scroll view
        for (int i=1; i<6; i++) {
            CGRect frame = CGRectMake((self.ui_landscapeScroll.frame.size.height) * (i-1) + 10 * (i-1),
                                      0,
                                      self.ui_landscapeScroll.frame.size.height,
                                      self.ui_landscapeScroll.frame.size.height);
            
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"project_item_%d.jpg", i]];
            UIImageView *iv = [[UIImageView alloc] initWithFrame:frame];
            [iv setImage:img];
            [img release];
            [self.ui_landscapeScroll addSubview:iv];
            [iv release];
            
            CGRect intervalFrame = CGRectMake(self.ui_landscapeScroll.frame.size.height * i,
                                              0,
                                              10,
                                              self.ui_landscapeScroll.frame.size.height);
            
            UIView * intervalView= [[UIView alloc] initWithFrame:intervalFrame];
            intervalView.backgroundColor = [UIColor clearColor];
            [self.ui_landscapeScroll addSubview:intervalView];
            [intervalView release];            
        }
        
        self.ui_landscapeScroll.contentSize = CGSizeMake((self.ui_landscapeScroll.frame.size.height)*5 + 50, self.ui_landscapeScroll.frame.size.height);
        self.ui_landscapeScroll.delegate = self;
        self.ui_landscapeScroll.scrollEnabled = YES;
        self.ui_landscapeScroll.pagingEnabled = YES;
                
        [self.view addSubview:self.uiview_landscape];
        [self.view bringSubviewToFront:self.uiview_landscape];
        
    }else { //if([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown){
        // Portrait mode.
        
        for (int i=1; i<6; i++) {
            CGRect frame = CGRectMake(0 ,
                                      self.ui_portraitScroll.frame.size.width * (i-1) + 10*(i-1),
                                      self.ui_portraitScroll.frame.size.width,
                                      self.ui_portraitScroll.frame.size.width);
            
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"project_item_%d.jpg", i]];
            UIImageView *iv = [[UIImageView alloc] initWithFrame:frame];
            [iv setImage:img];
            [img release];
            [self.ui_portraitScroll addSubview:iv];
            [iv release];
            
            CGRect intervalFrame = CGRectMake(0 ,
                                      self.ui_portraitScroll.frame.size.width * i,
                                      self.ui_portraitScroll.frame.size.width,
                                      10);
            UIView * intervalView= [[UIView alloc] initWithFrame:intervalFrame];
            intervalView.backgroundColor = [UIColor clearColor];
            [self.ui_portraitScroll addSubview:intervalView];
            [intervalView release];
            
        }
        
        self.ui_portraitScroll.contentSize = CGSizeMake(self.ui_portraitScroll.frame.size.width, self.ui_portraitScroll.frame.size.width*5);
        self.ui_portraitScroll.delegate = self;
        self.ui_portraitScroll.scrollEnabled = YES;
        self.ui_portraitScroll.pagingEnabled = YES;
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_uiview_landscape release];
    
    [_ui_landscapeScroll release];
    [_ui_portraitScroll release];
    [_btn_website release];
    [_btn_facebook release];
    [_btn_instagram release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setUiview_landscape:nil];
    
    [self setUi_landscapeScroll:nil];
    [self setUi_portraitScroll:nil];
    [self setBtn_website:nil];
    [self setBtn_facebook:nil];
    [self setBtn_instagram:nil];
    [super viewDidUnload];
}


///************************************************************* ScrollViewDelegate ********************************************************************/
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    //[self updatePager];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    
//}

/************************************************************* Auto Rotation ************************************************************************/
- (BOOL) shouldAutorotate {
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if ( toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown )
    {
        [self.uiview_landscape removeFromSuperview];
        
        for (int i=1; i<6; i++) {
            CGRect frame = CGRectMake(0 ,
                                      self.ui_portraitScroll.frame.size.width * (i-1) + 10 * (i-1),
                                      self.ui_portraitScroll.frame.size.width,
                                      self.ui_portraitScroll.frame.size.width);
            
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"project_item_%d.jpg", i]];
            UIImageView *iv = [[UIImageView alloc] initWithFrame:frame];
            [iv setImage:img];
            [img release];
            [self.ui_portraitScroll addSubview:iv];
            [iv release];
            
            CGRect intervalFrame = CGRectMake(0 ,
                                              self.ui_portraitScroll.frame.size.width * i,
                                              self.ui_portraitScroll.frame.size.width,
                                              10);
            UIView * intervalView= [[UIView alloc] initWithFrame:intervalFrame];
            intervalView.backgroundColor = [UIColor clearColor];
            [self.ui_portraitScroll addSubview:intervalView];
            [intervalView release];           
            
        }
        self.ui_portraitScroll.contentSize = CGSizeMake(self.ui_portraitScroll.frame.size.width, self.ui_portraitScroll.frame.size.width*5);
        self.ui_portraitScroll.delegate = self;
        self.ui_portraitScroll.scrollEnabled = YES;
        self.ui_portraitScroll.pagingEnabled = YES;
        
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight )
    {         
        
        
        // Scroll view
        for (int i=1; i<6; i++) {
            CGRect frame = CGRectMake(self.ui_landscapeScroll.frame.size.height * (i-1) + 10 * (i-1),
                                      0,
                                      self.ui_landscapeScroll.frame.size.height,
                                      self.ui_landscapeScroll.frame.size.height);
            
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"project_item_%d.jpg", i]];
            UIImageView *iv = [[UIImageView alloc] initWithFrame:frame];
            [iv setImage:img];
            [img release];
            [self.ui_landscapeScroll addSubview:iv];
            [iv release];
            
            CGRect intervalFrame = CGRectMake(self.ui_landscapeScroll.frame.size.height * i,
                                              0,
                                              10,
                                              self.ui_landscapeScroll.frame.size.height);
            
            UIView * intervalView= [[UIView alloc] initWithFrame:intervalFrame];
            intervalView.backgroundColor = [UIColor clearColor];
            [self.ui_landscapeScroll addSubview:intervalView];
            [intervalView release];            
        }
        
        self.ui_landscapeScroll.contentSize = CGSizeMake(self.ui_landscapeScroll.frame.size.height*5 + 50, self.ui_landscapeScroll.frame.size.height);
        self.ui_landscapeScroll.delegate = self;
        self.ui_landscapeScroll.scrollEnabled = YES;
        self.ui_landscapeScroll.pagingEnabled = YES;
                
        [self.view addSubview:self.uiview_landscape];
        [self.view bringSubviewToFront:self.uiview_landscape];
    }
}

- (IBAction)click_websiteBtn:(id)sender {
    
    NSLog(@"website button is clicked");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.greennoise.cr"]];
}

- (IBAction)click_facebookBtn:(id)sender {
    
    NSLog(@"facebook button is clicked");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com/GreenNoiseapp"]];
}

- (IBAction)click_instagramBtn:(id)sender {
    
    NSLog(@"instagram button is clicked");
}

- (IBAction)click_closeBtn:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
