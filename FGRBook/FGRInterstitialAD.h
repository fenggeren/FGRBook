//
//  FGRInterstitialAD.h
//  FGRBook
//
//  Created by fenggeren on 2016/11/14.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FGRInterstitialAD : NSObject

+ (instancetype)showInController:(UIViewController *)controller dismissBlock:(void(^)(NSError *))block;

+ (instancetype)showInController:(UIViewController *)controller timeInterval:(NSInteger)duration repeats:(BOOL)repeat dismissBlock:(void(^)(NSError *))block;

- (void)cancelShow;
@end
