//
//  FGRHomeData.m
//  FGRBook
//
//  Created by fenggeren on 16/9/18.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRHomeData.h"
#import "GDataXMLNode.h"
#import "FGRDataManager.h"
#import "FGRNovelModel.h"
#import "FGRHomeSectionNovels.h"



@interface FGRHomeData()

@end


@implementation FGRHomeData

NSString * homeCachedFile()
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *homeFile = [docPath stringByAppendingPathComponent:@"homeData"];
    return homeFile;
}

- (void)cache
{

    if (self.sectionModels == nil || self.sectionModels.count == 0 ||
        self.bannerModels == nil || self.bannerModels.count == 0) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([NSKeyedArchiver archiveRootObject:self toFile:homeCachedFile()]) {
            NSLog(@"---首页保存成功——");
        } else {
            NSLog(@"---首页保存失败——");
        }
    });
}

+ (instancetype)homeDataFromCached
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:homeCachedFile()];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.bannerModels forKey:@"bannerModels"];
    [aCoder encodeObject:self.sectionModels forKey:@"sectionModels"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.bannerModels = [aDecoder decodeObjectForKey:@"bannerModels"];
        self.sectionModels = [aDecoder decodeObjectForKey:@"sectionModels"];
    }
    return self;
}



NSString *trimHeadTail(NSString *str)
{
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)loadDataComplete:(void (^)(NSError *))block
{
    [DataManager asyncRequestDocumentWith:BQG_BASE_URL completeBlock:^(GDataXMLDocument *docu, NSError *error) {
        if (error == nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self parseBanners:docu];
                [self parseSections:docu];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(error);
                });
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error);
            });
        }
    }];
}

- (void)parseBanners:(GDataXMLDocument *)docu
{
    NSArray *nodes = [docu nodesForXPath:@"//*[@id='hotcontent']//div[@class='item']" error:NULL];
    NSMutableArray *models = [NSMutableArray array];
    for (GDataXMLElement *ele in nodes) {
        FGRNovelModel *novel = [[FGRNovelModel alloc] init];
        
        GDataXMLElement *imgEle = (GDataXMLElement *)[ele firstNodeForXPath:@"*[@class='image']/a" error:NULL];
        novel.imgURL = [[imgEle firstNodeForXPath:@"img/@src" error:NULL] stringValue];
        
        GDataXMLElement *dlEle = (GDataXMLElement *)[ele firstNodeForXPath:@"dl" error:NULL];
        novel.author = [[[dlEle firstNodeForXPath:@"dt/span" error:NULL] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        novel.url = [[dlEle firstNodeForXPath:@"dt/a/@href" error:NULL] stringValue];
        novel.name = [[[dlEle firstNodeForXPath:@"dt/a" error:NULL] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        novel.briefIntroduction = [[[dlEle firstNodeForXPath:@"dd" error:NULL] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [models addObject:novel];
    }
    self.bannerModels = models;
}

- (void)parseSections:(GDataXMLDocument *)doc
{
    NSArray *nodes1 = [doc nodesForXPath:@"//div[@class='content'] | //div[@class='content border']" error:NULL];
    
    NSMutableArray *sections = [NSMutableArray array];
    for (GDataXMLElement *section in nodes1) {
        FGRHomeSectionNovels *sectionNovels = [[FGRHomeSectionNovels alloc] init];
        sectionNovels.typeName = trimHeadTail([[section firstNodeForXPath:@"h2" error:NULL] stringValue]);
        NSMutableArray *novels = [[NSMutableArray alloc] init];
        NSArray *novelsNode = [section nodesForXPath:@"ul/li" error:NULL];
        for (GDataXMLElement *nvlNode in novelsNode) {
            FGRNovelModel *novel = [[FGRNovelModel alloc] init];
            novel.url = [[nvlNode firstNodeForXPath:@"a/@href" error:NULL] stringValue];
            novel.name = trimHeadTail([[nvlNode firstNodeForXPath:@"a" error:NULL] stringValue]);
            novel.type = sectionNovels.typeName;
            novel.author = trimHeadTail([[nvlNode stringValue] componentsSeparatedByString:@"/"].lastObject);
            
            [novels addObject:novel];
        }
        sectionNovels.novels = novels;
        [sections addObject:sectionNovels];
    }
    self.sectionModels = sections;
}



@end




























