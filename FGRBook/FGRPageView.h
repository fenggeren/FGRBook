//
//  FGRPageView.h
//  FGRBook
//
//  Created by fenggeren on 16/9/13.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, FGRPageFlipEffect) {
    FGRPageFlipEffectNone,  // 没有翻页效果， 直接换内容， 可以使用UITextView, 直接改变offset的值--
    FGRPageFlipEffectScroll, // scroll, 直接使用UITextView 呈现内容即可。
};

@class FGRPage, FGRPageView;

@protocol FGRPageViewDelegate <NSObject>

- (void)flipLeft:(FGRPageView *)pageView;
- (void)flipRight:(FGRPageView *)pageView;
- (void)callMenu:(FGRPageView *)pageView;

@end


@interface FGRPageView : UIView
 
@property (nonatomic, strong) FGRPage *page;

@end
