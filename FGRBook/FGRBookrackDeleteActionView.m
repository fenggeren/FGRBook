//
//  FGRBookrackDeleteActionView.m
//  FGRBook
//
//  Created by fenggeren on 2016/11/2.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRBookrackDeleteActionView.h"

@interface FGRBookrackDeleteActionView ()
@property (nonatomic, strong) UIView *alphaView;
@property (nonatomic, copy) void (^clickBlock)(NSInteger);
@end

@implementation FGRBookrackDeleteActionView

+ (instancetype)nibView
{
    return [[UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil] instantiateWithOwner:self options:nil].firstObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    for (UIButton *btn in @[self.btnCancel, self.btnDelete]) {
        btn.layer.cornerRadius = 3;
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.].CGColor;
    }
}

+ (instancetype)showInView:(UIView *)superView clickBlock:(void (^)(NSInteger))block
{
    FGRBookrackDeleteActionView *view = [self nibView];
    view.origin = CGPointMake(0, superView.height);
    view.size = CGSizeMake(superView.width, view.height);
    view.clickBlock = block;
    
    UIView *alphaView = [[UIView alloc] init];
    alphaView.backgroundColor = [UIColor blackColor];
    alphaView.alpha = 0;
    alphaView.frame = superView.bounds;
    [alphaView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(tapAlpha:)]];
    [superView addSubview:alphaView];
    view.alphaView = alphaView;
    
    [superView addSubview:view];
    [view show];
    return view;
}

- (void)tapAlpha:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self dismiss];
    }
}

- (void)show
{
    [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
        self.origin = CGPointMake(0, self.superview.height - self.height);
        self.alphaView.alpha = 0.3;
    }];
}


- (void)dismiss
{
    [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
        self.origin = CGPointMake(0, self.superview.height);
        self.alphaView.alpha = 0.;
    } completion:^(BOOL finished) {
        [self.alphaView removeFromSuperview];
        [self removeFromSuperview];
    }];
}
 
- (IBAction)clkDelete:(UIButton *)sender {
    if (self.clickBlock) {
        self.clickBlock(0);
    }
    [self dismiss];
}
- (IBAction)clkCancel:(UIButton *)sender {
    if (self.clickBlock) {
        self.clickBlock(1);
    }
    [self dismiss];
}

@end














