//
//  FGRReadOptionConfigController.h
//  CollectionViewAutoScroll
//
//  Created by HuanaoGroup on 16/11/1.
//  Copyright © 2016年 HuanaoGroup. All rights reserved.
//

#import "FGRBaseViewController.h"
#import "FGRReadOptionItem.h"

@interface FGRReadOptionConfigController : FGRBaseViewController

@property (nonatomic, strong) NSArray<NSString *> *names;
@property (nonatomic, assign) FGRReadOptionType optionType;
@property (nonatomic, copy) NSString *navTitle;

@property (nonatomic, copy) dispatch_block_t returnBlock;


@end
