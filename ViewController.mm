//
//  ViewController.m
//  medical-local
//
//  Created by Rose Jiang on 3/21/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#include "AQPlayer.h"
#include "SoundTouch.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AboutViewController.h"
#import "Flurry.h"

#define TAG_IMAGE_DISPLAY_VIEW  100 
#define TAG_SELECTED_VIEW       200
#define TAG_BGIMAGE_VIEW        500

// Iphone 4 scroll views tag.
#define TAG_IPHONE4_VIEW1_SCROLLVIEW    1411 // portrait original view.
#define TAG_IPHONE4_VIEW2_SCROLLVIEW    1421 // portrait view.
#define TAG_IPHONE4_VIEW3_SCROLLVIEW    1431 // landscape view.

@interface ViewController ()

@end

@implementation ViewController

@synthesize uiview_landscape = _uiview_landscape;
@synthesize soundMgr;
@synthesize m_mapDic;
@synthesize m_prevTargetPath;

#define EXPORT_NAME @"exported"
#define SAVED_NAME @"saved.m4r"
#define LIMIT_OF_RINGTONE   40 // The length of ringtone is limited to 40 seconds.

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_landscape = false;
    m_rotate = NO;
    m_firstToSelRingBtn = YES;
    m_deviceState = DEVICESTATE_HORIZONTAL;
    
    // Initialize the map table.
    m_mapDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"Rain Forest Melody", @"1011",
                                @"Margay Wisdom", @"1012",
                                @"Calls in the Great Mountain", @"1013",
                                @"The Great Toad", @"1014",
                                @"Fresh Green Tunes", @"2015",
                                @"Jungle Choir", @"2016",
                                @"Natural Fills", @"2017",
                                @"Symphony of Birds", @"2018",
                                @"Rolling Thunder", @"1021",
                                @"Howler Awakening", @"1022",
                                @"Jaguar King", @"1023",
                                @"Joy in the Forest", @"1024",
                                @"Noon in the RainForest", @"2025",
                                @"Darkening Dusk", @"2026",
                                @"The Awakening of the Jungle", @"2027",
                                @"Howler's Dusk", @"2028",
                                @"Prowling Puma", @"1031",
                                @"Afternoon in the Marsh", @"1032",
                                @"Wetland Magic", @"1033",
                                @"Electric Cicada", @"1034",
                                @"Voices of Carara", @"2035",
                                @"Mountain Melodies", @"2036",
                                @"Puma Curiocity", @"2037",
                                @"Flyers of the Forest", @"2038",
                                @"Tropical Song", @"1041",
                                @"Big Cat Small Voice", @"1042",
                                @"Nest the nest", @"1043",
                                @"Mangrove Harmony", @"1044",
                                @"Voices of the Night", @"2045",
                                @"Wetland Lucid Dreams", @"2046",
                                @"Feast of Birds", @"2047",
                                @"Through the Mangrove", @"2048",
                                nil];    
    
        
    /* Settings for converting ringtone. */
    m_nRingToneLengthTime = LIMIT_OF_RINGTONE;
    
    // Initialize a sound player.    
	self.soundMgr = [[[CMOpenALSoundManager alloc] init] autorelease];
    self.soundMgr.delegate = self;
    
    m_playingNow = false;
    m_firstStopped = false;
    m_showInstallBar = NO;
    m_showMenuBar = NO;
    m_showInstallBar = NO;
    m_showIntroBar = YES;
    m_prevSelectedTag = 11;
    
    [self.view_activity setHidden:YES];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];    
    
    // Check if this orientation is portrait mode or lancscape mode.
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) { // Landscape mode.
        
        [self.l_scroll_image_ringtone setContentSize:CGSizeMake(239, 960)];
        self.l_scroll_image_ringtone.delegate = self;
        self.l_scroll_image_ringtone.scrollEnabled = YES;
        self.l_scroll_image_ringtone.pagingEnabled = YES;
        // Set ringtone desc label on portrait mode..
        
      
        // Set ringtone image on Portrait mode.
        UIImage *image;
        if (m_firstToSelRingBtn) {
            image = [UIImage imageNamed: @"introImage"];
            
            // Hide selectedImageView.
            UIImageView *imgSelectedView = (UIImageView *)[self.uiview_landscape viewWithTag:TAG_SELECTED_VIEW];
            imgSelectedView.hidden = YES;
            
        }else {
            image = [UIImage imageNamed: m_ringtoneImageName];
            
            // Display selectedDisplayImageView
            UIImageView *imgSelectedView = (UIImageView *)[self.uiview_landscape viewWithTag:TAG_SELECTED_VIEW];
            UIButton *selectedRingBtn = (UIButton*)[self.uiview_landscape viewWithTag:m_selectedTag];
            [imgSelectedView setFrame:CGRectMake((selectedRingBtn.frame.origin.x + selectedRingBtn.frame.size.width/4), (selectedRingBtn.frame.origin.y + selectedRingBtn.frame.size.height/4), imgSelectedView.frame.size.width, imgSelectedView.frame.size.height)];
            imgSelectedView.hidden = NO;
        }
        UIImageView *imageView = (UIImageView*)[self.uiview_landscape viewWithTag:100];
        [imageView setImage:image];
        //[image release];
                
        // Set the Green Alert/Tone category.
        if ((1000 < m_selectedTag) && (m_selectedTag < 1050)) { // GreenAlert.
            
            UILabel *categoryLabel = (UILabel*)[_uiview_landscape viewWithTag:301];
            categoryLabel.textColor = [UIColor yellowColor];
            categoryLabel.text = @"GreenAlert";
            
        }else if((2000 < m_selectedTag) && (m_selectedTag < 2050)) { // GreenTone.
            
            UILabel *categoryLabel = (UILabel*)[_uiview_landscape viewWithTag:301];
            categoryLabel.textColor = [UIColor yellowColor];
            categoryLabel.text = @"GreenTone";
        }        
        
        NSString *strKey = [NSString stringWithFormat:@"%d", m_selectedTag];
        NSString *selectedSoundName = (NSString *)[m_mapDic objectForKey:strKey];
        UILabel *titleLabel = (UILabel*)[_uiview_landscape viewWithTag:300];
        titleLabel.text = selectedSoundName;
        
        m_deviceState = DEVICESTATE_LANDSCAPE;
        
        [self.view addSubview:self.uiview_landscape];
        [self.view bringSubviewToFront:self.uiview_landscape];
        
        // Show/Hide the intro bar.
        if (m_showIntroBar) {
            
            // Show the intro bar.
            self.l_uiview_collapsableIntro.alpha = 1.0f;
            self.l_uiview_collapsableIntro.hidden = NO;
        }else {
            
            // Hide the intro bar.
            self.l_uiview_collapsableIntro.hidden = YES;
        }
        
        // Show/Hide the install bar.
        if (m_showInstallBar) {
            m_showInstallBar = NO;
        }
        if (m_showInstallBar) {
            
            // Show the install background image and install button.
            self.l_img_install_confirm.hidden = NO;
            self.l_btn_install.hidden = NO;
        }else {
            
            // Hide the install background image and install button.
            self.l_img_install_confirm.hidden = YES;
            self.l_btn_install.hidden = YES;
        }
        
        // Show/Hide the menu bar.
        if (m_showMenuBar) {
            
            // Show Menu bar
            self.l_uiview_menu.hidden = NO;
            m_showDescriptionBar = YES;
        }else {
            
            // Hide Menu bar
            self.l_uiview_menu.hidden = YES;
        }       
        
        // Show/Hide the description bar.
        if (m_showDescriptionBar) {
            
            // Show Desc bar.
            self.l_uiview_description.hidden = NO;
            self.l_uiview_description.alpha = 1.0f;
        }else {
            
            // Hide Desc bar.
            self.l_uiview_description.hidden = YES;
        }
        
    }else { // Portrait mode.
        
        [self.uiview_landscape removeFromSuperview];
        
        [self.p_scroll_image_ringtone setContentSize:CGSizeMake(960, 233)];
        self.p_scroll_image_ringtone.delegate = self;
        self.p_scroll_image_ringtone.scrollEnabled = YES;
        self.p_scroll_image_ringtone.pagingEnabled = YES;
        // Set ringtone desc label on landscape mode.

        
        // Set ringtone image on Portrait mode.
        UIImage *image;
        if (m_firstToSelRingBtn) {
            image = [UIImage imageNamed: @"introImage"];
            
            // Hide selectedDisplayImageView.
            UIImageView *imgSelectedView = (UIImageView *)[self.view viewWithTag:TAG_SELECTED_VIEW];
            imgSelectedView.hidden = YES;
            
        }else {
            image = [UIImage imageNamed: m_ringtoneImageName];
            
            // Display selectedDisplayImageView
            UIImageView *imgSelectedView = (UIImageView *)[self.view viewWithTag:TAG_SELECTED_VIEW];
            UIButton *selectedRingBtn = (UIButton*)[self.view viewWithTag:m_selectedTag];
            [imgSelectedView setFrame:CGRectMake((selectedRingBtn.frame.origin.x + selectedRingBtn.frame.size.width/4), (selectedRingBtn.frame.origin.y + selectedRingBtn.frame.size.height/4), imgSelectedView.frame.size.width, imgSelectedView.frame.size.height)];
            imgSelectedView.hidden = NO;
        }
        
        //UIImageView *imageView = (UIImageView*)[self.uiview_portrait viewWithTag:100];
        UIImageView *imageView = (UIImageView*)[self.view viewWithTag:100];
        [imageView setImage:image];
        //[image release];
        
        m_rotate = YES;
        m_deviceState = DEVICESTATE_PORTRAIT;
        
        // Set the Green Alert/Tone category.
        if ((1000 < m_selectedTag) && (m_selectedTag < 1050)) { // GreenAlert.
            
            UILabel *categoryLabel = (UILabel*)[self.view viewWithTag:301];
            categoryLabel.textColor = [UIColor yellowColor];
            categoryLabel.text = @"GreenAlert";
            
        }else if((2000 < m_selectedTag) && (m_selectedTag < 2050)) { // GreenTone.
            
            UILabel *categoryLabel = (UILabel*)[self.view viewWithTag:301];
            categoryLabel.textColor = [UIColor yellowColor];
            categoryLabel.text = @"GreenTone";
        }
        
        NSString *strKey = [NSString stringWithFormat:@"%d", m_selectedTag];
        NSString *selectedSoundName = (NSString *)[m_mapDic objectForKey:strKey];
        UILabel *titleLabel = (UILabel*)[self.view viewWithTag:300];
        titleLabel.text = selectedSoundName;
        
        // Show/Hide the intro bar.
        if (m_showIntroBar) {
            
            // Show the intro bar.
            self.p_uiview_collapsableIntro.alpha = 1.0f;
            self.p_uiview_collapsableIntro.hidden = NO;
        }else {
            
            // Hide the intro bar.
            self.p_uiview_collapsableIntro.hidden = YES;
        }
        
        // Show/Hide the install bar.
        if (m_showInstallBar) {
            m_showInstallBar = NO;
        }        
        if (m_showInstallBar) {
            
            // Show the install background image and install button.
            self.p_img_install_confirm.hidden = NO;
            self.p_btn_install.hidden = NO;
        }else {
            
            // Hide the install background image and install button.
            self.p_img_install_confirm.hidden = YES;
            self.p_btn_install.hidden = YES;
        }
        
        // Show/Hide the menu bar.
        if (m_showMenuBar) {
            
            // Show Menu bar
            self.p_uiview_menu.hidden = NO;
            m_showDescriptionBar = YES;
        }else {
            
            // Hide Menu bar
            self.p_uiview_menu.hidden = YES;
        }
        
        // Show/Hide the description bar.
        if (m_showDescriptionBar) {
            
            // Show Desc bar.
            self.p_uiview_description.hidden = NO;
            self.p_uiview_description.alpha = 1.0f;
        }else {
        
            // Hide Desc bar.
            self.p_uiview_description.hidden = YES;
            self.p_uiview_description.alpha = 1.0f;
        }       

    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [self.p_scroll_image_ringtone release];
    [self.p_img_ringimage release];
    [self.p_btn_play release];
    [self.p_btn_set release];
    [self.p_btn_gnSlideShow release];
    [self.l_scroll_image_ringtone release];
    [self.l_scroll_image_ringtone release];
    [self.l_img_ringimage release];
    [self.l_label_ringdesc release];
    [self.p_label_ringdesc release];
    [self.l_btn_play release];
    [self.l_btn_set release];
    [self.l_btn_gnSlideShow release];
    [self.l_btn_11 release];
    [self.l_btn_set release];
    [self.l_btn_gnSlideShow release];    
    [_uiview_landscape release];
    [_p_img_ringImage1 release];
    [_view_activity release];
    [_p_img_install_confirm release];
    [_p_btn_install release];
    [_l_img_install_confirm release];
    [_l_btn_install release];
    [_p_uiview_collapsableIntro release];
    [_l_uiview_collapsableIntro release];
    [_p_uiview_menu release];
    [_l_uiview_menu release];
    [_p_uiview_description release];
    [_l_uiview_description release];
    [super dealloc];
}

