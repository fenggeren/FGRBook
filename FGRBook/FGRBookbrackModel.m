//
//  FGRBookbrackModel.m
//  FGRBook
//
//  Created by fenggeren on 2016/10/16.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRBookbrackModel.h"
#import "FGRNovelModel.h"

@implementation FGRBookbrackModel

+ (NSArray<FGRBookbrackModel *> *)bookbrackModelsWith:(NSArray<FGRNovelModel *> *)novels
{
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:novels.count];
    
    for (FGRNovelModel *novel in novels) {
        [models addObject:[[self alloc] initWithNovel:novel]];
    }
    
    return models;
}

- (instancetype)initWithNovel:(FGRNovelModel *)novel
{
    if (self = [super init]) {
        self.select = NO;
        _novelModel = novel;
    }
    return self;
}

- (NSString *)imgURL
{
    return _novelModel.imgURL;
}

- (NSString *)name
{
    return _novelModel.name;
}

- (void)setSelect:(BOOL)select
{
    _select = select;
}

@end
