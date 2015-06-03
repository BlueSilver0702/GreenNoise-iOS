//
//  AboutViewController.h
//  local-database
//
//  Created by Nam Hyok on 4/11/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController <UIScrollViewDelegate>


// Properties related to portrait.
@property (retain, nonatomic) IBOutlet UIScrollView *ui_portraitScroll;

// Properties related to landscape.
@property (retain, nonatomic) IBOutlet UIView *uiview_landscape;
@property (retain, nonatomic) IBOutlet UIScrollView *ui_landscapeScroll;

// Buttons.
@property (retain, nonatomic) IBOutlet UIButton *btn_website;
@property (retain, nonatomic) IBOutlet UIButton *btn_facebook;
@property (retain, nonatomic) IBOutlet UIButton *btn_instagram;

// Button actions.
- (IBAction)click_websiteBtn:(id)sender;
- (IBAction)click_facebookBtn:(id)sender;
- (IBAction)click_instagramBtn:(id)sender;
- (IBAction)click_closeBtn:(id)sender;


@end
