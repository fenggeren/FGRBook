//
//  FGRInterstitialAD.m
//  FGRBook
//
//  Created by fenggeren on 2016/11/14.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRInterstitialAD.h"
#import "FGRTimerAction.h"
@import GoogleMobileAds;

@interface FGRInterstitialAD () <GADInterstitialDelegate>
{
    BOOL _showAD;
}
@property (nonatomic, weak) UIViewController *showingController;

@property (nonatomic, copy) void (^dismissBlock)(NSError *err);

@property(nonatomic, strong) GADInterstitial *interstitial;

@property (nonatomic, strong) FGRTimerAction *timer;
@end

@implementation FGRInterstitialAD

+ (instancetype)sharedInstance
{
    static FGRInterstitialAD *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)showInController:(UIViewController *)controller timeInterval:(NSInteger)duration repeats:(BOOL)repeat dismissBlock:(void(^)(NSError *))block
{
    FGRInterstitialAD *ad = [self sharedInstance];
    ad.dismissBlock = block;
    ad.showingController = controller;
    ad.timer = [FGRTimerAction timerActionWith:duration actionBlock:^{
        [ad config];
    }];
    return ad;
}

+ (instancetype)showInController:(UIViewController *)controller dismissBlock:(void (^)(NSError *))block
{
    FGRInterstitialAD *ad = [self sharedInstance];
    ad.dismissBlock = block;
    ad.showingController = controller;
    [ad config];
    return ad;
}

- (instancetype)init
{
    if (self = [super init]) {

    }
    return self;
}

- (void)config
{
    _showAD = YES;
    self.interstitial =
    [[GADInterstitial alloc] initWithAdUnitID:kADInterstitialID];
    self.interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ kGADSimulatorID, @"2077ef9a63d2b398840261c8221a0c9a" ];
    [self.interstitial loadRequest:request];
}

- (void)cancelShow
{
    
}

#pragma mark - GADInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    if (_showAD && self.showingController) {
#ifndef DEBUG
        [self.interstitial presentFromRootViewController:self.showingController];
#endif
    } else {
        [self purge];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self purge];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"%@", self);
        });
    });
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    [self purge];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    if (self.dismissBlock) {
        self.dismissBlock(nil);
        self.dismissBlock = nil;
        [self purge];
    }
}

- (void)interstitialDidFailToPresentScreen:(GADInterstitial *)ad
{
    if (self.dismissBlock) {
        NSError *err = [NSError errorWithDomain:@"广告小时错误" code:204 userInfo:nil];
        self.dismissBlock(err);
        self.dismissBlock = nil;
    }
}

#pragma mark - 

- (void)purge
{
    self.dismissBlock = nil;
    if (self.interstitial) {
        // 无效
//        [self.interstitial presentFromRootViewController:nil];
    }
}

@end
