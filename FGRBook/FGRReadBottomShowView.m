//
//  FGRReadBottomShowView.m
//  
//
//  Created by fenggeren on 2016/9/26.
//
//

#import "FGRReadBottomShowView.h"
#import "UIImage+FGRExtension.h"
#import "UIView+Sizes.h"


@interface FGRReadBottomShowView ()
{
    NSArray *_themes;
}
@property (weak, nonatomic) IBOutlet UISlider *sldProgress;

@property (weak, nonatomic) IBOutlet UIScrollView *svContainer;


@end

@implementation FGRReadBottomShowView

+ (instancetype)readProgressView
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
    return [nib instantiateWithOwner:self options:nil].firstObject;
}

+ (instancetype)showInView:(UIView *)view andDelegate:(id)delegate
{
    FGRReadBottomShowView *showView = [FGRReadBottomShowView readProgressView];
    UIImage *colorImg = [UIImage imageWithColor:[UIColor blackColor] alpha:0.8];
    showView.backgroundColor = [UIColor colorWithPatternImage:colorImg];
    showView.origin = CGPointMake(0, view.height);
    showView.width = view.width;
    showView.delegate = delegate;
    [view addSubview:showView];
    
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        showView.origin = CGPointMake(0, view.height - showView.height);
    }];
    
    
    return showView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.sldProgress.value = [UIScreen mainScreen].brightness;
    
    [self configBackgroundTheme];
}

- (void)configBackgroundTheme
{
    NSMutableArray *themes = [NSMutableArray array];
    for (NSInteger i = 0; i < 5; ++i) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"reader_bg%ld", i + 1]];
        UIView *theme = [self bgViewWith:[UIColor colorWithPatternImage:image] tag:i];
        [self.svContainer addSubview:theme];
        [themes addObject:theme];
    }
    _themes = themes;
    
    [self layoutIfNeeded];
}


- (UIView *)bgViewWith:(UIColor *)color tag:(NSInteger)tag
{
    UIView *theme = [[UIView alloc] init];
    theme.tag = tag;
    theme.backgroundColor = color;
    [theme addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)]];
    return theme;
}

- (void)tapClick:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        for (UIView *v in _themes) {
            v.layer.borderWidth = 0;
        }
        UIView *v = _themes[tap.view.tag];
        v.layer.borderColor = [UIColor redColor].CGColor;
        v.layer.borderWidth = 1.;
        
        if ([self.delegate respondsToSelector:@selector(readBottomShowView:changeBackgroundTheme:)]) {
            [self.delegate readBottomShowView:self changeBackgroundTheme:tap.view.tag];
        }
    }
}

- (void)hide
{
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        self.origin = CGPointMake(0, self.origin.y + self.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)changeBrightness:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(readBottomShowView:changeBrightness:)]) {
        [self.delegate readBottomShowView:self changeBrightness:sender.value];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat len = self.svContainer.height;
    self.svContainer.contentSize = CGSizeMake(len, len * _themes.count);
    
    CGFloat margin = 8;
    CGFloat oriX = margin;
    len = len - margin;
    for (UIView *theme in _themes) {
        theme.origin = CGPointMake(oriX, margin * 0.5);
        theme.size = CGSizeMake(len, len);
        theme.clipsToBounds = YES;
        theme.layer.cornerRadius = len * 0.5;
        oriX = CGRectGetMaxX(theme.frame) + margin;
    }
}

@end
