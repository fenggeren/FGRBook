//
//  FGRSearchResultController.m
//  FGRBook
//
//  Created by fenggeren on 2016/10/5.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRSearchResultController.h"
#import "FGRSearchResultModel.h"
#import "FGRSearchResultCell.h"
#import "FGRNovelViewController.h"
#import "FGRDataManager.h"

@interface FGRSearchResultController () <UIWebViewDelegate>
{
    UIViewController *_superVC;
}
@property (nonatomic, strong) FGRSearchResultModel *resultModel;

@property (nonatomic, strong) UIWebView *webView;

@end


@implementation FGRSearchResultController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    self.resultModel = [[FGRSearchResultModel alloc] init];
    
    self.tableView.rowHeight = 80;
    [self.tableView registerNib:[UINib nibWithNibName:@"FGRSearchResultCell" bundle:nil] forCellReuseIdentifier:@"FGRSearchResultCell"];
}

#pragma mark - 



+ (instancetype)showInController:(UIViewController *)vc frame:(CGRect)frame
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FGRSearchResultController *search = [sb instantiateViewControllerWithIdentifier:@"FGRSearchResultController"];
    
    [vc addChildViewController:search];
    [vc.view addSubview:search.view];
    search.view.frame = frame;
    
    search->_superVC = vc;
    
    return search;
}

- (void)hide
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)updateKey:(NSString *)searchKey
{
    UIWebView *wv = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:wv];
    NSString *url = [NSString stringWithFormat:@"http://zhannei.baidu.com/cse/search?s=287293036948159515&q=%@", AFPercentEscapedStringFromString(@"我")];
    [wv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    wv.delegate = self;
 
    
    return;
    __weak __typeof(self)weakSelf = self;
    [self.resultModel loadDataWithKey:searchKey completeBlock:^{
        [weakSelf.tableView reloadData];
    }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultModel.novelModels.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FGRSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FGRSearchResultCell" forIndexPath:indexPath];
    
    cell.novelModel = self.resultModel.novelModels[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FGRNovelModel *novel = self.resultModel.novelModels[indexPath.row];
    FGRNovelViewController *novelVC = [FGRNovelViewController controller];
    novelVC.novelModel = novel;

    [_superVC.navigationController pushViewController:novelVC animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

#pragma mark -


- (UIWebView *)webView
{
    if (!_webView) {
        UIWebView *wv = [[UIWebView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:wv];
        NSString *url = [NSString stringWithFormat:@"http://zhannei.baidu.com/cse/search?s=287293036948159515&q=%@", AFPercentEscapedStringFromString(@"我")];
        [wv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        wv.delegate = self;
    }
    return _webView;
}


@end
















