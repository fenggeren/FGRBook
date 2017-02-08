//
//  FGRBookrackViewController.m
//  FGRBook
//
//  Created by fenggeren on 2016/9/30.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRBookrackViewController.h"
#import "FGRBookrackCell.h"
#import "FGRBookrackManager.h"
#import <MJRefresh/MJRefresh.h>
#import "UIView+Sizes.h"
#import "FGRNovelReadController.h"
#import "FGRNovelModel.h"
#import "CPGLoadingView.h"
#import "FGRBookbrackModel.h"
#import "FGRBookrackBottomMenu.h"
#import "FGRBookrackDeleteActionView.h"
#import "FGRNavigationController.h"
#import "FGRSearchWebController.h"
#import "FGRInterstitialAD.h"
#import "FGRTimerAction.h"

@import GoogleMobileAds;

@interface FGRBookrackViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, FGRBookrackCellProtocol,
    GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray<FGRBookbrackModel *> *novelModels;

@property (nonatomic, assign, getter=isNovelsEditable) BOOL novelsEditable;

@property (nonatomic, strong) IBOutlet GADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerViewHeightConstraint;

@property (nonatomic, strong) FGRTimerAction *timer;
@end

@implementation FGRBookrackViewController
{
    __weak FGRBookrackBottomMenu *_bottomMenu;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.collectionView registerNib:[UINib nibWithNibName:@"FGRBookrackCell" bundle:nil] forCellWithReuseIdentifier:@"FGRBookrackCell"];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.novelsEditable = NO;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:BookrackAddBookNoti object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self updateShowData];
    }];
    
    CPGLoadingView *loadView = [CPGLoadingView showInView:self.view];
    [BookrackManager loadAllNovelComplete:^{
        [loadView hide];
        [self updateShowData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadData];
        });
    }];
    
    __weak __typeof(self)weakSelf = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
    
    self.bannerView.adUnitID = kADBannerID;
    self.bannerView.rootViewController = self;
    self.bannerView.backgroundColor = [UIColor redColor];
    self.bannerView.delegate = self;
    self.bannerViewHeightConstraint.constant = 0;
    
    self.timer = [FGRTimerAction timerActionWith:kInterstitialADShowDuration actionBlock:^{
        NSLog(@"---TIMER---");
        [FGRInterstitialAD showInController:weakSelf dismissBlock:^(NSError *err) {
            NSLog(@"---ADDAADDA---");
        }];
    }];
}

- (void)admob
{
    GADRequest *request = [GADRequest request];
    request.testDevices = @[
                            [[[UIDevice currentDevice] identifierForVendor] UUIDString],kGADSimulatorID
                            ];
    [self.bannerView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self admob];
    [self.timer valid];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timer invalid];
}

- (void)loadData
{
    [BookrackManager refreshData:^{
        [self updateShowData];
        [self.collectionView.mj_header endRefreshing];
    }];
}

- (void)updateShowData
{
    self.novelModels = [FGRBookbrackModel bookbrackModelsWith:BookrackManager.novelModels];
    [self.collectionView reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 

- (void)setNovelsEditable:(BOOL)novelsEditable
{
    _novelsEditable = novelsEditable;
    self.collectionView.allowsSelection = !novelsEditable;
    [self configBars];
}

- (void)configBars
{
    if (self.novelsEditable) {
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelSelect:)];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
        self.title = @"已选(1)";
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(selectAll:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        
        for (UIBarButtonItem *item in @[leftBarButtonItem, rightBarButtonItem]) {
            [item setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
        }
        
        UIView *superView = self.tabBarController.view;
        CGRect originalFrame = CGRectMake(0, superView.height, superView.width, self.tabBarController.tabBar.height);
        CGRect showFrame = originalFrame;
        showFrame.origin = CGPointMake(0, superView.height - showFrame.size.height);
        _bottomMenu = [FGRBookrackBottomMenu showInView:superView originalFrame:originalFrame showFrame:showFrame];
        __weak __typeof(self)weakSelf = self;
        [_bottomMenu setBtnClickBlock:^(FGRBookrackBottomMenuItemType itemType) {
            [weakSelf clickMenuItem:itemType];
        }];
    } else {
        [_bottomMenu hide];
        self.navigationItem.leftBarButtonItem = nil;
        self.title = @"书架";
        self.navigationItem.rightBarButtonItems = @[/*[[UIBarButtonItem alloc] initWithTitle:@"***" style:UIBarButtonItemStyleDone target:self action:@selector(clickMoreMenu:)],*/[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(clickSearch:)],];
    }
}

#pragma mark - Actions

- (void)clickMenuItem:(FGRBookrackBottomMenuItemType)itemType
{
    switch (itemType) {
        case FGRBookrackBottomMenuItemTypeDownload:
        {
            NSIndexSet *selectSet = [self selectedIndexPathsForCell];
            NSArray *novels = [self.novelModels objectsAtIndexes:selectSet];
            for (FGRBookbrackModel *model in novels) {
                [model.novelModel loadAllCompleteProgress:^(CGFloat progress) {
                    
                }];
            }
            [self cancelSelect:nil];
        }
            break;
        case FGRBookrackBottomMenuItemTypeDelete:
        {
            __weak __typeof(self)weakSelf = self;
            FGRBookrackDeleteActionView *actionView = [FGRBookrackDeleteActionView showInView:self.tabBarController.view clickBlock:^(NSInteger index) {
                if (index == 0) {
                    [weakSelf removeNovels];
                }
            }];
            NSIndexSet *selectSet = [self selectedIndexPathsForCell];
            actionView.lblTitle.text =[NSString stringWithFormat: @"已选%ld本书", selectSet.count];
        }
            break;
        default:
            break;
    }
}

- (void)removeNovels
{
    NSIndexSet *selectSet = [self selectedIndexPathsForCell];
    NSArray *novels = [self.novelModels objectsAtIndexes:selectSet];
    
    [BookrackManager removeNovels:[novels valueForKey:@"novelModel"]];
    self.novelModels = [FGRBookbrackModel bookbrackModelsWith:BookrackManager.novelModels];
    NSArray *indexPaths = [novels valueForKeyPath:@"indexPath"];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:indexPaths];
    } completion:^(BOOL finished) {
        self.novelsEditable = NO;
        [self.collectionView reloadData];
    }];
}

