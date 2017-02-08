//
//  FGRNovelViewController.m
//  FGRBook
//
//  Created by fenggeren on 16/9/20.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRNovelViewController.h"
#import "FGRNovelModel.h"
#import "FGRDataManager.h"
#import "FGRNovelReadController.h"
#import "FGRBookrackManager.h"
#import "CPGLoadingView.h"
#import "UIImage+FGRExtension.h"
#import "NSString+FGRExtension.h"
#import "FGRChapterListController.h"

@interface FGRNovelViewController ()
@property (weak, nonatomic) IBOutlet UIView *vBottom;
@property (weak, nonatomic) IBOutlet UIButton *btnJoin;
@property (weak, nonatomic) IBOutlet UIButton *btnDownload;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIView *headerContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblAuthor;
@property (weak, nonatomic) IBOutlet UILabel *lblType;
@property (weak, nonatomic) IBOutlet UILabel *lblChapterCount;

@property (weak, nonatomic) IBOutlet UILabel *lblInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnMoreInfo;
@property (weak, nonatomic) IBOutlet UIView *tapViewChaptersView;

@property (weak, nonatomic) IBOutlet UILabel *lblUpdateInfo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoHeightConstraint;


@end

@implementation FGRNovelViewController

+ (instancetype)controller
{
    FGRNovelViewController *vc = [super controller];
    vc.hidesBottomBarWhenPushed = YES;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.vBottom.layer.shadowPath = CGPathCreateWithRect(self.vBottom.bounds, NULL);
    self.vBottom.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.vBottom.layer.shadowRadius = 2.;
    self.vBottom.layer.shadowOpacity = 0.8;
    self.vBottom.layer.shadowOffset = CGSizeMake(0, -3);
    
    self.lblInfo.lineBreakMode = NSLineBreakByCharWrapping;
    
    self.title = self.novelModel.name;
    self.btnJoin.enabled = ![BookrackManager hasJoined:self.novelModel];
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.novelModel.imgURL]  placeholderImage:[UIImage imageNamed:@"default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.headImageView.image = image ?: [UIImage imageNamed:@"bigPlaceholder"];
    }];
    self.lblName.text = self.novelModel.name;
    self.lblAuthor.text = self.novelModel.author;
    self.lblType.text = self.novelModel.type ?: @"好看的类型";
    
    [self updateShow];
    
    
    CPGLoadingView *loadView = [CPGLoadingView showInView:self.view];
    [self.novelModel loadDataCompleteBlock:^(NSError *err) {
        if (err) {
            [MBProgressHUD bwm_showTitle:err.localizedDescription toView:self.navigationController.view hideAfter:2.5 msgType:BWMMBProgressHUDMsgTypeError];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self updateShow];
            self.btnMoreInfo.hidden = ([self testInfoSize].height <= self.lblInfo.height);
            [loadView hide];
        }
    }];
}

- (void)updateShow
{
    NSString *chapterCount = [[NSString stringWithFormat:@"%ld", self.novelModel.chapters.count] alaboToChinese];
    chapterCount = [NSString stringWithFormat:@"%@章", chapterCount];
    self.lblChapterCount.text = chapterCount;
    self.lblInfo.text = self.novelModel.briefIntroduction;
    self.lblUpdateInfo.text = [self updateBeforeTime];
}