// Reproduce ringtone sound.
- (IBAction)click_p_btnPlay:(id)sender {
    
    [Flurry logEvent:@"PLAYING_GREENTONES"];
    
    if (m_playingNow) { // Currently playing
        
        // Stop playing.
        m_playingNow = false;
        [soundMgr stopBackgroundMusic];
        
        // Change the image of pause button to play.
        if ( [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown )
        {
            [self.p_btn_play setImage:[UIImage imageNamed:@"play@2x.png"] forState:UIControlStateNormal];
            
        }else if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft){
            
            [self.l_btn_play setImage:[UIImage imageNamed:@"play@2x.png"] forState:UIControlStateNormal];
        }else {
            
            [self.p_btn_play setImage:[UIImage imageNamed:@"play@2x.png"] forState:UIControlStateNormal];
        }
        
    }else {

        if(m_selectedSourceSoundName == nil) {
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please select a ring tone sound!!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];        
            return;        
        }
    
        // Change the image of play button to pause.
        if ( [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown )
        {
            [self.p_btn_play setImage:[UIImage imageNamed:@"Pause@2x.png"] forState:UIControlStateNormal];
        
        }else if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft){
        
            [self.l_btn_play setImage:[UIImage imageNamed:@"Pause@2x.png"] forState:UIControlStateNormal];
        }else {
        
            [self.p_btn_play setImage:[UIImage imageNamed:@"Pause@2x.png"] forState:UIControlStateNormal];
        }
    
        // Play sound.
        m_playingNow = true;
        [soundMgr playBackgroundMusic:m_selectedSourceSoundName];
    }
    
}

- (void) notifyEndOfPlaying {
    
    m_playingNow = false;
    
    // Change the image of pause button to play.
    if ( [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown )
    {
        [self.p_btn_play setImage:[UIImage imageNamed:@"play@2x.png"] forState:UIControlStateNormal];
        
    }else if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft){
        
        [self.l_btn_play setImage:[UIImage imageNamed:@"play@2x.png"] forState:UIControlStateNormal];
    }else {
        
        [self.p_btn_play setImage:[UIImage imageNamed:@"play@2x.png"] forState:UIControlStateNormal];
    }
    
}

