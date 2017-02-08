//
//  FGRReadNovelMoreMenu.h
//  FGRBook
//
//  Created by fenggeren on 2016/10/26.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGRBottomMenuProtocol.h"




@interface FGRTriangle : UIView

@end


@interface FGRReadNovelMoreMenuItem : NSObject

- (instancetype)initWith:(NSString *)iconName title:(NSString *)title clickAction:(dispatch_block_t)action;

@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) dispatch_block_t clickAction;
@end




@interface FGRReadNovelMoreMenu : UIView
+ (instancetype)showInView:(UIView *)v delegate:(id<FGRReadNovelMoreMenuProtocol>)delegate;
@property (nonatomic, weak) id<FGRReadNovelMoreMenuProtocol> delegate;
- (void)dismiss;
@end







