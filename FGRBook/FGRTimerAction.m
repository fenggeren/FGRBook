//
//  FGRTimerAction.m
//  FGRBook
//
//  Created by fenggeren on 2016/11/15.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRTimerAction.h"
#import "ASWeakProxy.h"


@interface FGRTimerAction()

@property (nonatomic, copy) dispatch_block_t action;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval actionTime;

@property (nonatomic, strong) NSTimer *timer;
@end

@implementation FGRTimerAction
{
    BOOL _valid;
}
//static NSMutableSet *validTimeActions;
//static NSMutableSet *invalidTimeActions;
//+ (void)initialize
//{
//    validTimeActions = [NSMutableSet set];
//    invalidTimeActions = [NSMutableSet set];
//}
//
//+ (instancetype)timerAction
//{
//    FGRTimerAction *action = nil;
//    if (validTimeActions.count == 0) {
//      
//    }
//    return action;
//}

+ (instancetype)timerActionWith:(NSTimeInterval)duration actionBlock:(dispatch_block_t)block
{
    FGRTimerAction *timer = [[self alloc] init];
    timer.action = block;
    timer.duration = duration;
    return timer;
}


- (instancetype)init
{
    if (self = [super init]) {
        [self config];
    }
    return self;
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}



- (void)config
{
    _valid = YES;
    self.actionTime = self.duration + CACurrentMediaTime();
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(checking) userInfo:nil repeats:YES];
}

- (void)checking
{
    NSTimeInterval curTime = CACurrentMediaTime();
    if (curTime > self.actionTime) {
        NSLog(@"--------%@----%@--", @(curTime), @(self.actionTime));
        self.actionTime = curTime + self.duration;
        if (self.action && _valid) {
            self.action();
        }
    }
}

- (void)invalid
{
    _valid = NO;
}
- (void)valid
{
    _valid = YES;
    [self checking];
}

@end










