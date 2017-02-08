//
//  FGRHomeSectionNovels.h
//  FGRBook
//
//  Created by fenggeren on 16/9/19.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FGRNovelModel;

@interface FGRHomeSectionNovels : NSObject <NSCoding>

@property (nonatomic, strong) NSArray<FGRNovelModel *> *novels;

@property (nonatomic, copy) NSString *typeName;

// Cell中 CollectionView的偏移量
@property (nonatomic, assign) CGPoint contentOffset;

@end
