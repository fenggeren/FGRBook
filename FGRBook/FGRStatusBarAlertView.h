//
//  FGRStatusBarAlertView.h
//  FGRBook
//
//  Created by fenggeren on 2016/10/25.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FGRStatusBarAlertView : UIView

+ (instancetype)showWithTitle:(NSString *)title;
+ (instancetype)showWithTitle:(NSString *)title hidenAfter:(NSInteger)duration;

- (instancetype)initWithTitle:(NSString *)title;

- (void)hiding;
@end
