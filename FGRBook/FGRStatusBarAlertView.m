//
//  FGRStatusBarAlertView.m
//  FGRBook
//
//  Created by fenggeren on 2016/10/25.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRStatusBarAlertView.h"

#define kSelfHeight 20

@interface FGRStatusBarAlertView ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation FGRStatusBarAlertView

+ (instancetype)showWithTitle:(NSString *)title
{
    FGRStatusBarAlertView *alertView = [[FGRStatusBarAlertView alloc] initWithTitle:title];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:alertView];
    alertView.frame = CGRectMake(0, -kSelfHeight, window.width, kSelfHeight);
    [UIView animateWithDuration:1. animations:^{
        alertView.frame = CGRectMake(0, 0, window.width, kSelfHeight);
    }];
    
    return alertView;
}

+ (instancetype)showWithTitle:(NSString *)title hidenAfter:(NSInteger)duration
{
    FGRStatusBarAlertView *alertView = [self showWithTitle:title];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertView hiding];
    });
    
    return alertView;
}


- (instancetype)initWithTitle:(NSString *)title
{
    if (self = [super init]) {
        UILabel *label = [[UILabel alloc] init];
        label.text = title;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        self.label = label;
//        self.windowLevel = UIWindowLevelStatusBar;
        self.backgroundColor = [UINavigationBar appearance].barTintColor;
    }
    return self;
}

- (void)hiding
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [UIView animateWithDuration:1. animations:^{
        self.frame = CGRectMake(0, -kSelfHeight, window.width, kSelfHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.label.frame = self.bounds;
}
@end
