//
//  FGRNovelModel.m
//  FGRBook
//
//  Created by fenggeren on 16/9/16.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRNovelModel.h"
#import "FGRChapterInfoModel.h"
#import "FGRDataManager.h"
#import <UIKit/UIKit.h>
#import "GDataXMLNode.h"
#import "FGRGlobalFunction.h"
#import "FGRCacheManager.h"
#import "FGRBookrackManager.h"
#import "CPGLoadingView.h"
#import "FGRGlobalFunction.h"

@interface FGRNovelModel ()
{
    BOOL _loading;
}

@end


@implementation FGRNovelModel
@dynamic readPercent;
@synthesize curIndex=_curIndex;
#pragma mark - 


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.imgURL forKey:@"imgURL"];
    [aCoder encodeObject:self.author forKey:@"author"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.updateDate forKey:@"updateDate"];
    [aCoder encodeObject:self.briefIntroduction forKey:@"briefIntroduction"];
    [aCoder encodeObject:self.latestChapter forKey:@"latestChapter"];
    [aCoder encodeInteger:self.curIndex forKey:@"curIndex"];
    [aCoder encodeObject:self.chapters forKey:@"chapters"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.imgURL = [aDecoder decodeObjectForKey:@"imgURL"];
        self.author = [aDecoder decodeObjectForKey:@"author"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.updateDate = [aDecoder decodeObjectForKey:@"updateDate"];
        self.briefIntroduction = [aDecoder decodeObjectForKey:@"briefIntroduction"];
        self.latestChapter = [aDecoder decodeObjectForKey:@"latestChapter"];
        self.curIndex = [aDecoder decodeIntegerForKey:@"curIndex"];
        self.chapters = [aDecoder decodeObjectForKey:@"chapters"];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self ;
}

#pragma mark --


- (void)refreshDataCompleteBlock:(void(^)(NSError *err))block
{
    [DataManager asyncRequestDocumentWith:self.url completeBlock:^(GDataXMLDocument *doc, NSError *error) {
        if (error) {
            threadPerform(YES, ^{
                block(error);
            });
        } else {
            threadPerform(NO, ^{
                [self parseInfo:doc];
                [self parseChapters:doc];
                threadPerform(YES, ^{
                    block(nil);
                });
            });
        }
    }];
}

- (void)loadDataCompleteBlock:(void (^)(NSError *))block
{
    if ([self hasCached] && [self hasLoaded]) {
        block(nil);
        return;
    }
    [self refreshDataCompleteBlock:block];
}

- (void)parseInfo:(GDataXMLDocument *)doc
{
    self.imgURL = [(GDataXMLElement *)[doc firstNodeForXPath:@"//*[@id='fmimg']/img/@src" error:NULL] stringValue];
    
    
    GDataXMLElement *infoEle = (GDataXMLElement *)[doc firstNodeForXPath:@"//div[@id='info']" error:NULL];
    
    self.name = [[infoEle firstNodeForXPath:@"h1" error:NULL] stringValue];
    NSString *auth = [[infoEle firstNodeForXPath:@"p" error:NULL] stringValue];
    self.author = [[auth componentsSeparatedByString:@":"] lastObject];
    NSString *nudpateDate = [[infoEle firstNodeForXPath:@"p[3]" error:NULL] stringValue];
    
    if ([nudpateDate isEqualToString:self.updateDate] == NO && self.updateDate != nil) {
        self.update = YES;
    }
    self.updateDate = nudpateDate;
    
    FGRChapterInfoModel *latestChapter = [[FGRChapterInfoModel alloc] init];
    GDataXMLElement *latestEle = (GDataXMLElement *)[infoEle firstNodeForXPath:@"p[4]" error:NULL];
    latestChapter.name = [[latestEle firstNodeForXPath:@"a" error:NULL] stringValue];
    latestChapter.url = [[latestEle firstNodeForXPath:@"a/@href" error:NULL] stringValue];
    latestChapter.novelModel = self;
    self.latestChapter = latestChapter;
    
    
    self.briefIntroduction = [[doc firstNodeForXPath:@"//*[@id='intro']/p" error:NULL] stringValue];
}

- (void)setLoadProgressBlock:(FGRProgressBlock (^)())loadProgressBlock
{
    _loadProgressBlock = [loadProgressBlock copy];
    
}

- (void)parseChapters:(GDataXMLDocument *)doc
{
    NSArray *nodes = [doc nodesForXPath:@"//*[@id='list']/dl/dd" error:NULL];
    NSMutableArray *chapters = [NSMutableArray array];
    for (GDataXMLElement *ele in nodes) {
        NSString *name = [ele stringValue];
        GDataXMLElement *aEle = (GDataXMLElement *)[ele firstNodeForXPath:@"a" error:NULL];
        NSString *url = [[aEle attributeForName:@"href"] stringValue];
        FGRChapterInfoModel *chapter = [FGRChapterInfoModel chapterInfoWith:name URL:url];
        chapter.novelModel = self;
        [chapters addObject:chapter];
    }
    
    self.chapters = chapters;
}

- (void)setUrl:(NSString *)url
{
    _url = [[DataManager fullURLWith:url] copy];
    _sid = [_url lastPathComponent];
}

- (void)setImgURL:(NSString *)imgURL
{
    _imgURL = [[DataManager fullURLWith:imgURL] copy];
}

- (void)setChapters:(NSArray<FGRChapterInfoModel *> *)chapters
{
    chapters = [[chapters reverseObjectEnumerator] allObjects];
    NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:chapters];
    NSArray *arr = [[set.array reverseObjectEnumerator] allObjects];
    if (_chapters == nil) {
        _chapters = arr;
    } else if (arr.count > _chapters.count) {
        NSArray *addArr = [arr subarrayWithRange:NSMakeRange(_chapters.count, arr.count - _chapters.count)];
        NSMutableArray *result = [NSMutableArray arrayWithArray:_chapters];
        [result addObjectsFromArray:addArr];
        _chapters = [result copy];
    }
    _chapterAmount = _chapters.count;
}

