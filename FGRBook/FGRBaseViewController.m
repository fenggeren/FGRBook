//
//  FGRBaseViewController.m
//  FGRBook
//
//  Created by fenggeren on 16/9/16.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRBaseViewController.h"

@interface FGRBaseViewController ()

@end

@implementation FGRBaseViewController



+ (instancetype)controller
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass(self.class)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(popAction)];
}

- (void)popAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)supportSpanPop
{
    return YES;
}


@end
