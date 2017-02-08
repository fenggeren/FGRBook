//
//  FGRLoadProgressView.h
//  FGRBook
//
//  Created by fenggeren on 2016/10/24.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FGRLoadProgressView : UIView

+ (instancetype)loadProgressView;

@property (nonatomic, assign) CGFloat progress;

- (void)stopAnimation;
- (void)startAnimation;

@end