- (IBAction)click_p_btnSet:(id)sender {
    
    [Flurry logEvent:@"SETTING_GREENTONES"];
    
    if (m_showInstallBar) {
        
        if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown )
        {
            // Hide the descrition bar.
            self.p_uiview_description.hidden = NO;
            m_showDescriptionBar = YES;
            
            // Display the install background image and install button.
            self.p_img_install_confirm.hidden = YES;
            self.p_btn_install.hidden = YES;
        }else if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft){
            
            // Hide the descrition bar.
            self.l_uiview_description.hidden = NO;
            m_showDescriptionBar = YES;
            
            // Display the install background image and install button.
            self.l_img_install_confirm.hidden = YES;
            self.l_btn_install.hidden = YES;
        }else {
            
            // Hide the descrition bar.
            self.p_uiview_description.hidden = NO;
            m_showDescriptionBar = YES;
            
            // Display the install background image and install button.
            self.p_img_install_confirm.hidden = YES;
            self.p_btn_install.hidden = YES;

        }
        m_showInstallBar = NO;
        
        return;

    }
    
    if(m_selectedSourceSoundName == nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please select a ring tone sound!!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];        
        return;
    }              
    
    
    // Instruction to show the install view.
    m_showInstallBar = YES;
    if ( [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown )
    {
        // Hide the descrition bar.
        self.p_uiview_description.hidden = YES;
        m_showDescriptionBar = NO;
        
        // Display the install background image and install button.
        self.p_img_install_confirm.hidden = NO;
        self.p_btn_install.hidden = NO;
    }else if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft){
        
        // Hide the descrition bar.
        self.l_uiview_description.hidden = YES;
        m_showDescriptionBar = NO;
        
        // Display the install background image and install button.
        self.l_img_install_confirm.hidden = NO;
        self.l_btn_install.hidden = NO;
    }else {
        
        // Hide the descrition bar.
        self.p_uiview_description.hidden = YES;
        m_showDescriptionBar = NO;
        
        // Display the install background image and install button.
        self.p_img_install_confirm.hidden = NO;
        self.p_btn_install.hidden = NO;
        
    }
    
    // Convert mp3 to m4a.
    [self saveSoundFileToM4A];  
    
}

- (IBAction)click_btnInstall:(id)sender {
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    
    NSString *strKey = [NSString stringWithFormat:@"%d", m_selectedTag];
    NSString *selectedSoundName = (NSString *)[m_mapDic objectForKey:strKey];
    NSString *changedSoundName = [selectedSoundName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *convertedM4AFileName = [NSString stringWithFormat:@"%@.m4r",changedSoundName];
    //NSString *convertedM4AFileName = @"saved qw.m4r";
    NSString *exportPath = [[documentsDirectoryPath stringByAppendingPathComponent:convertedM4AFileName] retain];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
    {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        [controller setMailComposeDelegate:self];
        NSData *attachData = [NSData dataWithContentsOfFile:exportPath];
        NSString* body = [NSString stringWithFormat:@"%@\n", @"Ringtone attached."];
        body = [body stringByAppendingString:[NSString stringWithFormat:@"GreenTones by GreenNoise, spreading the voice of nature!\nTo install this GreenTone onto your Iphone;open the Ringtone with iTunes and sync with your iPhone.\n For step by step instructions please visit : http://greennoise.cr/gnstore/greentones."]];
        [controller setMessageBody:body isHTML:NO];
        //[controller addAttachmentData:attachData mimeType:[self fileMIMEType:m_convertedM4AFileName] fileName:m_convertedM4AFileName];
        [controller addAttachmentData:attachData mimeType:[self fileMIMEType:convertedM4AFileName] fileName:convertedM4AFileName];
        
        [self presentModalViewController:controller animated:YES];
        [controller release];
    }

}

- (NSString*) fileMIMEType:(NSString*) file
{
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[file pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    return [(NSString *)MIMEType autorelease];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    // Delete the previous target file.
    NSLog(@"%@", self.m_prevTargetPath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:self.m_prevTargetPath error:nil];
    
    m_showInstallBar = NO;
    m_showDescriptionBar = YES;
    m_showMenuBar = YES;
	[self dismissModalViewControllerAnimated:YES];
    
	return;
}

- (IBAction)click_p_btnGNSlide:(id)sender {
    
     [Flurry logEvent:@"VISITING_GN_PROJECT"];   
    //Detect 4 inch retina
    AboutViewController *aboutViewController;
#if 1
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) { // Iphone5        
        aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController_iphone5" bundle:nil];
        
    }else { // Iphone4        
        aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController_iphone4" bundle:nil];
        
    }
#else
    aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController_iphone4" bundle:nil];
    
#endif
    
    [self presentModalViewController:aboutViewController animated:YES];
    
}

- (IBAction)click_p_btnShare:(id)sender {
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) { // Landscape mode.
        
        [UIView animateWithDuration:1.0 animations:^{
            self.l_uiview_collapsableIntro.alpha = 0.0;
        }];
        
        
    }else {
        
        [UIView animateWithDuration:1.0 animations:^{
            self.p_uiview_collapsableIntro.alpha = 0.0;
        }];        
    }
    m_showIntroBar = NO;
    
}

- (IBAction)click_p_btnDesCollapsable:(id)sender {
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) { // Landscape mode.
        
        [UIView animateWithDuration:1.0 animations:^{
            self.l_uiview_description.alpha = 0.0;
        }];
        
        
    }else {
        
        [UIView animateWithDuration:1.0 animations:^{
            self.p_uiview_description.alpha = 0.0;
        }];
    }
    m_showDescriptionBar = NO;
    
}

