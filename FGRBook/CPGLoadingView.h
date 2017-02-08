//
//  CPGLoadingView.h
//  cpglive-ios
//
//  Created by 周俊 on 16/3/13.
//
//

#import <UIKit/UIKit.h>

@interface CPGLoadingView : UIView

@property (weak, nonatomic) UIView *alphaView;

- (void)hide;

+ (instancetype)loadingView;

+ (instancetype)showInView:(UIView *)aView;


@end
