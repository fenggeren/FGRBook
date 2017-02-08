//
//  FGRBottomMenuController.m
//  CollectionViewAutoScroll
//
//  Created by HuanaoGroup on 16/11/1.
//  Copyright © 2016年 HuanaoGroup. All rights reserved.
//

#import "FGRBottomMenuController.h"
#import "FGRBottomMenu.h"
#import "FGRReadOptionViewController.h"
#import "FGRChapterListController.h"
#import "FGRReadProgressView.h"
#import "FGRReadBottomShowView.h"
#import "FGRNovelReadController.h"
#import "FGRNovelShowManager.h"
#import "FGRNovelModel.h"
#import "UIImage+FGRExtension.h"
#import "FGRBookrackManager.h"

@interface FGRBottomMenuController () <FGRBottomMenuProtocol, UIGestureRecognizerDelegate>
@property (nonatomic, strong) FGRBottomMenu *bottomMenu;

@property (nonatomic, strong) FGRChapterListController *listController;
@end

@implementation FGRBottomMenuController
{
    __weak FGRReadProgressView *_bottomProgressView;
    __weak FGRReadBottomShowView *_bottomShowView;
}

+ (instancetype)bottomMenuController
{
    return [[self alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (touches.anyObject.view == self.view) {
        [self dismissComplete:nil];
        [super touchesBegan:touches withEvent:event];
    }
}

#pragma mark - 

- (void)show
{
    [self.bottomMenu show];
}

- (void)dismissComplete:(dispatch_block_t)block
{
    [self.bottomMenu dismissComplete:^{
        if (block) {
            block();
        }
    }];
    
    if (_bottomProgressView) {
        [_bottomProgressView hide];
    }
    
    if (_bottomShowView) {
        [_bottomShowView hide];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(UINavigationControllerHideShowBarDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController.view removeFromSuperview];
        [self.navigationController removeFromParentViewController];
    });
}


#pragma mark -

- (NSArray<UIView *> *)viewsInBottomMenu:(FGRBottomMenu *)bottomMenu
{
    UILabel *(^labelBlock)(NSString *, NSInteger) = ^UILabel*(NSString *title, NSInteger tag) {
        UILabel *l = [[UILabel alloc] init];
        l.backgroundColor = [UIColor clearColor];
        l.userInteractionEnabled = YES;
        l.text = title;
        l.tag = tag;
        l.font = [UIFont systemFontOfSize:20];
        l.textColor = [UIColor whiteColor];
        l.textAlignment = NSTextAlignmentCenter;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBottomMenuItem:)];
        tap.delegate = self;
        tap.cancelsTouchesInView = YES;
        [l addGestureRecognizer:tap];
        return l;
    };
    return @[labelBlock(@"目录", 0), labelBlock(@"进度", 1),
             labelBlock(@"选项", 2), labelBlock(@"显示", 3)];
}



- (void)clickBottomMenuItem:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        switch (tap.view.tag) {
            case 0: // 目录
            {
                if (self.novelModel.hasLoaded == NO) {
                    [MBProgressHUD bwm_showTitle:@"没有该小说记录,请前往起点阅读-!" toView:self.view hideAfter:1.5];
                } else {
                    [[self.menuDelegate navigationControllerForCatalogController:self.listController menuController:self] pushViewController:self.listController animated:YES];
                }
            }
                break;
            case 1: // 进度
            {
                FGRNovelShowManager *showManager = [self.menuDelegate showManagerForMenuController:self];
                _bottomProgressView = [FGRReadProgressView showInView:self.view title:showManager.chapterTitle percent:showManager.readPercent andDelegate:self.menuDelegate];
            }
                break;
            case 2: // 选项
            {
                FGRReadOptionViewController *optionVC = [[FGRReadOptionViewController alloc] initWithNibName:@"FGRReadOptionViewController" bundle:nil];
                [self.navigationController pushViewController:optionVC animated:NO];
            }
                break;
            case 3: // 显示
            {
                _bottomShowView = [FGRReadBottomShowView showInView:self.view andDelegate:self.menuDelegate];
            }
                break;
            default:
                break;
        }
        [self.bottomMenu dismissComplete:nil];
    }
}
#define kBottomMenuHeight 55
- (CGRect)originalFrameForBottomMenu:(FGRBottomMenu *)bottomMenu
{
    return CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, kBottomMenuHeight);
}
- (CGRect)showFrameForBottomMenu:(FGRBottomMenu *)bottomMenu
{
    return CGRectMake(0, self.view.bounds.size.height - kBottomMenuHeight, self.view.bounds.size.width, kBottomMenuHeight);
}
- (NSTimeInterval)showAnimationIntervalForBottomMenu:(FGRBottomMenu *)bottomMenu
{
    return UINavigationControllerHideShowBarDuration;
}


#pragma mark - 

- (FGRNovelModel *)novelModel
{
    return [self.menuDelegate showManagerForMenuController:self].novel;
}

- (FGRBottomMenu *)bottomMenu
{
    if (!_bottomMenu) {
        _bottomMenu = [[FGRBottomMenu alloc] init];
        _bottomMenu.delegate = self;
        _bottomMenu.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        [self.view addSubview:_bottomMenu];
    }
    return _bottomMenu;
}

- (FGRChapterListController *)listController
{
    if (!_listController) {
        FGRChapterListController *vc = [FGRChapterListController controller];
        vc.novelModel = [self.menuDelegate showManagerForMenuController:self].novel;
        
        __weak __typeof(self)wself = self;
        vc.selectBlock = ^(NSInteger index) {
            [wself.menuDelegate menuController:wself selectIndexChapter:index atCatalogController:wself.listController];
            return YES;
        };
        _listController = vc;
    }
    return _listController;
}
@end