- (NSString *)updateBeforeTime
{
    NSRange range = [self.novelModel.updateDate rangeOfString:@"\\d{4}([-/]\\d{1,2}){2} (\\d{1,2}[:|-|/]){2}\\d{1,2}" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        NSString *dateStr = [self.novelModel.updateDate substringWithRange:range];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *date = [formatter dateFromString:dateStr];
        NSInteger interval = [[NSDate date] timeIntervalSinceDate:date];
        NSString *beforeTime = nil;
        if (interval < 60) {
            beforeTime = @"1分钟内";
        } else if (interval >= 60 && interval < 60 * 60) {
            beforeTime = [NSString stringWithFormat:@"%ld分钟前", interval / 60];
        } else if (interval >= 60 * 60 && interval < 60 * 60 * 24) {
            beforeTime = [NSString stringWithFormat:@"%ld小时前", interval / (60 * 60)];
        } else if (interval >= 60 * 60 * 24 && interval < 60 * 60 * 24 * 30) {
            beforeTime = [NSString stringWithFormat:@"%ld天前", interval / (60 * 60 * 24)];
        } else if (interval >= 60 * 60 * 24 * 30 && interval < 60 * 60 * 24 * 30 * 12) {
            beforeTime = [NSString stringWithFormat:@"%ld月前", interval / (60 * 60 * 24 * 30)];
        } else if (interval >= 60 * 60 * 24 * 30 * 12 && interval < 60 * 60 * 24 * 30 * 12 * 5) {
            beforeTime = [NSString stringWithFormat:@"%ld年前", interval / (60 * 60 * 24 * 30 * 12)];
        } else {
            beforeTime = @"很久以前";
        }
        
        NSString *chapterName = self.novelModel.latestChapter.name;
        if (chapterName == nil || chapterName.length == 0) {
            chapterName = self.novelModel.chapters.lastObject.name;
        }
        if (chapterName == nil || chapterName.length == 0) {
            chapterName = @"最近";
        }
        return [NSString stringWithFormat:@"%@  更新于%@", self.novelModel.latestChapter.name ?: @"", beforeTime];
    }
    
    return self.novelModel.updateDate;
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.btnMoreInfo.hidden = ([self testInfoSize].height <= self.lblInfo.height);
}

- (CGSize)testInfoSize
{
    UILabel *l = [[UILabel alloc] init];
    l.font = self.lblInfo.font;
    l.numberOfLines = 0;
    l.text = self.novelModel.briefIntroduction;
    
    CGSize size = [l systemLayoutSizeFittingSize:CGSizeMake(self.lblInfo.width, CGFLOAT_MAX) withHorizontalFittingPriority:UILayoutPriorityFittingSizeLevel verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
    
    return size;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
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
}

#pragma mark -

- (void)readNovel
{
    FGRNovelReadController *detailVC = [FGRNovelReadController controller];
    detailVC.novelModel = self.novelModel;
    [self.navigationController pushViewController:detailVC animated:YES];
}


- (IBAction)clkDownload:(UIButton *)sender {
    [self clkAddBookself:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.novelModel loadAllCompleteProgress:^(CGFloat progress) {
            
        }];
    });
}

- (IBAction)clkRead:(id)sender {
    if (self.novelModel.isLoadCompleted == NO) {
        __weak __typeof(self)weakSelf = self;
        [self.novelModel loadDataCompleteBlock:^(NSError *err) {
            [weakSelf readNovel];
        }];
    } else {
        [self readNovel];
    }
}

- (IBAction)clkAddBookself:(UIButton *)sender {
    
    [BookrackManager addNovel:self.novelModel];
    self.btnJoin.enabled = ![BookrackManager hasJoined:self.novelModel];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BookrackAddBookNoti object:self userInfo:nil];
}

- (IBAction)clkShowMoreInfo:(UIButton *)sender {
    CGSize size = [self testInfoSize];
    if (size.height > self.lblInfo.height) {
        self.lblInfo.numberOfLines = 0;
        self.lblInfo.text = self.novelModel.briefIntroduction;
        self.infoHeightConstraint.constant = size.height;
    }
    self.btnMoreInfo.hidden = YES;
    sender.hidden = YES;
}


- (IBAction)tapShowChaptersList:(UITapGestureRecognizer *)sender {
    FGRChapterListController *vc = [FGRChapterListController controller];
    vc.novelModel = self.novelModel;
    __weak __typeof(self)wself = self;
    vc.selectBlock = ^(NSInteger index) {
        wself.novelModel.curIndex = index;
        [wself readNovel];
        return NO;
    };
    [self.navigationController pushViewController:vc animated:YES];
}

@end


