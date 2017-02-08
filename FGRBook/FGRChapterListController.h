//
//  FGRChapterListController.h
//  FGRBook
//
//  Created by fenggeren on 16/9/16.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRBaseViewController.h"

@class FGRNovelModel;

@interface FGRChapterListController : FGRBaseViewController

@property (nonatomic, strong) FGRNovelModel *novelModel;



@property (nonatomic, copy) BOOL (^selectBlock)(NSInteger index);

@end