- (IBAction)click_p_btn_ringtone:(id)sender {
       
    [Flurry logEvent:@"SELECTING_GREENTONES"];
    
    UIButton *selected_btn_ringtone = (UIButton*)sender;
    m_selectedTag = selected_btn_ringtone.tag;
    NSString *strKey = [NSString stringWithFormat:@"%d", m_selectedTag];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Get ring sound.
    m_selectedSourceSoundName = (NSString*)[delegate.m_twoDim_ringtone_sounds objectForKey:strKey];
    m_firstStopped = FALSE;
    NSLog(@"ringtone Sound is %@", m_selectedSourceSoundName);
    
    // Get ring image.
    m_ringtoneImageName = (NSString*)[delegate.m_twoDim_ringtone_images objectForKey:strKey];
    NSLog(@"ringtone Image is %@", m_ringtoneImageName);
       
    UIImage *image = [UIImage imageNamed: m_ringtoneImageName];
    
    if (m_deviceState == DEVICESTATE_HORIZONTAL) {
        
        UIImage *image = [UIImage imageNamed: m_ringtoneImageName];
        [self.p_img_ringimage setImage:image];
        
        UIImageView *imageView = (UIImageView*)[self.p_scroll_image_ringtone viewWithTag:TAG_SELECTED_VIEW];
        if (imageView != nil) {
            
            // Calculate the pos of selected imageview.
            CGRect rect = [selected_btn_ringtone frame];
            [imageView setFrame:CGRectMake((rect.origin.x + rect.size.width/4), (rect.origin.y + rect.size.height/4), imageView.frame.size.width, imageView.frame.size.height)];
            
        }
        
        imageView.hidden = NO;
        
        // Set the Green Alert/Tone category.
        if ((1000 < m_selectedTag) && (m_selectedTag < 1050)) { // GreenAlert.
            
            UILabel *categoryLabel = (UILabel*)[self.view viewWithTag:301];
            categoryLabel.textColor = [UIColor yellowColor];
            categoryLabel.text = @"GreenAlert";
            
        }else if((2000 < m_selectedTag) && (m_selectedTag < 2050)) { // GreenTone.
            
            UILabel *categoryLabel = (UILabel*)[self.view viewWithTag:301];
            categoryLabel.textColor = [UIColor yellowColor];
            categoryLabel.text = @"GreenTone";            
        }
        
        // Set the name of the selected sound.
        NSString *selectedSoundName = (NSString *)[m_mapDic objectForKey:strKey];
        UILabel *titleLabel = (UILabel*)[self.view viewWithTag:300];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = [NSString stringWithFormat:@"  %@",selectedSoundName];
        
    }else if(m_deviceState == DEVICESTATE_PORTRAIT) {
        
        UIImageView* imageView = (UIImageView* )[self.view viewWithTag:TAG_IMAGE_DISPLAY_VIEW];
        //[self.p_img_ringImage1 setImage:image];
        [imageView setImage:image];
        
        //UIImageView *selectedimageView = (UIImageView*)[_uiview_portrait viewWithTag:TAG_SELECTED_VIEW];
        UIImageView *selectedimageView = (UIImageView*)[self.view viewWithTag:TAG_SELECTED_VIEW];
        if (selectedimageView != nil) {
            
            // Calculate the pos of selected imageview.
            CGRect rect = [selected_btn_ringtone frame];
            [selectedimageView setFrame:CGRectMake((rect.origin.x + rect.size.width/4), (rect.origin.y + rect.size.height/4), selectedimageView.frame.size.width, selectedimageView.frame.size.height)];
            
        }
        selectedimageView.hidden = NO;
        
        // Set the Green Alert/Tone category.
        if ((1000 < m_selectedTag) && (m_selectedTag < 1050)) { // GreenAlert.
            
            UILabel *categoryLabel = (UILabel*)[self.view viewWithTag:301];
            categoryLabel.textColor = [UIColor yellowColor];
            categoryLabel.text = @"GreenAlert";
            
        }else if((2000 < m_selectedTag) && (m_selectedTag < 2050)) { // GreenTone.
            
            UILabel *categoryLabel = (UILabel*)[self.view viewWithTag:301];
            categoryLabel.textColor = [UIColor yellowColor];
            categoryLabel.text = @"GreenTone";            
        }
        
        // Set the name of the selected sound.
        NSString *selectedSoundName = (NSString *)[m_mapDic objectForKey:strKey];
        UILabel *titleLabel = (UILabel*)[self.view viewWithTag:300];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = [NSString stringWithFormat:@"  %@",selectedSoundName];
        
    }else if(m_deviceState == DEVICESTATE_LANDSCAPE) {
        
        UIImageView* imageView = (UIImageView* )[_uiview_landscape viewWithTag:TAG_IMAGE_DISPLAY_VIEW];
        //[self.l_img_ringimage setImage:image];
        [imageView setImage:image];
        
        UIImageView *selectedimageView = (UIImageView*)[_uiview_landscape viewWithTag:TAG_SELECTED_VIEW];
        if (selectedimageView != nil) {
            
            // Calculate the pos of selected imageview.
            CGRect rect = [selected_btn_ringtone frame];
            [selectedimageView setFrame:CGRectMake((rect.origin.x + rect.size.width/4), (rect.origin.y + rect.size.height/4), selectedimageView.frame.size.width, selectedimageView.frame.size.height)];
            
        }
        selectedimageView.hidden = NO;
        
        // Set the Green Alert/Tone category.
        if ((1000 < m_selectedTag) && (m_selectedTag < 1050)) { // GreenAlert.
            
            UILabel *categoryLabel = (UILabel*)[_uiview_landscape viewWithTag:301];
            categoryLabel.textColor = [UIColor yellowColor];
            categoryLabel.text = @"GreenAlert";
            
        }else if((2000 < m_selectedTag) && (m_selectedTag < 2050)) { // GreenTone.
            
            UILabel *categoryLabel = (UILabel*)[_uiview_landscape viewWithTag:301];
            categoryLabel.textColor = [UIColor yellowColor];
            categoryLabel.text = @"GreenTone";            
        }
        
        // Set the name of the selected sound.
        NSString *selectedSoundName = (NSString *)[m_mapDic objectForKey:strKey];
        UILabel *titleLabel = (UILabel*)[_uiview_landscape viewWithTag:300];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = [NSString stringWithFormat:@"  %@",selectedSoundName];
    }
   
    // Hide the introduction bar.
    if (m_showIntroBar) {
        
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) { // Landscape mode.
        
            [UIView animateWithDuration:1.0 animations:^{
                self.l_uiview_collapsableIntro.alpha = 0.0;
            }];        
        
        }else if ( [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown ){
        
            [UIView animateWithDuration:1.0 animations:^{
                self.p_uiview_collapsableIntro.alpha = 0.0;
            }];
        }else { // Portrait on the ground.
            
            [UIView animateWithDuration:1.0 animations:^{
                self.p_uiview_collapsableIntro.alpha = 0.0;
            }];
        }
        m_showIntroBar = NO;
    }
    
    // Show the menu bar.
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) { // Landscape mode.
        
        [UIView animateWithDuration:0.5 animations:^{
            self.l_uiview_menu.hidden = NO;
            self.l_uiview_menu.alpha = 1.0;
        }];        
        
    }else if ( [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown ){
        
        [UIView animateWithDuration:0.5 animations:^{
            self.p_uiview_menu.hidden = NO;
            self.p_uiview_menu.alpha = 1.0;
        }];
    }else { // Portrait on the ground.
        
        [UIView animateWithDuration:0.5 animations:^{
            self.p_uiview_menu.hidden = NO;
            self.p_uiview_menu.alpha = 1.0;
        }];
    }
    m_showMenuBar = YES;
    
    // Show/Hide the Tone/Alert description bar.
    if (m_prevSelectedTag == m_selectedTag) {
        
        if (m_showDescriptionBar) { // Hide
        
            if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) { // Landscape mode.
            
                [UIView animateWithDuration:0.5 animations:^{                
                    self.l_uiview_description.alpha = 0.0;
                    self.l_uiview_description.hidden = YES;
                }];
            
            }else if ( [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown ){
            
                [UIView animateWithDuration:0.5 animations:^{
                    self.p_uiview_description.alpha = 0.0;
                    self.p_uiview_description.hidden = YES;
                }];
                
            }else { // Portrait on the ground.
                
                [UIView animateWithDuration:0.5 animations:^{
                    self.p_uiview_description.alpha = 0.0;
                    self.p_uiview_description.hidden = YES;
                }];
            }
            m_showDescriptionBar = NO;            
        
        }else { // Show
            if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) { // Landscape mode.
        
                [UIView animateWithDuration:0.5 animations:^{
                    self.l_uiview_description.hidden = NO;
                    self.l_uiview_description.alpha = 1.0;
                }];
        
            }else if ( [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown ){
        
                [UIView animateWithDuration:0.5 animations:^{
                    self.p_uiview_description.hidden = NO;
                    self.p_uiview_description.alpha = 1.0;
                }];
                m_showDescriptionBar = YES;
            }else {// Portrait on the ground.
                
                [UIView animateWithDuration:0.5 animations:^{
                    self.p_uiview_description.hidden = NO;
                    self.p_uiview_description.alpha = 1.0;
                }];
            }
        }
    }else {
        
        // Show
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) { // Landscape mode.
            
            [UIView animateWithDuration:0.5 animations:^{
                self.l_uiview_description.hidden = NO;
                self.l_uiview_description.alpha = 1.0;
            }];
            
        }else if ( [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown ){
            
            [UIView animateWithDuration:0.5 animations:^{
                self.p_uiview_description.hidden = NO;
                self.p_uiview_description.alpha = 1.0;
            }];
            
        }else { // Portrait on the ground.
            
            [UIView animateWithDuration:0.5 animations:^{
                self.p_uiview_description.hidden = NO;
                self.p_uiview_description.alpha = 1.0;
            }];
        }
        m_showDescriptionBar = YES;

    }
    m_prevSelectedTag = m_selectedTag;
    
    // Convert mp3 to m4a.
    //[self saveSoundFileToM4A];
    
    // Check if the install bar showed.
    if (m_showInstallBar) {
        
        if ( [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown ) // Portrait on the hand.
        {       
            // Hide the install background image and install button.
            self.p_img_install_confirm.hidden = YES;
            self.p_btn_install.hidden = YES;
            
        }else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft){ // Landscape on the hand.
        
            // Hide the install background image and install button.
            self.l_img_install_confirm.hidden = YES;
            self.l_btn_install.hidden = YES;

        }else { // Portrait on the ground.
            
            // Hide the install background image and install button.
            self.p_img_install_confirm.hidden = YES;
            self.p_btn_install.hidden = YES;
        }
        m_showInstallBar = NO;
    }
    
    m_firstToSelRingBtn = NO;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    if ([touch view] == self.p_img_ringimage) {
        
        // Introduction bar.
        if (m_showIntroBar) {
                        
            // Disappear.
            [UIView animateWithDuration:0.5 animations:^{
                self.p_uiview_collapsableIntro.alpha = 0.0;
                self.p_uiview_collapsableIntro.hidden = YES;
            }];
            
            m_showIntroBar = NO;
            
        }        
        
        if(m_selectedSourceSoundName == nil)
            return;
        
        // Description bar.
        if (m_showDescriptionBar) { // The description bar already appeared.
            
            // Disappear.
            [UIView animateWithDuration:0.5 animations:^{
                self.p_uiview_description.alpha = 0.0;
                self.p_uiview_description.hidden = YES;
            }];
            m_showDescriptionBar = NO;
            
        }else { // The description bar already disappeared.
            
            // Let appear.
            [UIView animateWithDuration:0.5 animations:^{
                self.p_uiview_description.hidden = NO;
                self.p_uiview_description.alpha = 1.0;
            }];
            m_showDescriptionBar = YES;
        }
        
    }else if([touch view] == self.l_img_ringimage) {
        
        // Introduction bar.
        if (m_showIntroBar) {
            
            // Disappear.
            [UIView animateWithDuration:0.5 animations:^{
                self.l_uiview_collapsableIntro.alpha = 0.0;
                self.l_uiview_collapsableIntro.hidden = YES;
            }];
            
            m_showIntroBar = NO;
            
        }
        
        if(m_selectedSourceSoundName == nil)
            return;        
        
        // Description bar.
        if (m_showDescriptionBar) { // The description bar already appeared.
            
            // Disappear.
            [UIView animateWithDuration:0.5 animations:^{              
                self.l_uiview_description.alpha = 0.0;
                self.l_uiview_description.hidden = YES;
            }];
            m_showDescriptionBar = NO;
            
        }else { // The description bar already disappeared.
            
            // Appear
            [UIView animateWithDuration:0.5 animations:^{
                self.l_uiview_description.hidden = NO;
                self.l_uiview_description.alpha = 1.0;
            }];
            m_showDescriptionBar = YES;
        }
        
    }
}

