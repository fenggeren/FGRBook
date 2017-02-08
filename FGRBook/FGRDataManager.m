//
//  FGRDataManager.m
//  FGRBook
//
//  Created by fenggeren on 16/9/16.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRDataManager.h"
#import "GDataXMLNode.h"
#import "FGRChapterInfoModel.h"
#import "NSString+FGRExtension.h"
#import <UIKit/UIKit.h>
#import "AFNetworking/AFNetworking.h"
#import "AFNetworking/UIKit+AFNetworking.h"
#import "FGRGlobalFunction.h"
#import "CPGLoadingView.h"
#import "FGRNovelModel.h"

NSString * BIQUGE = @"笔趣阁";


@interface FGRDataManager ()
{
    __weak CPGLoadingView *_loadingView;
}
@property (nonatomic, copy) NSString *site;

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@end

@implementation FGRDataManager

- (void)chaptersWithNovel:(FGRNovelModel *)novel completeBlock:(void(^)(NSArray *))block
{
    [self asyncRequestDocumentWith:novel.url completeBlock:^(GDataXMLDocument *doc, NSError *err) {
        NSArray *nodes = [doc nodesForXPath:@"//*[@id='list']/dl/dd" error:NULL];
        NSMutableArray *chapters = [NSMutableArray array];
        for (GDataXMLElement *ele in nodes) {
            NSString *name = [ele stringValue];
            GDataXMLElement *aEle = (GDataXMLElement *)[ele firstNodeForXPath:@"a" error:NULL];
            NSString *url = [[aEle attributeForName:@"href"] stringValue];
            url = [self.class fullURLWith:url site:self.site];
            FGRChapterInfoModel *chapter = [FGRChapterInfoModel chapterInfoWith:name URL:url];
            chapter.novelModel = novel;
            [chapters addObject:chapter];
        }
        block(chapters);
    }];
}

- (void)chapterContentWithURL:(NSString *)url completeBlock:(void(^)(NSString *content, NSError *err))block
{
    
    [self asyncRequestDocumentWith:url completeBlock:^(GDataXMLDocument *doc, NSError* err) {
        GDataXMLElement *ele = (GDataXMLElement *)[doc firstNodeForXPath:@"//*[@id='content']" error:NULL];
        NSString *content = [ele.stringValue copy];
        NSRange range = [content rangeOfString:@"readx();"];
        if (range.location != NSNotFound) {
            content = [content substringFromIndex:range.location + range.length];
        }
        [content stringTrimHeaderTail];
        content = [content stringByReplacingOccurrencesOfString:@"    " withString:@"\n        "];
        content = [NSString stringWithFormat:@"    %@", content];
        
        block(content, nil);
    }];
}

- (void)asyncRequestDocumentWith:(NSString *)url completeBlock:(void (^)(GDataXMLDocument *, NSError *))block
{
//    UIView *topView = topViewController().view;
//    if (topView && _loadingView == nil) {
//        _loadingView = [CPGLoadingView showInView:topView];
//    }
    [self.sessionManager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithHTMLData:responseObject error:NULL];
//        [_loadingView hide];
        block(doc, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        [_loadingView hide];
        block(nil, error);
    }];
}

- (void)asyncRequestDataWith:(NSString *)url completeBlock:(void(^)(NSData *data, NSError *error))block
{
    [self.sessionManager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(nil, error);
        NSLog(@"%@", error);
    }];
}

 
- (void)configSessionManager
{
    NSURL *baseURL = [NSURL URLWithString:[self.class baseURL]];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer = serializer;
    _sessionManager = manager;
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}


//- (void)asyncRequestDocumentWith:(NSString *)url completeBlock:(void (^)(GDataXMLDocument *, NSError *))block
//{
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
//        if (connectionError) {
//            NSLog(@"%@", connectionError);
//            block(nil, connectionError);
//            return ;
//        }
//        NSError *error = NULL;
//        GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithHTMLData:data error:&error];
//        block(doc, error);
//    }];
//}

#pragma mark --

+ (NSString *)baseURL;
{
    return [[self sites] valueForKey:BIQUGE];
}

- (NSString *)site
{
    if (!_site) {
        _site = [BIQUGE copy];
    }
    return _site;
}

+ (instancetype)sharedInstance
{
    static FGRDataManager *dm = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dm = [[FGRDataManager alloc] init];
        [dm configSessionManager];
    });
    return dm;
}



// 通过plist 加载小说站点--
+ (NSDictionary *)sites
{
    static NSDictionary *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = @{@"笔趣阁": BQG_BASE_URL};
    });
    return dict;
}

+ (NSString *)fullURLWith:(NSString *)url site:(NSString *)site
{
    NSString *baseURL = self.sites[site];
    if ([url hasPrefix:@"http:"]) {
        return url;
    }
    return [url stringWithHeader:baseURL];
}

- (NSString *)fullURLWith:(NSString *)url
{
    return [self.class fullURLWith:url site:self.site];
}

@end


























