//
//  FGRNovelReadController.m
//  FGRBook
//
//  Created by fenggeren on 2016/9/24.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRNovelReadController.h"
#import "FGRNovelShowManager.h"
#import "FGRPageView.h"
#import "FGRNovelModel.h"
#import "UIColor+FGRExtension.h"
#import "UIImage+FGRExtension.h"
#import "FGRChapterListController.h"
#import "FGRNovelReadBottomMenu.h"
#import "FGRReadProgressView.h"
#import "UIView+Sizes.h"
#import "FGRReadBottomShowView.h"
#import "FGRReadNovelMoreMenu.h"
#import "CPGLoadingView.h"
#import "FGRBookrackManager.h"
#import "FGRBottomMenuController.h"
#import "FGROptionManager.h"

#import "FGRInterstitialAD.h"
#import "FGRTimerAction.h"

@interface FGRNovelReadController () <FGRNovelReadBottomMenuProtocol, FGRReadProgressViewProtocol, FGRReadBottomShowViewProtocol,
    FGRReadNovelMoreMenuProtocol, UIGestureRecognizerDelegate, FGRBottomMenuControllerProtocol>
{
    __weak FGRReadProgressView *_bottomProgressView;
    __weak FGRReadBottomShowView *_bottomShowView;
    __weak FGRReadNovelMoreMenu *_moreMenu;
    __weak FGRBottomMenuController *_menuController;
}

@property (nonatomic, strong) FGRNovelShowManager *showManager;
@property (nonatomic, weak) IBOutlet FGRPageView *pageView;

@property (nonatomic, strong) FGRChapterListController *listController;
@property (nonatomic, strong) FGRNovelReadBottomMenu *bottomMenu;

@property (nonatomic, strong) UIView *alphaView;

@property (weak, nonatomic) IBOutlet UILabel *lblChapterTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblChapterProgress;
@property (weak, nonatomic) IBOutlet UILabel *lblNovelPercent;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;


@property (nonatomic, strong) NSArray *moreMenuItems;

@property (nonatomic, strong) FGRTimerAction *timerAction;
@end

@implementation FGRNovelReadController
{
    NSTimer *_timer;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [FGROptionManager sharedInstance].readBgColor;
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"***" style:UIBarButtonItemStyleDone target:self action:@selector(moreMenu)],[[UIBarButtonItem alloc] initWithTitle:@"下载" style:UIBarButtonItemStyleDone target:self action:@selector(download)]];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFormateShow) name:FGRReadTextShowChangeNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appTerminate) name:UIApplicationWillTerminateNotification object:nil];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    [leftSwipe requireGestureRecognizerToFail:tapGesture];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];
    [rightSwipe requireGestureRecognizerToFail:tapGesture];
    
    self.novelModel.update = NO;
    [self pageView];
    
    __weak __typeof(self)weakSelf = self;
    self.timerAction = [FGRTimerAction timerActionWith:kInterstitialADShowDuration actionBlock:^{
        NSLog(@"---TIMER---");
        [FGRInterstitialAD showInController:weakSelf dismissBlock:^(NSError *err) {
            NSLog(@"---ADDAADDA---");
        }];
    }];
}

+ (NSString *)currentTime
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm";
    });
    return [formatter stringFromDate:[NSDate date]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CPGLoadingView *loadView = [CPGLoadingView showInView:self.view];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self showManager];
        mainPerform(^{
            [self showCurrentPageComplete:nil];
            [loadView hide];
        });
    });
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIImage *colorImg = [UIImage imageWithColor:[UIColor blackColor] alpha:0.8];
    [self.navigationController.navigationBar setBackgroundImage:colorImg forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
    [self startTime];
    [self.timerAction checking];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UINavigationBar *navBar = [UINavigationBar appearance];
    
    self.navigationController.navigationBar.barStyle = navBar.barStyle;
    [self.navigationController.navigationBar setBackgroundImage:navBar.backIndicatorImage forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = navBar.tintColor;
    self.navigationController.navigationBar.barTintColor = navBar.barTintColor;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        CGRect frame = self.bottomMenu.frame;
        self.bottomMenu.frame = CGRectOffset(frame, 0, frame.size.height);
    }];
    
    [self stopTime];
}


- (void)dealloc
{ 
    if ([self.showManager hasCachedDisk]) {
        [self.showManager cacheNovelDisk];
    }
    if (self.returnBlock) {
        self.returnBlock();
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)supportSpanPop
{
    return NO;
}

#pragma mark - 

- (void)timeHandle
{
    self.lblTime.text = [self.class currentTime];
}

- (void)startTime
{
    [self stopTime];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(timeHandle) userInfo:nil repeats:YES];
}
- (void)stopTime
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)appTerminate
{
    if ([self.showManager hasCachedDisk]) {
        [self.showManager cacheNovelDisk];
    }
}