- (BOOL)isLoadCompleted
{
    return self.chapters != nil;
}

- (CGFloat)readPercent
{
    CGFloat total = _chapterAmount;
    if (total <= 0) {
        return 0;
    }
    CGFloat percent = (CGFloat)_curIndex / total;
    
    if (_curChapterPageIndex == 0 && percent < 0.01 && _curIndex == 0) {
        return -1;
    }
    return percent > 1.0 ? 1.0 : percent;
}

- (void)setReadPercent:(CGFloat)readPercent
{
    NSInteger index = readPercent * _chapters.count;
    if (index > _chapters.count - 1) {
        index = _chapters.count - 1;
    }
    _curIndex = index;
}

- (BOOL)isBookSelfed
{
    return [[FGRBookrackManager sharedInstance] hasJoined:self];
}

#pragma mark - ShowContent

- (BOOL)isIndexValid:(NSInteger)chapterIndex
{
    return chapterIndex >= 0 && chapterIndex < _chapters.count;
}

- (BOOL)flipNextChapter
{
    BOOL result = [self isIndexValid:_curIndex + 1];
    self.curIndex++;
    return result;
}

- (BOOL)flipPreviousChapter
{
    BOOL result = [self isIndexValid:_curIndex - 1];
    self.curIndex--;
    return result;
}

- (void)nextChapter:(FGRLoadChapterContentBlock)block
{
    [self _novelContentWith:self.curIndex + 1 completeBlock:block];
}

- (void)previousChapter:(FGRLoadChapterContentBlock)block
{
    [self _novelContentWith:self.curIndex - 1 completeBlock:block];
}

- (void)currentChapter:(FGRLoadChapterContentBlock)block
{
    [self _novelContentWith:self.curIndex completeBlock:block];
}

- (void)setCurIndex:(NSInteger)curIndex
{
    if (curIndex < 0) {
        _curIndex = 0;
    } else if (curIndex > self.chapters.count - 1){
        _curIndex = self.chapters.count - 1;
    } else {
        _curIndex = curIndex;
    }
}

- (NSInteger)curIndex
{
    if (_curIndex >= self.chapters.count) {
        _curIndex = self.chapters.count - 1;
    }
    return _curIndex;
}

