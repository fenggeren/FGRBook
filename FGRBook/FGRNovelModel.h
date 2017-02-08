//
//  FGRNovelModel.h
//  FGRBook
//
//  Created by fenggeren on 16/9/16.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGRChapterInfoModel.h"


typedef void(^FGRLoadChapterContentBlock)(FGRChapterInfoModel *chapter);
typedef void (^FGRProgressBlock)(CGFloat progress);

@interface FGRNovelModel : NSObject <NSCoding, FGRCacheBase>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy, readonly) NSString *sid;

@property (nonatomic, copy) NSString *imgURL;

@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *updateDate;
@property (nonatomic, copy) NSString *briefIntroduction;



// 最新章节
@property (nonatomic, strong) FGRChapterInfoModel *latestChapter;

// 看到的章节序号
@property (nonatomic, assign) NSInteger curIndex;

// 看到的章节的 page序号
@property (nonatomic, assign) NSInteger curChapterPageIndex;

@property (nonatomic, assign) NSInteger chapterAmount;

@property (nonatomic, assign, getter=isUpdate) BOOL update;

@property (nonatomic, strong) NSArray<FGRChapterInfoModel *> *chapters;

@property (nonatomic, assign, readonly, getter=isLoadCompleted) BOOL loadCompleted;

// percent 0.89
@property (nonatomic, assign) CGFloat readPercent;

@property (nonatomic, readonly, getter=isBookSelfed) BOOL bookSelf;

@property (nonatomic, copy) FGRProgressBlock (^loadProgressBlock)();
//@property (nonatomic, copy) void (^loadProgressBlock)(CGFloat progress);
- (void)currentChapter:(FGRLoadChapterContentBlock)block;

- (void)loadDataCompleteBlock:(void(^)(NSError *err))block;

- (void)refreshDataCompleteBlock:(void(^)(NSError *err))block;

- (BOOL)flipNextChapter;
- (BOOL)flipPreviousChapter;


#pragma mark - Cache

+ (instancetype)novelModelWithCacheKey:(NSString *)cacheKey;

+ (void)removeFor:(NSArray<FGRNovelModel *> *) novels;

- (void)cache;

- (void)remove;

//  已被缓存
- (BOOL)hasCached;

// 章节目录已经加载
- (BOOL)hasLoaded;

// 已加入书架
- (BOOL)hasJoinedBookrack;

- (void)loadAllCompleteProgress:(void(^)(CGFloat progress))block;

@end



















