//
//  FGRCacheManager.h
//  FGRBook
//
//  Created by fenggeren on 2016/9/30.
//  Copyright © 2016年 fenggeren. All rights reserved.
//



#import <Foundation/Foundation.h>

#define CacheManager [FGRCacheManager sharedInstance]

@protocol FGRCacheBase;

@class FGRNovelModel, FGRChapterInfoModel;

@interface FGRCacheManager : NSObject

+ (instancetype)sharedInstance;

- (id)modelWithURL:(NSString *)url;

- (void)cacheModel:(id<NSCoding,FGRCacheBase>)novel;

- (void)removeModel:(id<NSCoding,FGRCacheBase>)novel;


- (void)insertNovelModel:(FGRNovelModel *)novelModel;

- (void)insertChapterModel:(FGRChapterInfoModel *)model forFile:(NSString *)file;
- (void)insertChapterModels:(NSArray<FGRChapterInfoModel *> *)models forFile:(NSString *)file;

- (FGRNovelModel *)novelWithKey:(NSString *)key;
- (FGRChapterInfoModel *)chapterWithKey:(NSString *)key fromFile:(NSString *)file;

- (NSArray<FGRNovelModel *> *)novelsWithKeys:(NSArray<NSString *> *)keys;

- (NSArray<FGRChapterInfoModel *> *)chaptersWithKeys:(NSArray<NSString *> *)keys fromFile:(NSString *)file;
- (NSArray<FGRChapterInfoModel *> *)allChaptersWithFile:(NSString *)file;

- (BOOL)removeNovelWithKeys:(NSArray<NSString *> *)keys;

- (BOOL)novelHasExistsWithKey:(NSString *)key;

- (BOOL)removeNovelChaptersFile:(NSString *)file;

- (NSString *)chapterContentWithKey:(NSString *)key fromFile:(NSString *)file;
@end