- (void)_novelContentWith:(NSInteger)index completeBlock:(FGRLoadChapterContentBlock)block
{
    if (index < 0 || (index > self.chapters.count - 1)) {
        if (index < 0) {
            index = 0;
        } else if (index > self.chapters.count - 1) {
            index = self.chapters.count - 1;
        }
        block(nil);
        return;
    }
    _curIndex = index;

    if (self.chapters == nil || self.chapters.count == 0) {
        block(nil);
        return;
    }
    
    if (self.chapters == nil) {
        block(nil);
    }
    
    FGRChapterInfoModel *model = self.chapters[index];
    if (model.isLoaded) {
        block(model);
    } else
    {
        __block CPGLoadingView *loadingView = nil;
        mainPerform(^{
            UIView *topView = [UIApplication sharedApplication].keyWindow;
            if (topView ) {
                loadingView = [CPGLoadingView showInView:topView];
            }
        });
        [DataManager chapterContentWithURL:model.url completeBlock:^(NSString *content, NSError *err) {
            model.content = content;
            block(model);
            mainPerform(^{
                [loadingView hide];
            });
        }];
    }
    [self preLoad];
}


- (void)preLoad
{
    static NSInteger num = 2;
    for (NSInteger i = 1; i < num + 1 && self.curIndex + i < self.chapters.count; ++i) {
        FGRChapterInfoModel *model = self.chapters[self.curIndex + i];
        if (model.isLoaded) {
            continue;
        } else {
            [model loadContentCompleteBlock:^(NSError *err) {
                
            }];
        }
    }
}

- (void)loadAllCompleteProgress:(void(^)(CGFloat progress))block
{
    if (_loading) {
        return;
    }
    _loading = YES;
    NSInteger count = self.chapters.count;
    __block NSInteger loaded = 0;
    __block NSInteger curProgress = 0;
    [self.chapters enumerateObjectsUsingBlock:^(FGRChapterInfoModel *obj, NSUInteger idx, BOOL *stop) {
        [obj loadContentCompleteBlock:^(NSError *err) {
            loaded++;
            NSLog(@"---%@---",@(loaded));
            if (loaded * 100 - curProgress >= 1 || loaded == count) {
                curProgress = loaded;
                mainPerform(^{
                    block((CGFloat)loaded / count);
                    if (self.loadProgressBlock) {
                        self.loadProgressBlock()((CGFloat)loaded / count);
                    }
                    if (loaded == count) {
                        _loading = NO;
                        [[NSNotificationCenter defaultCenter] postNotificationName:NovelDownloadCompleteNoti object:self];
                    }
                });
            }
        }];
    }];
}


#pragma mark - 

- (BOOL)isEqual:(FGRNovelModel *)object
{
    return [self.url isEqualToString:object.url];
}

- (NSUInteger)hash
{
    return [self.url hash];
}

#pragma mark -


- (NSString *)cacheKey
{
    return _url;
}

+ (instancetype)novelModelWithCacheKey:(NSString *)cacheKey
{
//    FGRNovelModel *model = [CacheManager modelWithURL:cacheKey];
    FGRNovelModel *model = [CacheManager novelWithKey:cacheKey];
    if (model == nil) {
        model = [[self alloc] init];
    }
    return model;
}



- (void)cache
{
    [CacheManager insertNovelModel:self];
}


- (void)remove
{
//    [CacheManager removeModel:self];
    [CacheManager removeNovelWithKeys:@[self.url]];
    [CacheManager removeNovelChaptersFile:self.sid];
}

+ (void)removeFor:(NSArray<FGRNovelModel *> *) novels
{
    NSArray *keys = [novels valueForKeyPath:@"url"];
    [CacheManager removeNovelWithKeys:keys];
    for (FGRNovelModel *novel in novels) {
        [CacheManager removeNovelChaptersFile:novel.sid];
    }
}

- (BOOL)hasCached
{
//    return [CacheManager modelWithURL:self.url] != nil;
    return [CacheManager novelHasExistsWithKey:self.url];
}

- (BOOL)hasLoaded
{
    if (self.chapters == nil) {
        NSArray *array = [CacheManager allChaptersWithFile:self.sid];
        [array makeObjectsPerformSelector:@selector(setNovelModel:) withObject:self];
        self.chapters = array;
    }
    return self.chapters != nil && self.chapters.count != 0;
}

- (BOOL)hasJoinedBookrack
{
    return [BookrackManager hasJoined:self];
}

@end
