//
//  FGRBookrackBottomMenu.m
//  FGRBook
//
//  Created by fenggeren on 2016/10/17.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRBookrackBottomMenu.h"


#define kAnimateDuration 0.3

@interface FGRBookrackBottomMenu ()
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) CGRect showFrame;

@end

@implementation FGRBookrackBottomMenu

+ (instancetype)bottomMenu
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
    return [nib instantiateWithOwner:self options:nil].firstObject;
}

+ (instancetype)showInView:(UIView *)superView originalFrame:(CGRect)originalFrame showFrame:(CGRect)showFrame
{
    FGRBookrackBottomMenu *menu = [self bottomMenu];
    menu.frame = originalFrame;
    menu.originalFrame = originalFrame;
    menu.showFrame = showFrame;
    [superView addSubview:menu];
    
    [menu show];
    return menu;
}


- (void)show
{
    [UIView animateWithDuration:kAnimateDuration animations:^{
        self.frame = self.showFrame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hide
{
    [UIView animateWithDuration:kAnimateDuration animations:^{
        self.frame = self.originalFrame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)btnClick:(UIButton *)sender {
    if (self.btnClickBlock) {
        self.btnClickBlock(sender.tag);
    }
}

@end
