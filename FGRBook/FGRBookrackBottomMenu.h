//
//  FGRBookrackBottomMenu.h
//  FGRBook
//
//  Created by fenggeren on 2016/10/17.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, FGRBookrackBottomMenuItemType) {
    FGRBookrackBottomMenuItemTypeDownload,
    FGRBookrackBottomMenuItemTypeMove,
    FGRBookrackBottomMenuItemTypeDelete,
};

@interface FGRBookrackBottomMenu : UIView

+ (instancetype)bottomMenu;

+ (instancetype)showInView:(UIView *)superView originalFrame:(CGRect)originalFrame showFrame:(CGRect)showFrame;

@property (nonatomic, copy) void (^btnClickBlock)(FGRBookrackBottomMenuItemType itemType);


- (void)show;
- (void)hide;

@end