- (void)updateFormateShow
{
    [self.showManager formate];
    [self showCurrentPageComplete:nil];
}

- (void)download
{
    [BookrackManager addNovel:self.novelModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:BookrackAddBookNoti object:self userInfo:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.novelModel loadAllCompleteProgress:^(CGFloat progress) {
            
        }];
    });
}

- (void)moreMenu
{
    if (_moreMenu) {
        [_moreMenu dismiss];
    } else {
        _moreMenu = [FGRReadNovelMoreMenu showInView:self.view delegate:self];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.isNavigationBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)tapClick:(UITapGestureRecognizer *)tap {
    
    if (tap.state == UIGestureRecognizerStateEnded) {
        CGFloat tapX = [tap locationInView:self.pageView].x;
        CGFloat width = CGRectGetWidth(self.pageView.bounds) * 0.5;
        
        
        if (tapX < (CGRectGetWidth(self.pageView.bounds) - width) * 0.5) {
            // 左翻页
            [self leftFlipPage];
        } else if (tapX > ((CGRectGetWidth(self.pageView.bounds) - width) * 0.5) + width) {
            // 右翻页
            [self rightFlipPage];
        } else {
            // 唤起/隐藏操作栏
            if (self.navigationController.navigationBarHidden) {
                [self showMenus];
            } else {
                [self hideMenus];
            }
        }
    }
}

- (void)swipeGesture:(UISwipeGestureRecognizer *)swip
{
    if (swip.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self rightFlipPage];
    } else if (swip.direction == UISwipeGestureRecognizerDirectionRight) {
        [self leftFlipPage];
    }
}



#pragma mark --

- (void)showMenus
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (_menuController == nil) {
        FGRBottomMenuController *menuVC = [FGRBottomMenuController bottomMenuController];
        menuVC.menuDelegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:menuVC];
        [self addChildViewController:nav];
        nav.view.frame = self.view.bounds;
        [self.view addSubview:nav.view];
        _menuController = menuVC;
    }
    [_menuController show];
    
}

- (void)hideMenus
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
    [self hideBottomMenu];
}

- (void)hideBottomMenu
{
    if (_menuController) {
        [_menuController dismissComplete:nil];
    }
    
    if (_moreMenu) {
        [_moreMenu dismiss];
    }
}

#pragma mark -

- (void)leftFlipPage
{
    __weak __typeof(self)weakSelf = self;
    [self.showManager prePage:^(FGRPage *page) {
        if (page) {
            weakSelf.pageView.page = page;
            [weakSelf showMarkLabels];
        } else {
             // TODO. 前面没有了~
            NSLog(@"---前面没有了~--");
        }
    }];
}