- (void)exportAssetAsSourceFormat:(NSString *)strSong {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSURL *soundUrl = [NSURL fileURLWithPath:
                       [NSString stringWithFormat:@"%@/%@",
                        [[NSBundle mainBundle] resourcePath],strSong]];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:soundUrl options:nil];
    
    // JP
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                           initWithAsset:songAsset
                                           presetName:AVAssetExportPresetPassthrough];
    
    NSArray *tracks = [songAsset tracksWithMediaType:AVMediaTypeAudio];
    AVAssetTrack *track = [tracks objectAtIndex:0];
    id desc = [track.formatDescriptions objectAtIndex:0];
    const AudioStreamBasicDescription *audioDesc = CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)desc);
    FourCharCode formatID = audioDesc->mFormatID;
    
    //exportAudioMix.inputParameters = [NSArray arrayWithObject:exportAudioMixInputParameters];
    //exportSession.audioMix = exportAudioMix;
    
    NSString *fileType = nil;
    NSString *ex = nil;
    
    switch (formatID) {
            
        case kAudioFormatLinearPCM:
        {
            UInt32 flags = audioDesc->mFormatFlags;
            if (flags & kAudioFormatFlagIsBigEndian) {
                fileType = @"public.aiff-audio";
                ex = @"aif";
            } else {
                fileType = @"com.microsoft.waveform-audio";
                ex = @"wav";
            }
        }
            break;
            
        case kAudioFormatMPEGLayer3:
            fileType = @"com.apple.quicktime-movie";
            ex = @"mp3";
            break;
            
        case kAudioFormatMPEG4AAC:
            fileType = @"com.apple.m4a-audio";
            ex = @"m4a";
            break;
            
        case kAudioFormatAppleLossless:
            fileType = @"com.apple.m4a-audio";
            ex = @"m4a";
            break;
            
        default:
            break;
    }
    
    exportSession.outputFileType = fileType;
    
    NSString *exportPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[EXPORT_NAME stringByAppendingPathExtension:ex]] retain];
	if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
		[[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
	}
    exportSession.outputURL = [NSURL fileURLWithPath:exportPath];
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"export session completed");
            //return YES;
            [self performSelectorOnMainThread:@selector(gotoMainView:)
                                   withObject:[EXPORT_NAME stringByAppendingPathExtension:ex]
                                waitUntilDone:NO];
        } else {
            NSLog(@"export session error");
            //return NO;
        }
        
        [exportSession release];
    }];
    
    [pool release];
}



- (IBAction)click_l_btnSet:(id)sender {
    
    // Convert the selected mp2 file and send to email.
    
}

- (IBAction)click_l_btnGNSlide:(id)sender {
    
    
}

/********************************Auto Rotation*****************************************/

