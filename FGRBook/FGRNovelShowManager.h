//
//  FGRNovelShowManager.h
//  FGRBook
//
//  Created by fenggeren on 2016/9/23.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FGRPage, FGRChapter, FGRNovelModel;


typedef void(^FGRGetPageBlock)(FGRPage * page);


// 只用于阅读时 使用， 默认 所有的章节信息(除章内容外)都已加载完毕--!
@interface FGRNovelShowManager : NSObject

+ (instancetype)novelShowManagerWithNovel:(FGRNovelModel *)novel showSize:(CGSize)size complete:(void(^)(NSError *err))block;

- (instancetype)initWithNovel:(FGRNovelModel *)novel showSize:(CGSize)size;

@property (nonatomic, assign) NSInteger chapterIndex;

//@property (nonatomic, assign, readonly) NSInteger curChapterIndex;
@property (nonatomic, strong, readonly) FGRChapter *curChapter;

@property (nonatomic, assign, readonly) CGSize size;

@property (nonatomic, strong, readonly) FGRNovelModel *novel;

//  8/9页
@property (nonatomic, copy, readonly) NSString *indexStr;
// percent 0.898
@property (nonatomic, assign, readonly) CGFloat readPercent;
// 第一章 xxxx
@property (nonatomic, copy, readonly) NSString *chapterTitle;

// 设置 阅读百分比0.89 -->  如果last = 0.88   且0.88 & 0.89 在同一页 返回NO
- (BOOL)setNovelReadPercent:(CGFloat)percent;

- (void)refreshCurrentChapterComplete:(void(^)(NSError *err))block;

- (BOOL)hasCachedDisk;
- (void)cacheNovelDisk;
 
// 翻页--
- (void)curPage:(FGRGetPageBlock)block;
- (void)nextPage:(FGRGetPageBlock)block;
- (void)prePage:(FGRGetPageBlock)block;



// 上/下 一章
- (void)nextChapter;
- (void)previousChapter;

// 重新布局显示
- (void)formate;


@end
