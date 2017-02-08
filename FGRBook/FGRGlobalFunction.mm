//
//  FGRGlobalFunction.c
//  FGRBook
//
//  Created by fenggeren on 16/9/19.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRGlobalFunction.h"


void threadPerform(BOOL mainThread, void(^block)())
{
    if ([NSThread isMainThread] && mainThread) {
        block();
    } else {
        dispatch_async(mainThread ? dispatch_get_main_queue() :
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           block();
        });
    }
}

void mainPerform(void(^block)())
{
    threadPerform(YES, block);
}

UIViewController *topController(UIViewController *vc)
{
    if ([vc isKindOfClass:[UITabBarController class]]) {
        return topController([(UITabBarController *)vc selectedViewController]);
    } else if([vc isKindOfClass:[UINavigationController class]]) {
        return topController([(UINavigationController *)vc visibleViewController]);
    } else if (vc.presentingViewController) {
        return topController(vc.presentingViewController);
    } else {
        return vc;
    }
}

UIViewController *topViewController()
{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (vc == nil) {
        return nil;
    }
    return topController(vc);
}
