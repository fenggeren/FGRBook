//
//  FGRSearchResultController.h
//  FGRBook
//
//  Created by fenggeren on 2016/10/5.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FGRSearchResultController : UITableViewController

+ (instancetype)showInController:(UIViewController *)vc frame:(CGRect)frame;

- (void)hide;

- (void)updateKey:(NSString *)searchKey;

@end
