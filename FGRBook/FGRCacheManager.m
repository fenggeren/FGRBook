//
//  FGRCacheManager.m
//  FGRBook
//
//  Created by fenggeren on 2016/9/30.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRCacheManager.h"
#import "FGRChapterInfoModel.h"
#import "YYCache.h"
#import "FGRDataBase.h"
#import <sqlite3.h>

#define FGRSTR(text) @#text

#define kNovelCacheDirectory @"novels"
#define kNovelCacheDirectoryDB @"db_novels"

@interface FGRCacheManager()

@property (nonatomic, strong) YYCache *cache;

@property (nonatomic, strong) dispatch_queue_t cacheQueue;

@end

@implementation FGRCacheManager
{
    FGRDataBase *_dataBase;
}
+ (instancetype)sharedInstance
{
    static FGRCacheManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        
    });
    return instance;
}



- (instancetype)init
{
    if (self = [super init]) {
        [self config];
    }
    return self;
}

- (void)config
{
    _cacheQueue = dispatch_queue_create("cache.queue", DISPATCH_QUEUE_SERIAL);
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *direc = [docPath stringByAppendingPathComponent:kNovelCacheDirectoryDB];
    
    BOOL isDirec = NO;
    if (!([[NSFileManager defaultManager] fileExistsAtPath:direc isDirectory:&isDirec] || isDirec)) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:direc withIntermediateDirectories:YES attributes:nil error:NULL]) {
            NSAssert(false, @"创建文件失败");
        }
    }
    
    dispatch_sync(_cacheQueue, ^{
        _dataBase = [[FGRDataBase alloc] initWithPath:direc];
    });
}



- (void)cacheModel:(id<NSCoding,FGRCacheBase>)novel
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.cache setObject:novel forKey:novel.cacheKey];
    });
}

- (void)removeModel:(id<NSCoding,FGRCacheBase>)novel
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       [self.cache removeObjectForKey:novel.cacheKey];
    });
}

- (id)modelWithURL:(NSString *)url
{
    return [self.cache objectForKey:url];
}

#pragma mark - db


- (void)insertNovelModel:(FGRNovelModel *)novelModel
{
    dispatch_async(_cacheQueue, ^{
        [_dataBase insertNovel:novelModel];
    });

}
- (void)insertChapterModel:(FGRChapterInfoModel *)model forFile:(NSString *)file
{
    dispatch_async(_cacheQueue, ^{
        [_dataBase insertChapter:model forFile:file];
    });
}

- (void)insertChapterModels:(NSArray<FGRChapterInfoModel *> *)models forFile:(NSString *)file
{
    dispatch_async(_cacheQueue, ^{
        for (FGRChapterInfoModel *model in models) {
            [_dataBase insertChapter:model forFile:file];
        }
    });
}

- (FGRNovelModel *)novelWithKey:(NSString *)key
{
    __block FGRNovelModel *model = nil;
    dispatch_sync(_cacheQueue, ^{
        model = [_dataBase novelWithKey:key];
    });
    return model;
}

- (FGRChapterInfoModel *)chapterWithKey:(NSString *)key fromFile:(NSString *)file
{
    __block FGRChapterInfoModel *model = nil;
    dispatch_sync(_cacheQueue, ^{
        model = [_dataBase chapterWithKey:key fromFile:file];
    });
    return model;
}

- (NSArray<FGRNovelModel *> *)novelsWithKeys:(NSArray<NSString *> *)keys
{
    __block NSArray *models = nil;
    dispatch_sync(_cacheQueue, ^{
        models = [_dataBase novelsWithKeys:keys];
    });
    return models;
}

- (NSArray<FGRChapterInfoModel *> *)chaptersWithKeys:(NSArray<NSString *> *)keys fromFile:(NSString *)file
{
    __block NSArray *models = nil;
    dispatch_sync(_cacheQueue, ^{
        models = [_dataBase chaptersWithKeys:keys fromFile:file];
    });
    return models;
}

- (NSArray<FGRChapterInfoModel *> *)allChaptersWithFile:(NSString *)file
{
    __block NSArray *models = nil;
    dispatch_sync(_cacheQueue, ^{
        models = [_dataBase allChaptersFromFile:file];
    });
    return models;
}

- (BOOL)removeNovelWithKeys:(NSArray<NSString *> *)keys
{
    __block BOOL result = NO;
    dispatch_sync(_cacheQueue, ^{
        result = [_dataBase removeNovelWithKeys:keys];
    });
    return result;
}

- (BOOL)removeNovelChaptersFile:(NSString *)file
{
    __block BOOL result = NO;
    dispatch_sync(_cacheQueue, ^{
        result = [_dataBase deleteTable:file];
    });
    return result;
}

- (BOOL)novelHasExistsWithKey:(NSString *)key
{
    __block BOOL result = NO;
    dispatch_sync(_cacheQueue, ^{
        result = [_dataBase novelHasExistsWithKey:key];
    });
    return result;
}

- (NSString *)chapterContentWithKey:(NSString *)key fromFile:(NSString *)file
{
    __block NSString *content = nil;
    dispatch_sync(_cacheQueue, ^{
        content = [_dataBase chapterContentWithKey:key fromFile:file];
    });
    return content;
}

@end
