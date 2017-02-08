//
//  FGRBottomMenuController.h
//  CollectionViewAutoScroll
//
//  Created by HuanaoGroup on 16/11/1.
//  Copyright © 2016年 HuanaoGroup. All rights reserved.
//

#import "FGRBaseViewController.h"
#import "FGRBottomMenuProtocol.h"

@class FGRBottomMenuController, FGRNovelShowManager, FGRChapterListController;

@protocol  FGRBottomMenuControllerProtocol<NSObject>

- (FGRNovelShowManager *)showManagerForMenuController:(FGRBottomMenuController *)menuController;
- (void)menuController:(FGRBottomMenuController *)menuController selectIndexChapter:(NSInteger)index atCatalogController:(FGRChapterListController *)listController;
- (UINavigationController *)navigationControllerForCatalogController:(FGRChapterListController *)listController menuController:(FGRBottomMenuController *)menuController;
@end


@interface FGRBottomMenuController : FGRBaseViewController

+ (instancetype)bottomMenuController;

@property (nonatomic, weak) id<FGRBottomMenuControllerProtocol, FGRReadProgressViewProtocol, FGRReadBottomShowViewProtocol> menuDelegate;

- (void)show;
- (void)dismissComplete:(dispatch_block_t)block;

@end
