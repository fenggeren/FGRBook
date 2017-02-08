//
//  CPGLoadingView.m
//  cpglive-ios
//
//  Created by 周俊 on 16/3/13.
//
//

#import "CPGLoadingView.h"
#import "Masonry.h"

@interface CPGLoadingView () {
    NSTimer *animationTimer;
}
@property (weak, nonatomic) IBOutlet UIImageView *img1;
@property (weak, nonatomic) IBOutlet UIImageView *img2;
@property (weak, nonatomic) IBOutlet UIImageView *img3;
@property (weak, nonatomic) IBOutlet UIImageView *img4;

@end

@implementation CPGLoadingView

- (void)awakeFromNib {
    [super awakeFromNib];
    for (UIImageView *object in @[_img1, _img2, _img3, _img4]) {
        object.image = [object.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        object.tintColor = [UIColor blackColor];
        object.alpha = 1;
        object.transform = CGAffineTransformMakeScale(1.2, 1.2);
    };
}

- (void)startAnimation {
    if (animationTimer) {
        [animationTimer invalidate];
    }
    
    NSArray *imgs = @[_img1, _img2, _img3, _img4];
    for (NSInteger index = 0; index < imgs.count; ++index) {
        UIImageView *object = imgs[index];
        [UIView animateKeyframesWithDuration:1 delay:.2 * index options:UIViewKeyframeAnimationOptionRepeat|UIViewKeyframeAnimationOptionAutoreverse animations:^{
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
                object.alpha = 0.1;
                object.transform = CGAffineTransformMakeScale(1, 1);
            }];
        } completion:nil];
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        self.alphaView.alpha = 0.4;
    }];
}

- (void)hide {
    [self.layer removeAllAnimations];
    self.superview.userInteractionEnabled = YES;
    [self.alphaView removeFromSuperview];
    [self removeFromSuperview];
}

+ (instancetype)loadingView {
    UINib *nib = [UINib nibWithNibName:@"CPGLoadingView" bundle:nil];
    CPGLoadingView *view = [nib instantiateWithOwner:self options:nil][0];
    return view;
}

+ (instancetype)showInView:(UIView *)aView {
    UIView *alpha = [UIView new];
    alpha.backgroundColor = [UIColor clearColor];
    [aView addSubview:alpha];
    
    [alpha mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(aView);
    }];
    
    CPGLoadingView *loading = [self loadingView];
    [aView addSubview:loading];
    
    [loading mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(aView);
    }];
    
    aView.userInteractionEnabled = NO;
    loading.alphaView = alpha;
    [loading startAnimation];
    return loading;
}

@end
