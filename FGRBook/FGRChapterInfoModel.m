//
//  FGRChapterInfoModel.m
//  FGRBook
//
//  Created by fenggeren on 16/9/16.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRChapterInfoModel.h"
#import "FGRDataManager.h"
#import "FGRCacheManager.h"
#import "FGRNovelModel.h"
#import "NSString+FGRExtension.h"

@implementation FGRChapterInfoModel


+ (instancetype)chapterInfoWith:(NSString *)name URL:(NSString *)url
{
    FGRChapterInfoModel *model = [[self alloc] init];
    model.name = name;
    model.url = url;
    return model;
}

- (instancetype)initWithName:(NSString *)name andURL:(NSString *)url andContent:(NSString *)content
{
    if (self = [super init]) {
        _name = [name copy];
        _url = [url copy];
        _content = [content copy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.content forKey:@"content"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        _content = [aDecoder decodeObjectForKey:@"content"]; 
    }
    return self;
}

- (NSString *)cacheKey
{
    return _url;
}

- (void)setContent:(NSString *)content
{
    _content = [content copy];
    if (content == nil || content.length == 0) {
        return;
    }
    [self cache];
}

- (void)setUrl:(NSString *)url
{
    _url = [[DataManager fullURLWith:url] copy];
}


- (BOOL)isLoaded
{
    if (![self isValidContent:_content]) {
        _content = [CacheManager chapterContentWithKey:self.url fromFile:self.novelModel.sid];
    }
    
    return [self isValidContent:_content];
}

- (BOOL)isValidContent:(NSString *)content
{
    return !(content == nil || ([content stringTrimHeaderTail].length < 20 && [content containsString:@"null"]));
}

- (void)loadContentCompleteBlock:(void (^)(NSError *))block
{
    if (self.isLoaded) {
        block(nil);
        return;
    }
    [DataManager chapterContentWithURL:self.url completeBlock:^(NSString *content, NSError *err) {
        self.content = content;
        block(err);
    }];
}

- (void)cache
{
    BOOL bs = self.novelModel.isBookSelfed;
    if (self.novelModel.isBookSelfed) {
        [CacheManager insertChapterModel:self forFile:self.novelModel.sid];
    }
}

- (void)remove
{
    
}

- (BOOL)isEqual:(FGRChapterInfoModel *)object
{
    return [self.url isEqualToString:object.url];
}

- (NSUInteger)hash
{
    return [self.url hash];
}

@end
