//
//  ViewController.h
//  medical-local
//
//  Created by Rose Jiang on 3/21/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "CMOpenALSoundManager.h"


enum DeviceState {
    DEVICESTATE_HORIZONTAL,
    DEVICESTATE_PORTRAIT,
    DEVICESTATE_LANDSCAPE
    
};

@class CMOpenALSoundManager;
@interface ViewController : UIViewController<UIScrollViewDelegate, MFMailComposeViewControllerDelegate, CMOpenALSoundManagerDelegate> {
    
    
    // Current rigntone names of sound and images.
    NSString *m_selectedSourceSoundName;
    NSString *m_ringtoneImageName;
    NSMutableString *m_convertedM4AFileName;

    Boolean  m_landscape;
    
    float    m_nSpeed;
    int      m_nPitch;
    
    //Stuffs for converting to ringtone.
    NSInteger m_nRingToneLengthTime;
    
    // Auto-rotate flag.
    BOOL      m_rotate;
    
    // First
    BOOL      m_firstToSelRingBtn;
    
    // Device current state.
    enum DeviceState m_deviceState;
    
    // The tag of selected ring button.
    NSInteger m_selectedTag;
    NSInteger m_prevSelectedTag;
    
    // The sound player.
    CMOpenALSoundManager *soundMgr;
    bool                  m_playingNow;
    
    // States variables.
    bool                  m_firstStopped;
    bool                  m_showDescriptionBar; // Yes : Show, NO : Hidden.
    bool                  m_showInstallBar; // Yes : Show, NO : Hidden.
    bool                  m_showMenuBar; // Yes : Show, NO : Hidden.
    bool                  m_showIntroBar; // Yes : Show, NO : Hidden.
    
    //
    NSString *m_prevTargetPath;
    
}

@property (nonatomic, retain) CMOpenALSoundManager *soundMgr;
@property(strong, nonatomic) NSDictionary *m_mapDic;
@property (nonatomic, retain) NSString *m_prevTargetPath;;

@property (retain, nonatomic) IBOutlet UIView *uiview_portrait;
@property (retain, nonatomic) IBOutlet UIView *uiview_landscape;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *view_activity;


/* Portrait mode */
@property (retain, nonatomic) IBOutlet UIScrollView *p_scroll_image_ringtone;
@property (retain, nonatomic) IBOutlet UIImageView *p_img_ringimage;
@property (retain, nonatomic) IBOutlet UIImageView *p_img_ringImage1;

@property (retain, nonatomic) IBOutlet UIView *p_uiview_description;
@property (retain, nonatomic) IBOutlet UILabel *p_label_ringdesc;

@property (retain, nonatomic) IBOutlet UIView *p_uiview_collapsableIntro;


@property (retain, nonatomic) IBOutlet UIImageView *p_img_install_confirm;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_install;

// Menu in portrait mode.
@property (retain, nonatomic) IBOutlet UIView *p_uiview_menu;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_play;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_set;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_gnSlideShow;

// Portrait mode each ringtones.
@property (retain, nonatomic) IBOutlet UIButton *p_btn_11;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_12;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_13;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_14;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_21;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_22;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_23;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_24;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_31;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_32;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_33;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_34;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_41;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_42;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_43;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_44;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_15;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_16;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_17;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_18;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_25;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_26;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_27;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_28;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_35;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_36;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_37;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_38;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_45;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_46;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_47;
@property (retain, nonatomic) IBOutlet UIButton *p_btn_48;

// Actions of each controls on portrait mode.
- (IBAction)click_p_btnPlay:(id)sender;
- (IBAction)click_p_btnSet:(id)sender;
- (IBAction)click_btnInstall:(id)sender;
- (IBAction)click_p_btnGNSlide:(id)sender;
- (IBAction)click_p_btnShare:(id)sender;
- (IBAction)click_p_btnDesCollapsable:(id)sender;


// Actions of each ringtone buttons on portrait mode.
- (IBAction)click_p_btn_ringtone:(id)sender;


/* LandScape mode */
@property (retain, nonatomic) IBOutlet UIScrollView *l_scroll_image_ringtone;
@property (retain, nonatomic) IBOutlet UIImageView *l_img_ringimage;


@property (retain, nonatomic) IBOutlet UIView *l_uiview_description;
@property (retain, nonatomic) IBOutlet UILabel *l_label_ringdesc;

@property (retain, nonatomic) IBOutlet UIImageView *l_img_install_confirm;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_install;
@property (retain, nonatomic) IBOutlet UIView *l_uiview_collapsableIntro;


// Menu
@property (retain, nonatomic) IBOutlet UIView *l_uiview_menu;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_play;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_set;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_gnSlideShow;

// LandScape mode each ringtones.
@property (retain, nonatomic) IBOutlet UIButton *l_btn_11;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_12;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_13;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_14;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_22;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_21;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_23;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_24;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_31;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_32;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_33;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_34;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_41;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_42;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_43;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_44;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_15;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_16;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_17;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_18;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_25;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_26;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_27;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_28;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_35;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_36;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_37;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_38;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_45;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_46;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_47;
@property (retain, nonatomic) IBOutlet UIButton *l_btn_48;


// Actions of each controls on landscape mode.
- (IBAction)click_l_btnPlay:(id)sender;
- (IBAction)click_l_btnSet:(id)sender;
- (IBAction)click_l_btnGNSlide:(id)sender;

// Functions related to play sound.
- (void) InitAudio;
- (void) LoadSound;
- (void) PlaySound;
- (void) StopSound:(BOOL)fPause;
- (void) UnloadSound;
- (void) UninitAudio;

@end
