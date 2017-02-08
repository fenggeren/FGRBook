//
//  MyCollectionViewDataSource.h
//  CollectionViewAutoScroll
//
//  Created by Fenggeren on 16/10/28.
//  Copyright © 2016年 Fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGRCollectionViewLayout.h"

@class FGRNovelModel;

@interface FGRCollectionViewDataSource : NSObject<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>


- (void)configCollectionView:(UICollectionView *)collectionView;


- (void)defaultSetLayout;


- (void)startAutoScroll;

- (void)stopAutoScroll;


@property (nonatomic, strong, readonly) FGRCollectionViewLayout *collectionViewLayout;

@property (nonatomic, strong) NSArray<FGRNovelModel *> *models;

@property (nonatomic, copy) void(^didSelectedCell)(NSIndexPath *indexPath, FGRNovelModel *model);

@end
