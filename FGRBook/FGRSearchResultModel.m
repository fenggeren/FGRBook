//
//  FGRSearchResultModel.m
//  FGRBook
//
//  Created by fenggeren on 2016/10/5.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRSearchResultModel.h"
#import "FGRDataManager.h"
#import "GDataXMLNode.h"
#import "FGRNovelModel.h"
#import "FGRChapterInfoModel.h"
#import "NSString+FGRExtension.h"

@interface FGRSearchResultModel ()
{
    NSString *_searchKey;
}

@end



@implementation FGRSearchResultModel




#pragma mark -
 
- (void)loadDataWithKey:(NSString *)searchKey completeBlock:(dispatch_block_t)block
{
    if ([_searchKey isEqualToString:searchKey]) {
        return;
    }
    
    _searchKey = [searchKey copy];
    NSString *url = [NSString stringWithFormat:@"http://zhannei.baidu.com/cse/search?s=287293036948159515&q=%@", AFPercentEscapedStringFromString(searchKey)];
    [DataManager asyncRequestDocumentWith:url completeBlock:^(GDataXMLDocument *docu, NSError *error) {
        NSArray *list = [docu nodesForXPath:@"//*[@id='results']//div[@class='result-item result-game-item']" error:NULL];
        
        NSMutableArray *novels = [NSMutableArray array];
        for (GDataXMLElement *novel in list) {
            FGRNovelModel *model = [[FGRNovelModel alloc] init];
            
            GDataXMLElement *imgEle = (GDataXMLElement *)[novel firstNodeForXPath:@"*/div[@class='result-game-item-pic']/img/@src" error:NULL];
            model.imgURL = [imgEle stringValue];
            
            // 详细信息列表
            GDataXMLElement *detailEle = (GDataXMLElement *)[novel firstNodeForXPath:@"*/div[@class='result-game-item-detail']" error:NULL];
            NSString *name = [[detailEle firstNodeForXPath:@"h3" error:NULL] stringValue];
            name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
            model.name = [name stringTrimHeaderTail];
            model.briefIntroduction = [[detailEle firstNodeForXPath:@"p" error:NULL] stringValue];
            
            NSArray *infoList = [detailEle nodesForXPath:@"div[@class='result-game-item-info']/p[@class='result-game-item-info-tag']" error:NULL];
            
            [self configInfoList:infoList model:model];
            [novels addObject:model];
        }
        self.novelModels = novels;
        
        block();
    }];
}


- (void)configInfoList:(NSArray *)eles model:(FGRNovelModel *)model
{
    for (GDataXMLElement *ele in eles) {
        NSString *title = [[ele firstNodeForXPath:@"span[1]" error:NULL] stringValue];
        NSString *value = [[ele firstNodeForXPath:@"span[2]" error:NULL] stringValue];
        value = [value stringTrimHeaderTail];
        if ([title containsString:@"作者"]) {
            model.author = value;
        } else if ([title containsString:@"类型"]) {
            model.type = value;
        } else if ([title containsString:@"更新时间"]) {
            model.updateDate = value;
        } else if ([title containsString:@"最新章节"]) {
            FGRChapterInfoModel *chapter = [[FGRChapterInfoModel alloc] init];
            chapter.name = value;
            chapter.url = nil;
            chapter.novelModel = model;
        }

    }
}

@end






















