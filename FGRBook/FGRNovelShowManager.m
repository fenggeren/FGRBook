//
//  FGRNovelShowManager.m
//  FGRBook
//
//  Created by fenggeren on 2016/9/23.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRNovelShowManager.h"
#import "FGRDataManager.h"
#import "FGRNovelModel.h"
#import "FGRChapterInfoModel.h"
#import "FGRChapter.h"
#import "FGRCacheManager.h"

@interface FGRNovelShowManager ()
@property (nonatomic, strong) FGRChapter *curChapter;

@end

@implementation FGRNovelShowManager

@dynamic indexStr, readPercent, chapterIndex;


+ (instancetype)novelShowManagerWithNovel:(FGRNovelModel *)novel showSize:(CGSize)size complete:(void(^)(NSError *err))block
{
    FGRNovelShowManager *sm = [[FGRNovelShowManager alloc] initWithNovel:novel showSize:size];
    
    [sm.novel currentChapter:^(FGRChapterInfoModel *infoModel) {
        if (infoModel) {
            sm.curChapter = [[FGRChapter alloc] initWithSize:sm.size chapter:infoModel];
            [sm.curChapter formate];
            sm.curChapter.curIndex = novel.curChapterPageIndex;
            block(nil);
        } else {
            NSError *err = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{@"error": @"获取章节失败"}];
            block(err);
        }
    }];
    
    return sm;
}

- (instancetype)initWithNovel:(FGRNovelModel *)novel showSize:(CGSize)size
{
    if (self = [super init]) {
        _novel = novel;
        _size = size;
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [self.novel currentChapter:^(FGRChapterInfoModel *infoModel) {
            if (infoModel) {
                self.curChapter = [[FGRChapter alloc] initWithSize:self.size chapter:infoModel];
                [self.curChapter formate];
                self.curChapter.curIndex = novel.curChapterPageIndex;
            }
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageIndexChange:) name:kFGRNotiChapterPageIndexChangeKey object:nil];
        });
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark --

- (void)loadNovelData
{
    
}

- (void)setChapterIndex:(NSInteger)chapterIndex
{
    self.novel.curIndex = chapterIndex;
    _curChapter = nil;
}

- (NSInteger)chapterIndex
{
    return self.novel.curIndex;
}

- (NSString *)chapterTitle
{
    return _curChapter.title;
}

- (NSString *)indexStr
{
    return _curChapter.indexStr;
}

- (CGFloat)readPercent
{
    return _novel.readPercent;
}



- (BOOL)setNovelReadPercent:(CGFloat)percent
{
    NSInteger indexChapter = _novel.curIndex;
    _novel.readPercent = percent;
    if (indexChapter != _novel.curIndex) {
        _curChapter = nil;
        return YES;
    }
    return NO;
}

- (void)refreshCurrentChapterComplete:(void(^)(NSError *err))block
{
    [self.curChapter.infoModel loadContentCompleteBlock:^(NSError *err) {
        [self.curChapter formate];
        block(err);
    }];
}

- (void)curChapterContent:(void(^)(FGRChapterInfoModel *))block
{
    FGRChapterInfoModel *info = self.novel.chapters[self.novel.curIndex];
    if (info.isLoaded) {
        block(info);
    } else { 
        [info loadContentCompleteBlock:^(NSError *err) {
            block(info);
        }];
    }
}

- (void)curPage:(FGRGetPageBlock)block
{
    [self curChapter:^(FGRChapter *chapter) {
        if (chapter.curPage) {
            block(chapter.curPage);
        } else {  // 没有当前页--
            
        }
    }];
}

- (void)nextPage:(FGRGetPageBlock)block
{
    __weak __typeof(self)weakSelf = self;
    [self curChapter:^(FGRChapter *chapter) {
        if (chapter) {
            [chapter flipNext];
            if (chapter.curPage) {
                block(chapter.curPage);
            } else {  // 加载下一章
                [weakSelf nextChapter:^(FGRChapter *newChapter){
                    if (newChapter) {
                        block(newChapter.curPage);
                    } else {
                        block(nil); // 看完
                    }
                }];
            }
        } else {
            block(nil); // 看完
        }
    }];
}

- (void)prePage:(FGRGetPageBlock)block
{
    __weak __typeof(self)weakSelf = self;
    [self curChapter:^(FGRChapter *chapter) {
        if (chapter) {
            [chapter flipPrevious];
            if (chapter.curPage) {
                block(chapter.curPage);
            } else {  // 加载上一章 最后一页
                [weakSelf previousChapter:^(FGRChapter *newChapter){
                    if (newChapter) {
                        block(newChapter.lastPage);
                    } else {
                        block(nil); // 看完
                    }
                }];
            }
        } else {
            block(nil); // 看完
        }
    }];
}
#pragma mark - 
- (void)pageIndexChange:(NSNotification *)noti
{
    NSInteger curIndex = [noti.userInfo[@"value"] integerValue];
    self.novel.curChapterPageIndex = curIndex;
}

#pragma mark - HELP-

- (void)curChapter:(void(^)(FGRChapter *chapter))block
{
    if (_curChapter) {
        block(_curChapter);
        return;
    }
    [self configCurrentChapterBlock:block];
}

- (void)nextChapter:(void(^)(FGRChapter *chapter))block
{
    _curChapter = nil;
    if ([self.novel flipNextChapter]) {
        [self configCurrentChapterBlock:block];
    } else {
        block(nil);
    }
}

- (void)previousChapter:(void(^)(FGRChapter *chapter))block
{
    _curChapter = nil;
    if ([self.novel flipPreviousChapter]) {
        [self configCurrentChapterBlock:block];
    } else {
        block(nil);
    }
}


- (void)configCurrentChapterBlock:(void(^)(FGRChapter *chapter))block
{
    __weak __typeof(self)weakSelf = self;
    [self.novel currentChapter:^(FGRChapterInfoModel *infoModel) {
        if (infoModel) {
            weakSelf.curChapter = [[FGRChapter alloc] initWithSize:weakSelf.size chapter:infoModel];
            [weakSelf.curChapter formate];
            block(weakSelf.curChapter);
        } else {
            block(nil);
        }
    }];
}



#pragma mark -

- (void)nextChapter
{
    _curChapter = nil;
    [self.novel flipNextChapter];
}
- (void)previousChapter
{
    _curChapter = nil;
    [self.novel flipPreviousChapter];
}

- (void)formate
{
    [_curChapter formate];
}

- (BOOL)hasCachedDisk
{
    return self.novel.hasCached;
}

- (void)cacheNovelDisk
{ 
    [self.novel cache];
}


@end
