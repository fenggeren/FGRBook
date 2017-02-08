//
//  FGRTimerAction.h
//  FGRBook
//
//  Created by fenggeren on 2016/11/15.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FGRTimerAction : NSObject

+ (instancetype)timerActionWith:(NSTimeInterval)duration actionBlock:(dispatch_block_t)block;

- (void)checking;

- (void)invalid;
- (void)valid;

@end
