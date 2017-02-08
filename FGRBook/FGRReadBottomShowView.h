//
//  FGRReadBottomShowView.h
//  
//
//  Created by fenggeren on 2016/9/26.
//
//

#import <UIKit/UIKit.h>
#import "FGRBottomMenuProtocol.h"


@interface FGRReadBottomShowView : UIView

+ (instancetype)showInView:(UIView *)view andDelegate:(id)delegate;

@property (nonatomic, weak) id<FGRReadBottomShowViewProtocol> delegate;

- (void)hide;

@end
