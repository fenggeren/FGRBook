//
//  FGRGlobalFunction.h
//  FGRBook
//
//  Created by fenggeren on 16/9/19.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT void threadPerform(BOOL mainThread, void(^block)());
FOUNDATION_EXPORT UIViewController *topViewController();
FOUNDATION_EXPORT void mainPerform(void(^block)());
