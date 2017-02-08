//
//  FGRNovelReadBottomMenu.h
//  FGRBook
//
//  Created by fenggeren on 2016/9/25.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FGRNovelReadBottomMenuType) {
    FGRNovelReadBottomMenuTypeCatalog,
    FGRNovelReadBottomMenuTypeProgress,
    FGRNovelReadBottomMenuTypeOptions,
    FGRNovelReadBottomMenuTypeShow,
    FGRNovelReadBottomMenuTypeComment,
};

@class FGRNovelReadBottomMenu;

@protocol FGRNovelReadBottomMenuProtocol <NSObject>
@optional
- (void)clickMenu:(FGRNovelReadBottomMenu *)menu typeForItem:(FGRNovelReadBottomMenuType)menuType;

@end

@interface FGRNovelReadBottomMenu : UIView

@property (nonatomic, weak) id<FGRNovelReadBottomMenuProtocol> delegate;


@end
