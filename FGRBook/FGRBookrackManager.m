//
//  FGRBookrackManager.m
//  FGRBook
//
//  Created by fenggeren on 2016/10/8.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRBookrackManager.h"
#import "FGRNovelModel.h"

#define kBookrackFile @"kBookrackFile.plist"

@interface FGRBookrackManager ()
{
    NSMutableOrderedSet *_novelURLs;
    NSMutableArray *_novelModels;
}
@end


@implementation FGRBookrackManager


+ (instancetype)sharedInstance
{
    static FGRBookrackManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath] == NO) {
            [[NSFileManager defaultManager] createFileAtPath:self.filePath contents:nil attributes:nil];
        }
        NSArray *array = [[NSArray alloc] initWithContentsOfFile:self.filePath];
        _novelURLs = [[NSMutableOrderedSet alloc] initWithArray:array];
    }
    return self;
}


- (NSString *)filePath
{
    static NSString *path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        path = [docPath stringByAppendingPathComponent:kBookrackFile];
    });
    return path;
}


- (void)loadAllNovelComplete:(dispatch_block_t)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *novels = [NSMutableArray array];
        for (NSString *url in _novelURLs) {
            FGRNovelModel *model = [FGRNovelModel novelModelWithCacheKey:url];
            [novels addObject:model];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _novelModels = novels;
            block();
        });
    });
}

- (void)refreshData:(dispatch_block_t)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_t group = dispatch_group_create();
        
        for (FGRNovelModel *novel in self.novelModels) {
            dispatch_group_enter(group);
            [novel refreshDataCompleteBlock:^(NSError *err) {
                dispatch_group_leave(group);
            }];
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            block();
        });
    });
}

- (void)addNovel:(FGRNovelModel *)novel
{
    if ([_novelModels containsObject:novel]) {
        return;
    }
    [novel cache];
    [_novelModels addObject:novel];
    [_novelURLs addObject:novel.url];
    [self persistent];
}

- (void)removeNovel:(FGRNovelModel *)novel
{
    if ([_novelModels containsObject:novel]) {
        return;
    }
    [novel remove];
    [_novelModels removeObject:novel];
    [_novelURLs removeObject:novel.url];
    [self persistent];
}

- (void)removeNovels:(NSArray<FGRNovelModel *> *)novels
{
    [FGRNovelModel removeFor:novels];
    [_novelModels removeObjectsInArray:novels];
    [_novelURLs removeObjectsInArray:[novels valueForKeyPath:@"url"]];
    [self persistent];
}

- (BOOL)hasJoined:(FGRNovelModel *)novel
{
    return [_novelModels containsObject:novel];
}

- (void)persistent
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *urls = [_novelModels valueForKeyPath:@"url"];
        [urls writeToFile:self.filePath atomically:YES];
    });
}

@end





