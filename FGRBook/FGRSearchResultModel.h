//
//  FGRSearchResultModel.h
//  FGRBook
//
//  Created by fenggeren on 2016/10/5.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FGRNovelModel;

extern NSString * AFPercentEscapedStringFromString(NSString *string);

@interface FGRSearchResultModel : NSObject

@property (nonatomic, strong) NSArray<FGRNovelModel *> *novelModels;



- (void)loadDataWithKey:(NSString *)searchKey completeBlock:(dispatch_block_t)block;

@end
