//
//  FGRChapterInfoModel.h
//  FGRBook
//
//  Created by fenggeren on 16/9/16.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol FGRCacheBase <NSObject>

- (NSString *)cacheKey;

@end

@class FGRNovelModel;

@interface FGRChapterInfoModel : NSObject <NSCoding, FGRCacheBase>

+ (instancetype)chapterInfoWith:(NSString *)name URL:(NSString *)url;

- (instancetype)initWithName:(NSString *)name andURL:(NSString *)url andContent:(NSString *)content;

@property (nonatomic, weak) FGRNovelModel *novelModel;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *content;
 

@property (nonatomic, assign, readonly, getter=isLoaded) BOOL loaded;

- (void)loadContentCompleteBlock:(void (^)(NSError *))block;

- (void)cache;

- (void)remove;

@end
