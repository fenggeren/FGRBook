//
//  FGRSearchViewController.m
//  FGRBook
//
//  Created by fenggeren on 2016/9/30.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRSearchViewController.h"
#import "UIView+Sizes.h"
#import "FGRSearchResultController.h"

@interface FGRSearchViewController () <UITextFieldDelegate>
{
    NSTimeInterval _updateInterval;
    NSTimer *_timer;
}
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, weak) FGRSearchResultController *searchResultController;

@property (strong, nonatomic) IBOutlet UIView *topView;

@end

@implementation FGRSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textField.delegate = self;
    self.textField.returnKeyType = UIReturnKeySearch;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldEdit:) name:UITextFieldTextDidChangeNotification object:self.textField];
    
    _updateInterval = INT_MAX;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (IBAction)clickCancel:(UIButton *)sender
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}




- (void)textFieldEdit:(NSNotification *)noti
{
    if (self.searchResultController && [noti.object text].length == 0) {
        [self.searchResultController hide];
    } else if (self.searchResultController == nil) {
        CGRect frame = self.view.bounds;
        frame.origin = CGPointMake(0, CGRectGetMaxY(self.topView.frame));
        self.searchResultController = [FGRSearchResultController showInController:self frame:frame];
    }
    
    
    if (self.searchResultController && [noti.object text].length > 0) {
        NSTimeInterval curT = CACurrentMediaTime();
        _updateInterval = curT;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (curT == _updateInterval) {
                [self.searchResultController updateKey:[noti.object text]];
            }
        });
    }
}


#pragma mark - 



@end
