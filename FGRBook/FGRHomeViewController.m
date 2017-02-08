//
//  FGRHomeViewController.m
//  FGRBook
//
//  Created by fenggeren on 16/9/18.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRHomeViewController.h"
#import "FGRHomeData.h"
#import "FGRNovelModel.h" 
#import "FGRDataManager.h"
#import "FGRHomeTableViewCell.h"
#import <MJRefresh/MJRefresh.h>
#import "FGRNovelViewController.h"
#import "FGRSearchViewController.h"
#import "FGRNavigationController.h"
#import "FGRSearchWebController.h"
#import "FGRCollectionViewDataSource.h"
#import "Masonry/Masonry.h"

@import GoogleMobileAds;

@interface FGRHomeViewController () <UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *bannerContainer;
@property (nonatomic, strong) FGRHomeData *homeModel;
//@property (nonatomic, strong) FGRIndexBannerDataSource *bannerDataSource;
@property (nonatomic, strong) FGRCollectionViewDataSource *dataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerViewHeightConstraint;

@end

@implementation FGRHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"精选";
    
    self.homeModel = [[FGRHomeData alloc] init];
    self.tableView.rowHeight = 205;
    self.tableView.separatorInset = UIEdgeInsetsMake(-1, -20, -1, 0);
    self.tableView.separatorColor = [UIColor lightGrayColor];
    
    [self configBanner];
    
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    FGRHomeData *homeData = [FGRHomeData homeDataFromCached];
    if (homeData) {
        self.homeModel = homeData;
        [self showData];
    } else {
        __weak typeof(self)weakself = self;
        [self.homeModel loadDataComplete:^(NSError *err) {
            [weakself showData];
            [weakself.homeModel cache];
        }];
    }
    
    [self loadData];
    
    self.bannerView.adUnitID = kADBannerID;
    self.bannerView.rootViewController = self;
    self.bannerView.backgroundColor = [UIColor redColor];
    self.bannerView.delegate = self;
    self.bannerViewHeightConstraint.constant = 0;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    FGRCollectionViewLayout *collectionViewLayout = (FGRCollectionViewLayout *)self.bannerContainer.collectionViewLayout;
    CGSize size = self.bannerContainer.bounds.size;
    
    collectionViewLayout.itemSize = CGSizeMake(size.width * 0.4, size.height * 0.7);
    collectionViewLayout.minimumLineSpacing = 20;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
}

- (void)admob
{
    GADRequest *request = [GADRequest request];
    request.testDevices = @[
                            [[[UIDevice currentDevice] identifierForVendor] UUIDString],kGADSimulatorID
                            ];
    [self.bannerView loadRequest:request];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     [self.dataSource startAutoScroll];
    [self admob];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.dataSource stopAutoScroll];
}

- (void)loadData
{
    __weak typeof(self)weakself = self;
    [self.homeModel loadDataComplete:^(NSError *err) {
//        [weakself showData];
        [weakself.homeModel cache];
    }];
}

- (void)showData
{
    self.dataSource.models = self.homeModel.bannerModels;
    [self.bannerContainer reloadData];
    [self.tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataSource startAutoScroll];
        [self.bannerContainer scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataSource.models.count inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    });
    [self.tableView.mj_header endRefreshing];
}

- (void)configBanner
{

    self.dataSource = [[FGRCollectionViewDataSource alloc] init];
    [self.dataSource configCollectionView:self.bannerContainer];
    __weak typeof(self)weakself = self;
    self.dataSource.didSelectedCell = ^(NSIndexPath *indexPath, FGRNovelModel *novel) {
        [DataManager chaptersWithNovel:novel completeBlock:^(NSArray *chapters) {
            novel.chapters = chapters;
            novel.curIndex = 0;
            FGRNovelViewController *detailVC = [FGRNovelViewController controller];
            detailVC.novelModel = novel;
            [weakself.navigationController pushViewController:detailVC animated:YES];
        }];
    };
}


#pragma mark -  BannerViewDeleget
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    self.bannerViewHeightConstraint.constant = 100;
    [UIView animateWithDuration:0.2 animations:^{
        [self.bannerView layoutIfNeeded];
    }];
}



#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.homeModel.sectionModels.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FGRHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(FGRHomeTableViewCell.class) forIndexPath:indexPath];
    cell.sectionNovels = self.homeModel.sectionModels[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    FGRHomeTableViewCell *initCell = (FGRHomeTableViewCell *)cell;
    [initCell afterShowConfig];
}

#pragma mark - Action

- (IBAction)search:(UIBarButtonItem *)sender {
//    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:[FGRSearchViewController controller]];
    
    
    FGRNavigationController *nav = [[FGRNavigationController alloc] initWithRootViewController:[FGRSearchWebController controller]];
//    UIViewController *vc = [FGRSearchViewController controller];
    [self.navigationController presentViewController:nav animated:YES completion:^{
        
    }];
}

- (BOOL)supportSpanPop
{
    return NO;
}
@end