- (BOOL) shouldAutorotate {
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if ( toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) // Portrait on the hand.
    {
        [self.uiview_landscape removeFromSuperview];
        
        UIScrollView *sv = (UIScrollView*)[self.view viewWithTag:2];
        
        [sv setContentSize:CGSizeMake(640, 233)];
        sv.delegate = self;
        sv.scrollEnabled = YES;
        sv.pagingEnabled = YES;
        
        // Set ringtone image on Portrait mode.
        UIImage *image;
        if (m_firstToSelRingBtn) {
            image = [UIImage imageNamed: @"introImage"];
            
            // Hide selectedDisplayImageView.
            UIImageView *imgSelectedView = (UIImageView *)[self.view viewWithTag:TAG_SELECTED_VIEW];
            imgSelectedView.hidden = YES;            
            
            // Show/Hide the intro bar.
            if (m_showIntroBar) {
                
                // Show the intro bar.
                self.p_uiview_collapsableIntro.alpha = 1.0f;
                self.p_uiview_collapsableIntro.hidden = NO;
            }else {
                
                // Hide the intro bar.
                self.p_uiview_collapsableIntro.hidden = YES;
            }            
            
            // Hide Menu bar
            self.p_uiview_menu.hidden = YES;
            
            // Hide Desc bar.
            self.p_uiview_description.hidden = YES;
            
            
            
        }else {           
            
            // Hide Intro Description View.
            self.p_uiview_collapsableIntro.hidden = YES;            
            
            // Show Menu bar
            self.p_uiview_menu.hidden = NO;            
            
            // Show Desc bar.
            if (m_showDescriptionBar) {
                self.p_uiview_description.hidden = NO;
                self.p_uiview_description.alpha = 1.0f;
            }else {
                self.p_uiview_description.hidden = YES;
                self.p_uiview_description.alpha = 0.0f;
            }
            
            // Show/Hide Install Bar
            if (m_showInstallBar) {
                // Display the install background image and install button.
                self.p_img_install_confirm.hidden = NO;
                self.p_btn_install.hidden = NO;
            }else {
                // Hide the install background image and install button.
                self.p_img_install_confirm.hidden = YES;
                self.p_btn_install.hidden = YES;                
            }
            
            image = [UIImage imageNamed: m_ringtoneImageName];
            
            // Display selectedDisplayImageView
            UIImageView *imgSelectedView = (UIImageView *)[self.view viewWithTag:TAG_SELECTED_VIEW];
            UIButton *selectedRingBtn = (UIButton*)[self.view viewWithTag:m_selectedTag];
            [imgSelectedView setFrame:CGRectMake((selectedRingBtn.frame.origin.x + selectedRingBtn.frame.size.width/4), (selectedRingBtn.frame.origin.y + selectedRingBtn.frame.size.height/4), imgSelectedView.frame.size.width, imgSelectedView.frame.size.height)];
            imgSelectedView.hidden = NO;
        }
        
        //UIImageView *imageView = (UIImageView*)[self.uiview_portrait viewWithTag:100];
        UIImageView *imageView = (UIImageView*)[self.view viewWithTag:100];
        [imageView setImage:image];
        //[image release];
        
        m_rotate = YES;
        m_deviceState = DEVICESTATE_PORTRAIT;
        
        // Set the Green Alert/Tone category.
        if ((1000 < m_selectedTag) && (m_selectedTag < 1050)) { // GreenAlert.
            
            UILabel *categoryLabel = (UILabel*)[self.view viewWithTag:301];
            categoryLabel.textColor = [UIColor yellowColor];
            categoryLabel.text = @"GreenAlert";
            
        }else if((2000 < m_selectedTag) && (m_selectedTag < 2050)) { // GreenTone.
            
            UILabel *categoryLabel = (UILabel*)[self.view viewWithTag:301];
            categoryLabel.textColor = [UIColor yellowColor];
            categoryLabel.text = @"GreenTone";
            
        }
        
        // Set the title of ringtone name Label
        NSString *strKey = [NSString stringWithFormat:@"%d", m_selectedTag];
        NSString *selectedSoundName = (NSString *)[m_mapDic objectForKey:strKey];
        UILabel *titleLabel = (UILabel*)[self.view viewWithTag:300];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = [NSString stringWithFormat:@"  %@",selectedSoundName];
        
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight ) // Landscape on the hand.
    {
        //[self.uiview_portrait removeFromSuperview];
        
        [self.l_scroll_image_ringtone setContentSize:CGSizeMake(239, 960)];
        self.l_scroll_image_ringtone.delegate = self;
        self.l_scroll_image_ringtone.scrollEnabled = YES;
        self.l_scroll_image_ringtone.pagingEnabled = YES;
        
        // Set ringtone image on Portrait mode.
        UIImage *image;
        if (m_firstToSelRingBtn) {
            image = [UIImage imageNamed: @"introImage"];
            
            // Hide selectedImageView.
            UIImageView *imgSelectedView = (UIImageView *)[self.uiview_landscape viewWithTag:TAG_SELECTED_VIEW];
            imgSelectedView.hidden = YES;
            
            // Show/Hide the intro bar.
            if (m_showIntroBar) {
                
                // Show the intro bar.
                self.l_uiview_collapsableIntro.alpha = 1.0f;
                self.l_uiview_collapsableIntro.hidden = NO;
            }else {
                
                // Hide the intro bar.
                self.l_uiview_collapsableIntro.hidden = YES;
            }
            
            // Hide Menu bar
            self.l_uiview_menu.hidden = YES;
            
            // Hide Desc bar.
            self.l_uiview_description.hidden = YES;
            
        }else {
            
            // Hide Intro Description View.
            self.l_uiview_collapsableIntro.hidden = YES;
            
            // Show Menu bar
            self.l_uiview_menu.hidden = NO;
            
            // Show Desc bar.
            if (m_showDescriptionBar) {
                self.l_uiview_description.hidden = NO;
                self.l_uiview_description.alpha = 1.0f;
            }else {
                self.l_uiview_description.hidden = YES;
                self.l_uiview_description.alpha = 0.0f;
            }
            
            // Show/Hide Install Bar
            if (m_showInstallBar) {
                // Display the install background image and install button.
                self.l_img_install_confirm.hidden = NO;
                self.l_btn_install.hidden = NO;
            }else {
                // Hide the install background image and install button.
                self.l_img_install_confirm.hidden = YES;
                self.l_btn_install.hidden = YES;
            }
            
            image = [UIImage imageNamed: m_ringtoneImageName];
            
            // Display selectedDisplayImageView
            UIImageView *imgSelectedView = (UIImageView *)[self.uiview_landscape viewWithTag:TAG_SELECTED_VIEW];
            UIButton *selectedRingBtn = (UIButton*)[self.uiview_landscape viewWithTag:m_selectedTag];
            [imgSelectedView setFrame:CGRectMake((selectedRingBtn.frame.origin.x + selectedRingBtn.frame.size.width/4), (selectedRingBtn.frame.origin.y + selectedRingBtn.frame.size.height/4), imgSelectedView.frame.size.width, imgSelectedView.frame.size.height)];
            imgSelectedView.hidden = NO;
        }
        UIImageView *imageView = (UIImageView*)[self.uiview_landscape viewWithTag:100];
        [imageView setImage:image];
        //[image release];
        
        // Set the Green Alert/Tone category.
        if ((1000 < m_selectedTag) && (m_selectedTag < 1050)) { // GreenAlert.
            
            UILabel *categoryLabel = (UILabel*)[_uiview_landscape viewWithTag:301];
            categoryLabel.textColor = [UIColor yellowColor];
            categoryLabel.text = @"GreenAlert";
            
        }else if((2000 < m_selectedTag) && (m_selectedTag < 2050)) { // GreenTone.
            
            UILabel *categoryLabel = (UILabel*)[_uiview_landscape viewWithTag:301];
            categoryLabel.textColor = [UIColor yellowColor];
            categoryLabel.text = @"GreenTone";
            
        }
        
        // Set the title of ringtone name Label
        NSString *strKey = [NSString stringWithFormat:@"%d", m_selectedTag];
        NSString *selectedSoundName = (NSString *)[m_mapDic objectForKey:strKey];
        UILabel *titleLabel = (UILabel*)[_uiview_landscape viewWithTag:300];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = [NSString stringWithFormat:@"  %@",selectedSoundName];
        
        m_deviceState = DEVICESTATE_LANDSCAPE;
        
        [self.view addSubview:self.uiview_landscape];
        [self.view bringSubviewToFront:self.uiview_landscape];        
    
    }else { // Portrait on the ground.
        
        [self.uiview_landscape removeFromSuperview];
        
        UIScrollView *sv = (UIScrollView*)[self.view viewWithTag:2];
        
        [sv setContentSize:CGSizeMake(640, 233)];
        sv.delegate = self;
        sv.scrollEnabled = YES;
        sv.pagingEnabled = YES;
        
        // Set ringtone image on Portrait mode.
        UIImage *image;
        if (m_firstToSelRingBtn) {
            image = [UIImage imageNamed: @"introImage"];
            
            // Hide selectedDisplayImageView.
            UIImageView *imgSelectedView = (UIImageView *)[self.view viewWithTag:TAG_SELECTED_VIEW];
            imgSelectedView.hidden = YES;
            
            // Show/Hide the intro bar.
            if (m_showIntroBar) {
                
                // Show the intro bar.
                self.p_uiview_collapsableIntro.alpha = 1.0f;
                self.p_uiview_collapsableIntro.hidden = NO;
            }else {
                
                // Hide the intro bar.
                self.p_uiview_collapsableIntro.hidden = YES;
            }
            
            // Hide Menu bar
            self.p_uiview_menu.hidden = YES;
            
            // Hide Desc bar.
            self.p_uiview_description.hidden = YES;
            
            
            
        }else {
            
            // Hide Intro Description View.
            self.p_uiview_collapsableIntro.hidden = YES;
            
            // Show Menu bar
            self.p_uiview_menu.hidden = NO;
            
            // Show Desc bar.
            if (m_showDescriptionBar) {
                self.p_uiview_description.hidden = NO;
                self.p_uiview_description.alpha = 1.0f;
            }else {
                self.p_uiview_description.hidden = YES;
                self.p_uiview_description.alpha = 0.0f;
            }
            
            // Show/Hide Install Bar
            if (m_showInstallBar) {
                // Display the install background image and install button.
                self.p_img_install_confirm.hidden = NO;
                self.p_btn_install.hidden = NO;
            }else {
                // Hide the install background image and install button.
                self.p_img_install_confirm.hidden = YES;
                self.p_btn_install.hidden = YES;
            }
            
            image = [UIImage imageNamed: m_ringtoneImageName];
            
            // Display selectedDisplayImageView
            UIImageView *imgSelectedView = (UIImageView *)[self.view viewWithTag:TAG_SELECTED_VIEW];
            UIButton *selectedRingBtn = (UIButton*)[self.view viewWithTag:m_selectedTag];
            [imgSelectedView setFrame:CGRectMake((selectedRingBtn.frame.origin.x + selectedRingBtn.frame.size.width/4), (selectedRingBtn.frame.origin.y + selectedRingBtn.frame.size.height/4), imgSelectedView.frame.size.width, imgSelectedView.frame.size.height)];
            imgSelectedView.hidden = NO;
        }
        
        //UIImageView *imageView = (UIImageView*)[self.uiview_portrait viewWithTag:100];
        UIImageView *imageView = (UIImageView*)[self.view viewWithTag:100];
        [imageView setImage:image];
        //[image release];
        
        m_rotate = YES;
        m_deviceState = DEVICESTATE_PORTRAIT;
        
        // Set the Green Alert/Tone category.
        if ((1000 < m_selectedTag) && (m_selectedTag < 1050)) { // GreenAlert.
            
            UILabel *categoryLabel = (UILabel*)[self.view viewWithTag:301];
            categoryLabel.textColor = [UIColor yellowColor];
            categoryLabel.text = @"GreenAlert";
            
        }else if((2000 < m_selectedTag) && (m_selectedTag < 2050)) { // GreenTone.
            
            UILabel *categoryLabel = (UILabel*)[self.view viewWithTag:301];
            categoryLabel.textColor = [UIColor yellowColor];
            categoryLabel.text = @"GreenTone";
            
        }
        
        // Set the title of ringtone name Label
        NSString *strKey = [NSString stringWithFormat:@"%d", m_selectedTag];
        NSString *selectedSoundName = (NSString *)[m_mapDic objectForKey:strKey];
        UILabel *titleLabel = (UILabel*)[self.view viewWithTag:300];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = [NSString stringWithFormat:@"  %@",selectedSoundName];
        
    }
}


