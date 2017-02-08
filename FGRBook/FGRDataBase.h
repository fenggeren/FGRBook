//
//  FGRDataBase.h
//  FGRBook
//
//  Created by fenggeren on 2016/10/13.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FGRNovelModel, FGRChapterInfoModel;

@interface FGRDataBase : NSObject

- (instancetype)initWithPath:(NSString *)path;

- (FGRNovelModel *)novelWithKey:(NSString *)key;
- (FGRChapterInfoModel *)chapterWithKey:(NSString *)key fromFile:(NSString *)file;

- (BOOL)insertNovel:(FGRNovelModel *)novel;
- (BOOL)insertChapter:(FGRChapterInfoModel *)chapter forFile:(NSString *)file;

- (NSArray<FGRChapterInfoModel *> *)allChaptersFromFile:(NSString *)file;
- (NSArray<FGRNovelModel *> *)novelsWithKeys:(NSArray<NSString *> *)keys;
- (NSArray<FGRChapterInfoModel *> *)chaptersWithKeys:(NSArray<NSString *> *)keys fromFile:(NSString *)file;

- (BOOL)insertNovels:(NSArray<FGRNovelModel *> *)novels;
- (BOOL)insertChapters:(NSArray<FGRChapterInfoModel *> *)chapters;

- (BOOL)removeNovelWithKeys:(NSArray<NSString *> *)keys;

- (BOOL)novelHasExistsWithKey:(NSString *)key;

- (BOOL)deleteTable:(NSString *)tableName;

- (NSString *)chapterContentWithKey:(NSString *)key fromFile:(NSString *)file;
@end
