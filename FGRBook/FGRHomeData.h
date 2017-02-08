//
//  FGRHomeData.h
//  FGRBook
//
//  Created by fenggeren on 16/9/18.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FGRNovelModel, FGRChapterInfoModel, FGRHomeSectionNovels;
 

@interface FGRHomeData : NSObject<NSCoding>

- (void)cache;
+ (instancetype)homeDataFromCached;

@property (nonatomic, strong) NSArray<FGRNovelModel *> *bannerModels;

@property (nonatomic, strong) NSArray<FGRHomeSectionNovels *> *sectionModels;

- (void)loadDataComplete:(void(^)(NSError *))block;

@end
