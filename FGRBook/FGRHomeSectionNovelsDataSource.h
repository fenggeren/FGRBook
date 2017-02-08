//
//  FGRHomeSectionNovelsDataSource.h
//  FGRBook
//
//  Created by fenggeren on 16/9/19.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FGRNovelModel;

@interface FGRHomeSectionNovelsDataSource : NSObject <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray<FGRNovelModel *> *novelModels;

@end
