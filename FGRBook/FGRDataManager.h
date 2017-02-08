//
//  FGRDataManager.h
//  FGRBook
//
//  Created by fenggeren on 16/9/16.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DataManager [FGRDataManager sharedInstance]

@class FGRChapterInfoModel;
@class FGRNovelModel;
@class GDataXMLElement;
@class GDataXMLDocument;

@protocol FGRSiteParse <NSObject>

- (FGRChapterInfoModel *)chapterWithEle:(GDataXMLElement *)element;
- (void)setChapterContent:(FGRChapterInfoModel *)model with:(GDataXMLElement *)element;
- (NSArray<FGRNovelModel *> *)homeBannerNovels;

@end


@interface FGRDataManager : NSObject

+ (instancetype)sharedInstance;

- (void)asyncRequestDocumentWith:(NSString *)url completeBlock:(void(^)(GDataXMLDocument *docu, NSError *error))block;

- (void)asyncRequestDataWith:(NSString *)url completeBlock:(void(^)(NSData *data, NSError *error))block;

- (void)chaptersWithNovel:(FGRNovelModel *)novel completeBlock:(void(^)(NSArray *))block;

- (void)chapterContentWithURL:(NSString *)url completeBlock:(void(^)(NSString *content, NSError *err))block;


- (NSString *)fullURLWith:(NSString *)url;


@end

















