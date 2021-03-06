//
//  MCPagerView.h
//  MCPagerView
//
//  Created by Rose on 04/11/13.
//  Copyright Rose. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MCPAGERVIEW_DID_UPDATE_NOTIFICATION @"MCPageViewDidUpdate"

@protocol MCPagerViewDelegate;

@interface MCPagerView : UIView

- (void)setImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage forKey:(NSString *)key;

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,readonly) NSInteger numberOfPages;
@property (nonatomic,copy) NSString *pattern;
@property (nonatomic,assign) id<MCPagerViewDelegate>delegate;

@end

@protocol MCPagerViewDelegate <NSObject>

@optional
- (BOOL)pageView:(MCPagerView *)pageView shouldUpdateToPage:(NSInteger)newPage;
- (void)pageView:(MCPagerView *)pageView didUpdateToPage:(NSInteger)newPage;

@end