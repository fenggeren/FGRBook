//
//  FGRBookrackManager.h
//  FGRBook
//
//  Created by fenggeren on 2016/10/8.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <Foundation/Foundation.h>


#define BookrackManager [FGRBookrackManager sharedInstance]

@class FGRNovelModel;

@interface FGRBookrackManager : NSObject


+ (instancetype)sharedInstance;

// 书架的书
@property (nonatomic, strong, readonly) NSArray<FGRNovelModel *> *novelModels;

- (void)loadAllNovelComplete:(dispatch_block_t)block;
- (void)refreshData:(dispatch_block_t)block;



- (BOOL)hasJoined:(FGRNovelModel *)novel;

- (void)addNovel:(FGRNovelModel *)novel;

- (void)removeNovel:(FGRNovelModel *)novel;

- (void)removeNovels:(NSArray<FGRNovelModel *> *)novels;
@end
