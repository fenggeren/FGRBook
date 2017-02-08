//
//  FGRReadProgressView.h
//  
//
//  Created by fenggeren on 2016/9/25.
//
//

#import <UIKit/UIKit.h>
#import "FGRBottomMenuProtocol.h"


@interface FGRReadProgressView : UIView

+ (instancetype)showInView:(UIView *)view title:(NSString *)title percent:(CGFloat)percent andDelegate:(id<FGRReadProgressViewProtocol>)delegate;

- (void)hide;

@property (nonatomic, weak) id<FGRReadProgressViewProtocol> delegate;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblProgress;
@property (weak, nonatomic) IBOutlet UISlider *sldProgress;

@property (nonatomic, assign) CGFloat percent;


@end
