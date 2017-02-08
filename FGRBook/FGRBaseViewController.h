//
//  FGRBaseViewController.h
//  FGRBook
//
//  Created by fenggeren on 16/9/16.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGRNavigationPopProtocol.h"


@interface FGRBaseViewController : UIViewController <FGRNavigationPopProtocol>

+ (instancetype)controller;
 
- (void)popAction;
@end
