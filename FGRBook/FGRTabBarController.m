//
//  FGRTabBarController.m
//  FGRBook
//
//  Created by fenggeren on 2016/9/30.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRTabBarController.h"
#import "FGRStatusBarAlertView.h"
#import "FGRNovelModel.h"
#import "JDStatusBarNotification.h"
#import "UIColor+FGRExtension.h"

#define NovelLoadCompletedStyle @"NovelLoadCompletedStyle"

@interface FGRTabBarController ()

@end

@implementation FGRTabBarController

+ (void)initialize
{

}

- (void)viewDidLoad {
    [super viewDidLoad];

    [JDStatusBarNotification addStyleNamed:NovelLoadCompletedStyle
                                   prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
                                       style.barColor = [UIColor colorWithNodecimalRed:212 green:59 blue:51 alpha:1.];
                                       style.textColor = [UIColor whiteColor];
                                       style.animationType = JDStatusBarAnimationTypeFade;
                                       style.font = [UIFont fontWithName:@"SnellRoundhand-Bold" size:12.0];
//                                       style.progressBarColor = [UIColor colorWithRed:0.986 green:0.062 blue:0.598 alpha:1.000];
                                       style.progressBarHeight = 20.0;
                                       
                                       return style;
                                   }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(novelLoadCompleted:) name:NovelDownloadCompleteNoti object:nil];
}


- (void)novelLoadCompleted:(NSNotification *)noti
{
    NSString *title = nil;
    if (![noti.object isKindOfClass:FGRNovelModel.class]) {
        title = @"测试下载小说完成";
    } else {
        title = [NSString stringWithFormat:@"%@下载完毕", [(FGRNovelModel *)noti.object name]];
    }
    [JDStatusBarNotification showWithStatus:title dismissAfter:2. styleName:NovelLoadCompletedStyle];
 
    
//    [FGRStatusBarAlertView showWithTitle:title hidenAfter:4.];
    
    
}



@end










