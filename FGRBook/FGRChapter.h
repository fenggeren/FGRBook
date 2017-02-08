//
//  FGRChapter.h
//  FGRBook
//
//  Created by fenggeren on 2016/9/23.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FGRPage.h"


#define kFGRNotiChapterPageIndexChangeKey @"kFGRNotiChapterPageIndexChangeKey"

@class FGRChapterInfoModel;

@interface FGRChapter : NSObject
 

- (instancetype)initWithSize:(CGSize)size chapter:(FGRChapterInfoModel *)model;

@property (nonatomic, strong, readonly) FGRChapterInfoModel *infoModel;

@property (nonatomic, assign) CGSize size;

@property (nonatomic, strong, readonly) FGRPage *curPage;

// 最后一页
@property (nonatomic, strong, readonly) FGRPage *lastPage;

@property (nonatomic, copy, readonly) NSString *indexStr;

@property (nonatomic, copy, readonly) NSString *title;
 
@property (nonatomic, assign) NSInteger curIndex;


- (void)flipNext;
- (void)flipPrevious;

// 格式化--
- (void)formate;

@end