- (NSIndexSet *)selectedIndexPathsForCell
{
    return [self.novelModels indexesOfObjectsPassingTest:^BOOL(FGRBookbrackModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.select == YES;
    }];
}

- (void)cancelSelect:(UIBarButtonItem *)item
{
    self.novelsEditable = NO;
    [self.novelModels makeObjectsPerformSelector:@selector(setSelect:) withObject:@(NO)];
    [self.collectionView reloadData];
}
- (void)selectAll:(UIBarButtonItem *)item
{ 
    for (FGRBookbrackModel *bm in self.novelModels) {
        bm.select = YES;
    }
    [self.collectionView reloadData];
}

- (void)clickSearch:(UIBarButtonItem *)item
{
    FGRNavigationController *nav = [[FGRNavigationController alloc] initWithRootViewController:[FGRSearchWebController controller]];
    [self.navigationController presentViewController:nav animated:YES completion:^{
        
    }];
}

- (void)clickMoreMenu:(UIBarButtonItem *)item
{ 
}

#pragma mark -  BannerViewDeleget
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    self.bannerViewHeightConstraint.constant = 100;
    [UIView animateWithDuration:0.2 animations:^{
        [self.bannerView layoutIfNeeded];
    }];
}


#pragma mark - FGRBookrackCellDelegate

- (void)bookrackCellBeginEditing:(FGRBookrackCell *)cell
{
    self.novelsEditable = YES;
    [self.collectionView reloadData];
}
- (void)bookrackCell:(FGRBookrackCell *)cell didSelect:(BOOL)isSelect
{
    if (self.novelsEditable) {
        NSArray *result = [self.novelModels valueForKeyPath:@"isSelected"];
        NSInteger selectCount = [result indexesOfObjectsPassingTest:^BOOL(NSNumber *select, NSUInteger idx, BOOL * _Nonnull stop) {
            return select.boolValue == YES;
        }].count;
        self.title = [NSString stringWithFormat:@"已选(%@)", @(selectCount)];
    }
}


#pragma mark - DataSource & Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.novelModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FGRBookrackCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FGRBookrackCell" forIndexPath:indexPath];
    
    FGRBookbrackModel *model = self.novelModels[indexPath.item];
    model.indexPath = indexPath;
    cell.novelModel = model;
    [cell setEditable:self.isNovelsEditable];
    cell.delegate = self;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    FGRBookrackCell *rcell = (FGRBookrackCell *)cell;
    [rcell endDisplaying];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat lrM = 20;
    CGFloat mm = 10;
    NSInteger count = 3;
    CGFloat width =  (NSInteger)((collectionView.width - lrM * 2 - mm * (count - 1)) / count);
    CGFloat height = (NSInteger)(width * 2);
    CGSize size = CGSizeMake(width, height);
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 20, 20, 20);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FGRNovelModel *novel = self.novelModels[indexPath.item].novelModel;
    __weak __typeof(self)weakSelf = self;
    void (^read)() = ^{
        FGRNovelReadController *detailVC = [FGRNovelReadController controller];
        detailVC.novelModel = novel;
        detailVC.returnBlock = ^{ 
            [weakSelf.collectionView reloadData];
        };
        detailVC.hidesBottomBarWhenPushed = YES;
        [weakSelf.navigationController pushViewController:detailVC animated:YES];
    };
    
    if (novel.isLoadCompleted == NO) {
        [novel loadDataCompleteBlock:^(NSError *err) {
            read();
        }];
    } else {
        read();
    }
}


- (BOOL)supportSpanPop
{
    return NO;
}

@end
