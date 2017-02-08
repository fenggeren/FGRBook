//
//  FGRNavigationController.m
//  FGRBook
//
//  Created by fenggeren on 16/9/16.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRNavigationController.h"
#import "FGRNavigationPopProtocol.h"

@interface FGRNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation FGRNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

    id target = self.interactivePopGestureRecognizer.delegate;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:target action:NSSelectorFromString(@"handleNavigationTransition:")];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    self.interactivePopGestureRecognizer.enabled = NO;
}
    
    

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.visibleViewController conformsToProtocol:@protocol(FGRNavigationPopProtocol)]) {
        id<FGRNavigationPopProtocol> vc = (id<FGRNavigationPopProtocol>)self.visibleViewController;
        return [vc supportSpanPop];
    }
    return NO;
}


@end