- (void)rightFlipPage
{
    __weak __typeof(self)weakSelf = self;
    [self.showManager nextPage:^(FGRPage *page) {
        if (page) {
            weakSelf.pageView.page = page;
            [weakSelf showMarkLabels];
        } else {
            // TODO. 后面没有了~
            NSLog(@"---已经看完了----");
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

- (void)showCurrentPageComplete:(dispatch_block_t)block
{
    __weak __typeof(self)weakSelf = self;
    [self.showManager curPage:^(FGRPage *page) {
        weakSelf.pageView.page = page;
        [weakSelf showMarkLabels];
        if (block) {
            block();
        }
    }];
}

- (void)showMarkLabels
{
    self.lblChapterTitle.text = self.showManager.chapterTitle;
//    self.title = self.showManager.chapterTitle;
    CGFloat readPercent = self.showManager.readPercent;
    readPercent = readPercent >= 0 ? readPercent : 0;
    self.lblNovelPercent.text = [NSString stringWithFormat:@"%.1f%%", readPercent * 100];
    self.lblChapterProgress.text = self.showManager.indexStr;
}


#pragma mark - Delegate

#pragma mark - FGRBottomMenuControllerProtocol

- (FGRNovelShowManager *)showManagerForMenuController:(FGRBottomMenuController *)menuController
{
    return self.showManager;
}

- (void)menuController:(FGRBottomMenuController *)menuController selectIndexChapter:(NSInteger)index atCatalogController:(FGRChapterListController *)listController
{
    [self hideMenus];
    self.showManager.chapterIndex = index;
    [self showCurrentPageComplete:nil];
}

- (UINavigationController *)navigationControllerForCatalogController:(FGRChapterListController *)listController menuController:(FGRBottomMenuController *)menuController
{
    return self.navigationController;
}
#pragma mark - FGRReadNovelMoreMenuProtocol

- (NSArray<FGRReadNovelMoreMenuItem *> *)menuItemsInReadNovelMoreMenu:(FGRReadNovelMoreMenu *)menu
{
    return self.moreMenuItems;
}

#pragma mark UIGestureDelegate


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return touch.view == self.pageView || touch.view == self.view;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_menuController) {
        [self hideMenus];
    }
}

#pragma mark FGRNovelReadBottomMenuProtocol
- (void)clickMenu:(FGRNovelReadBottomMenu *)menu typeForItem:(FGRNovelReadBottomMenuType)menuType
{
    switch (menuType) {
        case FGRNovelReadBottomMenuTypeCatalog:
            if (self.novelModel.hasLoaded == NO) {
                [MBProgressHUD bwm_showTitle:@"没有该小说记录,请前往起点阅读-!" toView:self.view hideAfter:1.5];
            } else {
                [self.navigationController pushViewController:self.listController animated:YES];
            }
            break;
        case FGRNovelReadBottomMenuTypeProgress:
        {
            [self hideBottomMenu];
            _bottomProgressView = [FGRReadProgressView showInView:self.view title:self.showManager.chapterTitle percent:self.showManager.readPercent andDelegate:self];
        }
        break;
            
        case FGRNovelReadBottomMenuTypeOptions:
        {
            [self hideBottomMenu];
        }
            break;
            
        case FGRNovelReadBottomMenuTypeShow:
        {
            [self hideBottomMenu];
            _bottomShowView = [FGRReadBottomShowView showInView:self.view andDelegate:self];
        }
        break;
            
        case FGRNovelReadBottomMenuTypeComment:
            break;
        default:
            break;
    }
}

#pragma mark FGRReadProgressViewProtocol
- (void)nextChapterProgressView:(FGRReadProgressView *)progressView
{
    [self.showManager nextChapter];
    [self showCurrentPageComplete:^{
        _bottomProgressView.percent = self.showManager.readPercent;
        _bottomProgressView.lblTitle.text = self.showManager.chapterTitle;
    }];
}
- (void)previousChapterProgressView:(FGRReadProgressView *)progressView
{
    [self.showManager previousChapter];
    [self showCurrentPageComplete:^{
        _bottomProgressView.percent = self.showManager.readPercent;
        _bottomProgressView.lblTitle.text = self.showManager.chapterTitle;
    }];

}

- (void)readProgressView:(FGRReadProgressView *)progressView readPercentChange:(CGFloat)percent
{
    if ([self.showManager setNovelReadPercent:percent]) {
        [self showCurrentPageComplete:^{
            _bottomProgressView.lblTitle.text = self.showManager.chapterTitle;
        }];
    }
}

#pragma mark FGRReadBottomShowViewProtocol

- (void)readBottomShowView:(FGRReadBottomShowView *)showView changeBrightness:(CGFloat)brightness
{
    [UIScreen mainScreen].brightness = brightness;
}

- (void)readBottomShowView:(FGRReadBottomShowView *)showView changeBackgroundTheme:(NSInteger)theme
{
    [FGROptionManager sharedInstance].backgroundColorIndex = theme;
    self.view.backgroundColor = [FGROptionManager sharedInstance].readBgColor;
}

#pragma mark -

- (FGRNovelShowManager *)showManager
{
    if (!_showManager) {
        FGRNovelShowManager *showManager = [[FGRNovelShowManager alloc] initWithNovel:self.novelModel showSize:self.pageView.bounds.size];
        _showManager = showManager;
    }
    return _showManager;
}


- (FGRChapterListController *)listController
{
    if (!_listController) {
        FGRChapterListController *vc = [FGRChapterListController controller];
        vc.novelModel = self.novelModel;
        
        __weak __typeof(self)wself = self;
        vc.selectBlock = ^(NSInteger index) {
            [wself hideMenus];
            wself.showManager.chapterIndex = index;
            [wself showCurrentPageComplete:nil];
            return YES;
        };
        _listController = vc;
    }
    return _listController;
}



- (NSArray *)moreMenuItems
{
    if (!_moreMenuItems) {
        __weak __typeof(self)weakSelf = self;
        _moreMenuItems = @[[[FGRReadNovelMoreMenuItem alloc] initWith:@"refresh" title:@"刷新" clickAction:^{
            [weakSelf.showManager refreshCurrentChapterComplete:^(NSError *err) {
                [weakSelf showCurrentPageComplete:nil];
            }];
        }]];
    }
    return _moreMenuItems;
}


#pragma mark -

- (void)tapAlphaView:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        [self hideMenus];
    }
}

@end









