//
//  MCPagerView.m
//  MCPagerView
//
//  Created by Rose on 04/11/13.
//  Copyright Rose. All rights reserved.
//

#import "MCPagerView.h"

@implementation MCPagerView {
    NSMutableDictionary *_images;
    NSMutableArray *_pageViews;
}

@synthesize page = _page;
@synthesize pattern = _pattern;
@synthesize delegate = _delegate;

- (void)commonInit
{
    _page = 0;
    _pattern = @"";
    _images = [NSMutableDictionary dictionary];
    _pageViews = [NSMutableArray array];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)setPage:(NSInteger)page
{
    // Skip if delegate said "do not update"
    if ([_delegate respondsToSelector:@selector(pageView:shouldUpdateToPage:)] && ![_delegate pageView:self shouldUpdateToPage:page]) {
        return;
    }
    
    _page = page;
    [self setNeedsLayout];
    
    // Inform delegate of the update
    if ([_delegate respondsToSelector:@selector(pageView:didUpdateToPage:)]) {
        [_delegate pageView:self didUpdateToPage:page];
    }
    
    // Send update notification
    [[NSNotificationCenter defaultCenter] postNotificationName:MCPAGERVIEW_DID_UPDATE_NOTIFICATION object:self];
}

- (NSInteger)numberOfPages
{
    return _pattern.length;
}

- (void)tapped:(UITapGestureRecognizer *)recognizer
{
    self.page = [_pageViews indexOfObject:recognizer.view];
}

- (UIImageView *)imageViewForKey:(NSString *)key
{
    NSDictionary *imageData = [_images objectForKey:key];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[imageData objectForKey:@"normal"] highlightedImage:[imageData objectForKey:@"highlighted"]];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [imageView addGestureRecognizer:tgr];
    
    return imageView;
}

- (void)layoutSubviews
{
    [_pageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = obj;
        [view removeFromSuperview];
    }];
    [_pageViews removeAllObjects];
    
    NSInteger pages = self.numberOfPages;
    CGFloat xOffset = 0;
    for (int i=0; i<pages; i++) {
        NSString *key = [_pattern substringWithRange:NSMakeRange(i, 1)];
        UIImageView *imageView = [self imageViewForKey:key];
        
        CGRect frame = imageView.frame;
        frame.origin.x = xOffset;
        imageView.frame = frame;
        imageView.highlighted = (i == self.page);
        
        [self addSubview:imageView];
        [_pageViews addObject:imageView];
        
        xOffset = xOffset + frame.size.width;
    }
}

- (void)setImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage forKey:(NSString *)key
{
    NSDictionary *imageData = [NSDictionary dictionaryWithObjectsAndKeys:image, @"normal", highlightedImage, @"highlighted", nil];
    [_images setObject:imageData forKey:key];
    [self setNeedsLayout];
}

#if 0

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Scroll view
    for (int i=0; i<6; i++) {
        CGRect frame = CGRectMake(scrollView.frame.size.width * i,
                                  0,
                                  scrollView.frame.size.width,
                                  scrollView.frame.size.height);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:144.0];
        label.text = [NSString stringWithFormat:@"%d", i];
        
        [scrollView addSubview:label];
    }
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 6, scrollView.frame.size.height);
    
    scrollView.delegate = self;
#if 1
    // Pager
    [pagerView setImage:[UIImage imageNamed:@"a"]
       highlightedImage:[UIImage imageNamed:@"a-h"]
                 forKey:@"a"];
    [pagerView setImage:[UIImage imageNamed:@"b"]
       highlightedImage:[UIImage imageNamed:@"b-h"]
                 forKey:@"b"];
    [pagerView setImage:[UIImage imageNamed:@"c"]
       highlightedImage:[UIImage imageNamed:@"c-h"]
                 forKey:@"c"];
#endif
    [pagerView setPattern:@"abcabc"];
    
    pagerView.delegate = self;
}

- (void)updatePager
{
    pagerView.page = floorf(scrollView.contentOffset.x / scrollView.frame.size.width);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updatePager];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self updatePager];
    }
}

- (void)pageView:(MCPagerView *)pageView didUpdateToPage:(NSInteger)newPage
{
    CGPoint offset = CGPointMake(scrollView.frame.size.width * pagerView.page, 0);
    [scrollView setContentOffset:offset animated:YES];
}

- (void)viewDidUnload
{
    pagerView = nil;
    scrollView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    //if (isPortrait) { // Portrait mode.
    if ( [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown ) { // Portrait mode.
        
        UIImage *image = [UIImage imageNamed: m_ringtoneImageName];
        
        // Set ringtone image on Portrait mode.
        if (m_rotate) {
            UIImageView* imageView = (UIImageView* )[_uiview_portrait viewWithTag:100];
            //[self.p_img_ringImage1 setImage:image];
            [imageView setImage:image];
        }else {
            [self.p_img_ringimage setImage:image];
        }
        
        //[image release];
        
        // Set ringtone desc label on Portrait mode..
        
        
    }else if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) { // Landscape mode.
        
        UIImage *image = [UIImage imageNamed: m_ringtoneImageName];
        
        // Set ringtone image on Landscape mode.
        {
            UIImageView* imageView = (UIImageView* )[_uiview_landscape viewWithTag:100];
            //[self.l_img_ringimage setImage:image];
            [imageView setImage:image];
        }
        
        //[image release];
        
        // Set ringtone desc label on Landscape mode.
        
    } else {
        
        UIImage *image = [UIImage imageNamed: m_ringtoneImageName];
        
        if (m_deviceState == DEVICESTATE_HORIZONTAL) {
            UIImage *image = [UIImage imageNamed: m_ringtoneImageName];
            [self.p_img_ringimage setImage:image];
        }else if(m_deviceState == DEVICESTATE_PORTRAIT) {
            
            UIImageView* imageView = (UIImageView* )[_uiview_portrait viewWithTag:100];
            //[self.p_img_ringImage1 setImage:image];
            [imageView setImage:image];
            
        }else if(m_deviceState == DEVICESTATE_LANDSCAPE) {
            
            UIImageView* imageView = (UIImageView* )[_uiview_landscape viewWithTag:100];
            //[self.l_img_ringimage setImage:image];
            [imageView setImage:image];
        }
        
        
    }

    if(m_selectedSourceSoundName == nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please select a ring tone sound!!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
        
    }
    
    if (m_playingNow) {
        return;
    }
    
    // Convert mp3 to m4a.
    [self.view_activity setHidden:NO];
    [self saveSoundFileToM4A];
    [self.view_activity setHidden:YES];
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    
    NSString *exportPath = [[documentsDirectoryPath stringByAppendingPathComponent:m_convertedM4AFileName] retain];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
    {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        [controller setMailComposeDelegate:self];
        NSData *attachData = [NSData dataWithContentsOfFile:exportPath];
        NSString* body = [NSString stringWithFormat:@"%@\n", @"Ringtone attached."];
        body = [body stringByAppendingString:[NSString stringWithFormat:@"Date: %@\n", @"Created by Green Ringtone for iPhone"]];
        [controller setMessageBody:body isHTML:NO];
        [controller addAttachmentData:attachData mimeType:[self fileMIMEType:m_convertedM4AFileName] fileName:m_convertedM4AFileName];
        
        [self presentModalViewController:controller animated:YES];
        [controller release];
    }
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




#endif

@end
