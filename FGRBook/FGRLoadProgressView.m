//
//  FGRLoadProgressView.m
//  FGRBook
//
//  Created by fenggeren on 2016/10/24.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRLoadProgressView.h"
#import "POP.h"
#import "UIView+Sizes.h"

@interface FGRLoadProgressView ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lblProgress;

@end

@implementation FGRLoadProgressView

+ (instancetype)loadProgressView
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
    return [nib instantiateWithOwner:self options:nil].firstObject;
}

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
}


- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    self.lblProgress.text = [NSString stringWithFormat:@"%.0f%%", progress * 100];
    if (progress < 1) {
        [self startAnimation];
    } 
}


- (void)stopAnimation
{
//    [self.imageView.layer pop_removeAnimationForKey:@"rotate"];
    [self.imageView.layer removeAnimationForKey:@"rotationAnimation"];
}
- (void)startAnimation
{
    if ([self.imageView.layer animationForKey:@"rotationAnimation"] == nil) {
//        POPBasicAnimation *ani = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
//        ani.duration = 4.;
//        ani.toValue = @(M_PI * 2);
//        ani.repeatCount = INT_MAX;
//        ani.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//        [self.imageView.layer pop_addAnimation:ani forKey:@"rotate"];
        
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
        rotationAnimation.duration = 5.;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = HUGE_VALF;
        
        [self.imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
}

@end


