//
//  FGRSearchWebController.m
//  FGRBook
//
//  Created by fenggeren on 2016/10/6.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRSearchWebController.h"
#import "FGRDataManager.h"
#import "FGRNovelViewController.h"
#import "FGRNovelModel.h"

@interface FGRSearchWebController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation FGRSearchWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@"http://zhannei.baidu.com/cse/search?s=287293036948159515&q="];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(clickReturn:)];
}

 
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = request.URL.absoluteString;
    if ([url containsString:BQG_BASE_URL]) {
        FGRNovelViewController *novelVC = [FGRNovelViewController controller];
        FGRNovelModel *novel = [[FGRNovelModel alloc] init];
        novel.url = url;
        novelVC.novelModel = novel;
        
        [self.navigationController pushViewController:novelVC animated:YES];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)clickReturn:(UIBarButtonItem *)item
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
//}
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    self.navigationController.navigationBarHidden = NO;
//}


@end