/****************************************************************************************************************
 
 Actions for converting to ring tone and saving.
 
 ****************************************************************************************************************/


- (void) saveSoundFileToM4A
{
    
    int nLengthTimeBack = m_nRingToneLengthTime;
    
    m_nSpeed = 1.0f;
    m_nPitch = 0.0f;
    
    //[self UnloadSound];
    
	CFURLRef sndFile = NULL;
    ExtAudioFileRef audioFile;
    SoundTouch soundTouch;
    CAStreamBasicDescription dataFormat;
    CAStreamBasicDescription outFormat;
    SInt64 nTotalFrames;
    SInt64 nPrevFrameOffset;
    
    // Initialize source file.
	try
    {
        //NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:currentFile] retain];
        NSString *filePath = [[NSBundle mainBundle] pathForResource: [m_selectedSourceSoundName stringByDeletingPathExtension]
                                                                  ofType: [m_selectedSourceSoundName pathExtension]];
        //NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:m_selectedSourceSoundName] retain];
		sndFile = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filePath, kCFURLPOSIXPathStyle, false);
		if (!sndFile) { printf("can't parse file path\n"); return; }
        
		XThrowIfError(ExtAudioFileOpenURL (sndFile, &audioFile), "can't open file");
        
        AudioConverterRef acRef;
        UInt32 acrsize = sizeof(AudioConverterRef);
        XThrowIfError( ExtAudioFileGetProperty(audioFile, kExtAudioFileProperty_AudioConverter, &acrsize, &acRef), "kExtAudioFileProperty_AudioConverter" );
        
        AudioConverterPrimeInfo primeInfo;
        UInt32 piSize = sizeof(AudioConverterPrimeInfo);
        OSStatus err = AudioConverterGetProperty( acRef, kAudioConverterPrimeInfo, &piSize, &primeInfo );
        if(err != kAudioConverterErr_PropertyNotSupported) // Only if decompressing
        {
            //          XThrowIfError(err, "kAudioConverterPrimeInfo");
        }
        
        //      XThrowIfError(ExtAudioFileSeek( mAudioFile, (SInt64)segmentStart + headerFrames ), "ExtAudioFileSeek");
        
		UInt32 size = sizeof(dataFormat);
		XThrowIfError(ExtAudioFileGetProperty(audioFile, kExtAudioFileProperty_FileDataFormat, &size, &dataFormat), "couldn't get file's data format");
        
        size = sizeof(nTotalFrames);
        XThrowIfError(ExtAudioFileGetProperty(audioFile, kExtAudioFileProperty_FileLengthFrames, &size, &nTotalFrames), "couldn't get file's length in frames");
        
        outFormat.mSampleRate = 44100.f;
        outFormat.mFormatID = kAudioFormatLinearPCM;       
        outFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;        
        outFormat.mBytesPerPacket = 4;
        outFormat.mFramesPerPacket = 1;
        outFormat.mBytesPerFrame = 4;
        outFormat.mChannelsPerFrame = 2;
        outFormat.mBitsPerChannel = 16;
        
        size = sizeof(outFormat);
        XThrowIfError( ExtAudioFileSetProperty(audioFile, kExtAudioFileProperty_ClientDataFormat, size, &outFormat), "ExtAudioFileSetProperty error" );
        
        soundTouch.setSampleRate( outFormat.mSampleRate );
        soundTouch.setChannels( outFormat.mChannelsPerFrame );
        
        soundTouch.setTempo( m_nSpeed );
        soundTouch.setPitch( 1.0f );
        soundTouch.setRate( 1.0f );
        soundTouch.setPitchSemiTones( (float)m_nPitch / 100.f );
        
        soundTouch.setSetting( SETTING_USE_QUICKSEEK, 1 );
        soundTouch.setSetting( SETTING_USE_AA_FILTER, 1 );
	}
	catch (CAXException e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
	}
	if (sndFile)
		CFRelease(sndFile);
    
    // Initialize target file.
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
#if 0
    NSRange end = [m_selectedSourceSoundName rangeOfString:@".mp3"];
    NSString *strTemp = [m_selectedSourceSoundName substringToIndex:end.location];
    NSString *selectedSoundName = (NSString *)[m_mapDic objectForKey:strTemp];
    if (end.location != NSNotFound) {
        //m_convertedM4AFileName = [NSString stringWithFormat:@"%@.m4r",m_];
        m_convertedM4AFileName = @"saved.m4r";
    }
