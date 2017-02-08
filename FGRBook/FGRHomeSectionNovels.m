//
//  FGRHomeSectionNovels.m
//  FGRBook
//
//  Created by fenggeren on 16/9/19.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRHomeSectionNovels.h"
#import "FGRNovelModel.h"

@implementation FGRHomeSectionNovels

- (instancetype)init
{
    if (self = [super init]) {
        self.contentOffset = CGPointZero;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.novels forKey:@"novels"];
    [aCoder encodeObject:self.typeName forKey:@"typeName"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init]) {
        self.novels = [aDecoder decodeObjectForKey:@"novels"];
        self.typeName = [aDecoder decodeObjectForKey:@"typeName"];
    }
    return self;
}

@end
