//
//  AppDelegate.m
//  FGRBook
//
//  Created by fenggeren on 16/9/13.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "AppDelegate.h"
#import "FGRHomeViewController.h"
#import "FGRNavigationController.h"
#import "FGRTabBarController.h"
#import "UIImage+FGRExtension.h"
#import "UIColor+FGRExtension.h"
#import "UMMobClick/MobClick.h"
#import "GoogleMobileAds.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.window.rootViewController = [sb instantiateViewControllerWithIdentifier:@"FGRTabBarController"];
    [self.window makeKeyAndVisible];
    
    
    [self configNaviBar];
    [self configUMeng];
    [self configADMob];
    [self configNetwork];
    
    return YES;
}

- (void)configNaviBar
{
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    item.tintColor = [UIColor whiteColor];
    
    UINavigationBar *navBar = [UINavigationBar appearance];
    navBar.tintColor = [UIColor whiteColor];
    navBar.barTintColor = [UIColor colorWithNodecimalRed:212 green:59 blue:51 alpha:1.];
    navBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
}

- (void)configUMeng
{
    UMConfigInstance.appKey = kUMengKey;
    [MobClick startWithConfigure:UMConfigInstance];
}


- (void)configADMob
{
    [GADMobileAds configureWithApplicationID:kADAppID];
}

- (void)configNetwork
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [self alertNoNetwork:status];
    }];
}

- (void)alertNoNetwork:(AFNetworkReachabilityStatus)status
{
    if (status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown) {
        [MBProgressHUD bwm_showTitle:@"您的网络已断开，只能阅读已缓存的章节。" toView:self.window hideAfter:4. msgType:BWMMBProgressHUDMsgTypeError];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self alertNoNetwork:[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus];
    });
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
