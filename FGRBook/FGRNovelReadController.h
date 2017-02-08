//
//  FGRNovelReadController.h
//  FGRBook
//
//  Created by fenggeren on 2016/9/24.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRBaseViewController.h"

@class FGRNovelModel;

@interface FGRNovelReadController : FGRBaseViewController

@property (nonatomic, strong) FGRNovelModel *novelModel;

@property (nonatomic, copy) void (^returnBlock)();

@end
