//
//  FGRReadProgressView.m
//  
//
//  Created by fenggeren on 2016/9/25.
//
//

#import "FGRReadProgressView.h"
#import "UIImage+FGRExtension.h"
#import "UIView+Sizes.h"

@interface FGRReadProgressView ()
{ 
}

@end

@implementation FGRReadProgressView

+ (instancetype)readProgressView
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
    return [nib instantiateWithOwner:self options:nil].firstObject;
}

+ (instancetype)showInView:(UIView *)view title:(NSString *)title percent:(CGFloat)percent andDelegate:(id<FGRReadProgressViewProtocol>)delegate
{
    FGRReadProgressView *progressView = [FGRReadProgressView readProgressView];
    UIImage *colorImg = [UIImage imageWithColor:[UIColor blackColor] alpha:0.8];
    progressView.backgroundColor = [UIColor colorWithPatternImage:colorImg];
    progressView.origin = CGPointMake(0, view.height);
    progressView.width = view.width;
    progressView.lblTitle.text = title;
    progressView.percent = percent >= 0 ? percent : 0;
    progressView.delegate = delegate;
    [view addSubview:progressView];
    
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        progressView.origin = CGPointMake(0, view.height - progressView.height);
    }];

    
    return progressView;
}

- (void)hide
{
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        self.origin = CGPointMake(0, self.origin.y + self.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.sldProgress.continuous = NO;
//    [self.sldProgress setMinimumTrackImage:[UIImage imageWithColor:[UIColor yellowColor] alpha:1.0] forState:UIControlStateNormal];
//    [self.sldProgress setMaximumTrackImage:[UIImage imageWithColor:[UIColor lightGrayColor] alpha:1.0] forState:UIControlStateNormal];
}


- (void)setPercent:(CGFloat)percent
{
    self.lblProgress.text = [NSString stringWithFormat:@"%.1f%%", percent * 100];
    self.sldProgress.value = percent;
}

- (CGFloat)percent
{
    return self.sldProgress.value;
}

// 定时器  超过0.3s thumb不动  就do Action
- (IBAction)slide:(UISlider *)sender {
    
    self.lblProgress.text = [NSString stringWithFormat:@"%.1f%%", sender.value * 100];
    if ([self.delegate respondsToSelector:@selector(readProgressView:readPercentChange:)]) {
        [self.delegate readProgressView:self readPercentChange:sender.value];
    }
}


- (IBAction)clickPreviousChapter:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(previousChapterProgressView:)]) {
        [self.delegate previousChapterProgressView:self];
    }
}

- (IBAction)clickNextChapter:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(nextChapterProgressView:)]) {
        [self.delegate nextChapterProgressView:self];
    }
}


@end