#else
    
    NSString *strKey = [NSString stringWithFormat:@"%d", m_selectedTag];
    NSMutableString *selectedSoundName = [(NSString *)[m_mapDic objectForKey:strKey] copy];
    NSString *changedSoundName = [selectedSoundName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *convertedM4AFileName = [NSString stringWithFormat:@"%@.m4r",changedSoundName];    
    //[selectedSoundName replaceCharactersInRange:(NSRange) withString:<#(NSString *)#>];
    //NSString *convertedM4AFileName = [NSString stringWithFormat:@"%@.m4r",selectedSoundName];
    //NSString *convertedM4AFileName = @"saved qw.m4r";
    
#endif
    
    //NSString *targetPath = [[documentsDirectoryPath stringByAppendingPathComponent:convertedM4AFileName] retain];
    NSString *targetPath = [documentsDirectoryPath stringByAppendingPathComponent:convertedM4AFileName];
    self.m_prevTargetPath = [NSString stringWithString:targetPath];
    AudioFileID targetFile;
    
    AudioStreamBasicDescription encoderFormat;
    encoderFormat.mSampleRate = 44100.00;
    encoderFormat.mFormatID = kAudioFormatMPEG4AAC;
    encoderFormat.mFormatFlags  = kMPEG4Object_AAC_Main;
    encoderFormat.mFramesPerPacket = 1024;
    encoderFormat.mChannelsPerFrame = 2;
    encoderFormat.mBitsPerChannel  = 0;
    encoderFormat.mBytesPerPacket  = 0;
    encoderFormat.mBytesPerFrame  = 0;
    encoderFormat.mReserved   = 0;
	try {
		sndFile = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)targetPath, NULL);
		
		// create the audio file
		XThrowIfError(AudioFileCreateWithURL(sndFile, kAudioFileM4AType, &encoderFormat, kAudioFileFlags_EraseFile, &targetFile), "AudioFileCreateWithURL failed");        
		CFRelease(sndFile);
	}
	catch (CAXException &e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
	}
	catch (...) {
		fprintf(stderr, "An unknown error occurred\n");
	}
    
    // Wrap it in ExtAudioFile
    ExtAudioFileRef eafRef;
    OSStatus err = ExtAudioFileWrapAudioFileID(targetFile, YES, &eafRef);
    if (err != noErr) { NSLog(@"-[AudioFile convertWithDocument:] ExtAudioFileWrapAudioFileID() error %ld", err);}
    
    // Specify codec
    UInt32 codec = kAppleSoftwareAudioCodecManufacturer;
    err = ExtAudioFileSetProperty(eafRef, kExtAudioFileProperty_CodecManufacturer, sizeof(codec), &codec);
    if (err != noErr) { NSLog(@"-[AudioFile convertWithDocument:] ExtAudioFileSetProperty() error %ld", err); }
    
    // Set the client data format
    err = ExtAudioFileSetProperty( eafRef, kExtAudioFileProperty_ClientDataFormat, sizeof(AudioStreamBasicDescription), &outFormat );    
    if (err != noErr) { NSLog(@"-[AudioFile convertWithDocument:] ExtAudioFileSetProperty() error %ld", err); }
    
    AudioConverterRef converter;
    UInt32 n = sizeof (converter);
    err = ExtAudioFileGetProperty (eafRef, kExtAudioFileProperty_AudioConverter, &n, &converter);
    if (err != noErr) { NSLog(@"-[AudioFile convertWithDocument:] ExtAudioFileGetProperty() error %ld", err); }
    
    // Set quality
    UInt32 quality = 0x7F;//kAudioCodecQuality_Max;
    err = AudioConverterSetProperty(converter, kAudioConverterEncodeBitRate, sizeof (quality), &quality);
    
    // Set bit rate
    SInt32 bitRate = 96000;
    err = AudioConverterSetProperty(converter, kAudioConverterEncodeBitRate, sizeof (bitRate), &bitRate);
    if (err != noErr) { NSLog(@"-[AudioFile convertWithDocument:] AudioConverterSetProperty() error %ld", err); }
    
    n = 0;
    err = ExtAudioFileSetProperty (eafRef, kExtAudioFileProperty_ConverterConfig, sizeof (n), &n);
    if (err != noErr) { NSLog(@"-[AudioFile convertWithDocument:] ExtAudioFileSetProperty() error %ld", err); }
#if 0
    // Seek source file.
    if( nStartTime < 0 )
        nStartTime = 0;
    
    SInt64 duration = nTotalFrames / dataFormat.mSampleRate;
    
    if( nStartTime > duration )
        nStartTime = duration;
    
    SInt64 nNewSeekFramePos = nStartTime * dataFormat.mSampleRate;
    ExtAudioFileSeek( audioFile, nNewSeekFramePos );
    
    if( nLengthTime <= 0 )
        nLengthTime = 5;
    
    if( nStartTime + nLengthTime > duration )
        nLengthTime = duration - nStartTime;
    
    SInt64 nNewEndFramePos = (nStartTime + nLengthTime ) * dataFormat.mSampleRate;
#else
    SInt64 nNewSeekFramePos = 0;
    ExtAudioFileSeek( audioFile, nNewSeekFramePos );
    SInt64 nNewEndFramePos = m_nRingToneLengthTime * dataFormat.mSampleRate;
    
#endif
    //    SInt64 nNumPackets = 0;
    // loop.
    while( TRUE )
    {
        UInt32 nBufSize = 32768 / 4;
        UInt32 nNumFrames = nBufSize / outFormat.mBytesPerFrame;
        
        AudioBufferList fillBufList;
        fillBufList.mNumberBuffers = 1;
        fillBufList.mBuffers[0].mNumberChannels = outFormat.mChannelsPerFrame;
        fillBufList.mBuffers[0].mDataByteSize = nBufSize;
        fillBufList.mBuffers[0].mData = (void*)new char[32768];
        
        OSStatus result = ExtAudioFileRead( audioFile, &nNumFrames, &fillBufList );
        if (result)
            printf("ExtAudioFileRead failed: %d", (int)result);
        if (nNumFrames > 0)
        {
            SAMPLETYPE* pSamples = new SAMPLETYPE[nNumFrames * 2];
            SInt16* pBuffer = (SInt16*)fillBufList.mBuffers[0].mData;
            
#ifndef SOUNDTOUCH_INTEGER_SAMPLES
            double dScale = 1.0 / 32768.0;
            for( int nIndex = 0; nIndex < nNumFrames * 2; nIndex++ )
                pSamples[nIndex] = (float)(dScale * pBuffer[nIndex]);
#else
            for( int nIndex = 0; nIndex < nNumFrames * 2; nIndex++ )
                pSamples[nIndex] = pBuffer[nIndex];
#endif
            
            soundTouch.putSamples( pSamples, nNumFrames );
            int nRetSamples = 0;
            //            UInt32 nSampleSize = 0;
            fillBufList.mBuffers[0].mDataByteSize = 0;
            do
            {
                nRetSamples = soundTouch.receiveSamples( pSamples, nNumFrames );
                
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
                    
                    *pBuffer++ = (short)iTemp;
                }
#endif
                fillBufList.mBuffers[0].mDataByteSize += nRetSamples * 2 * sizeof(SInt16);
                
            } while (nRetSamples != 0);
            
            delete[] pSamples;
            
            
            UInt32 nFramesInPacket = fillBufList.mBuffers[0].mDataByteSize / ( 2 * sizeof(SInt16) );
            //            XThrowIfError(AudioFileWritePackets( targetFile, FALSE, nSampleSize, NULL/*&inPacketDesc*/, nNumPackets, &nFramesInPacket, (SInt16*)fillBufList.mBuffers[0].mData),
            //                      "AudioFileWritePackets failed");
            //            nNumPackets += nFramesInPacket;
            err = ExtAudioFileWrite (eafRef, nFramesInPacket, &fillBufList);
            
            delete[] (char*)fillBufList.mBuffers[0].mData;
        }
        
        // Check file position.
        SInt64 nFrameOffset = 0;
        ExtAudioFileTell( audioFile, &nFrameOffset );
        if( nFrameOffset >= nNewEndFramePos )
            break;
        
        if (nPrevFrameOffset == nFrameOffset) {
            break;
        }
        nPrevFrameOffset = nFrameOffset;
        
    }
    
    NSLog(@"1");
    // Unload source file.
    if (audioFile)
    {
        OSStatus error = ExtAudioFileDispose(audioFile);
        if (error)
            printf("ExtAudioFileDispose failed: %d", (int)error);
        audioFile = 0;
    }
    NSLog(@"2");
    
    // Close destination file.
	AudioFileClose(targetFile);
    
    NSLog(@"3");
    m_nRingToneLengthTime = nLengthTimeBack;
    
    //[self LoadSound];
    
    NSLog(@"4");
}



- (void)viewDidUnload {
    [self setP_img_ringImage1:nil];
    [self setView_activity:nil];
    [self setP_img_install_confirm:nil];
    [self setP_btn_install:nil];
    [self setL_img_install_confirm:nil];
    [self setL_btn_install:nil];
    [self setP_uiview_collapsableIntro:nil];
    [self setL_uiview_collapsableIntro:nil];
    [self setP_uiview_menu:nil];
    [self setL_uiview_menu:nil];
    [self setP_uiview_description:nil];
    [self setL_uiview_description:nil];
    [super viewDidUnload];
}
@end
