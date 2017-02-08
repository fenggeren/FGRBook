//
//  FGRBookrackCell.m
//  FGRBook
//
//  Created by fenggeren on 2016/10/8.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRBookrackCell.h"
#import "FGRNovelModel.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "FGRBookbrackModel.h"
#import "UIImage+FGRExtension.h"
#import "FGRLoadProgressView.h"
#import "POP.h"

@interface FGRBookrackCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *lblName;

@property (weak, nonatomic) IBOutlet UILabel *lblPercentReaded;

@property (weak, nonatomic) IBOutlet UIButton *btnSelect;

@property (weak, nonatomic) IBOutlet UIButton *coverAlpha;


@property (nonatomic, strong) UIView *updateView;

@property (nonatomic, strong) FGRLoadProgressView *progressView;
@property (nonatomic, strong) UIView *loadingCover;
@end

@implementation FGRBookrackCell


- (void)awakeFromNib {
    [super awakeFromNib];

    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    lp.minimumPressDuration = 1;
    [self.contentView addGestureRecognizer:lp];
    
    self.loadingCover = [[UIView alloc] init];
    self.loadingCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    self.loadingCover.hidden = YES;
    [self.contentView addSubview:self.loadingCover];
    
    self.progressView = [FGRLoadProgressView loadProgressView];
    self.progressView.hidden = YES;
    [self.contentView addSubview:self.progressView];
    
    self.updateView = [[UIView alloc] init];
    self.updateView.backgroundColor = [UIColor redColor];
    self.updateView.hidden = YES;
    self.updateView.layer.masksToBounds = YES;
    CGFloat updateViewLength = 12;
    self.updateView.layer.cornerRadius = updateViewLength * 0.5;
    self.updateView.bounds = CGRectMake(0, 0, updateViewLength, updateViewLength);
    [self.contentView addSubview:self.updateView];
    
    [self.coverAlpha setBackgroundImage:[UIImage imageWithColor:[UIColor blackColor] alpha:0.4] forState:UIControlStateNormal];
    [self.coverAlpha setBackgroundImage:[UIImage imageWithColor:[UIColor blackColor] alpha:0.7] forState:UIControlStateHighlighted];
    
}

- (void)longPress:(UILongPressGestureRecognizer *)lp
{
    if (lp.state == UIGestureRecognizerStateBegan) {
        [self.delegate bookrackCellBeginEditing:self];
        self.coverAlpha.hidden = NO;
        self.btnSelect.hidden = NO;
        self.btnSelect.selected = YES;
        [self updateData];
    }
}
- (IBAction)clickEdit:(UIButton *)sender {
    self.btnSelect.selected = !self.btnSelect.selected;
    [self updateData];
}

- (void)updateData
{
    self.novelModel.select = self.btnSelect.selected;
    [self.delegate bookrackCell:self didSelect:self.btnSelect.selected];
}

- (void)setNovelModel:(FGRBookbrackModel *)novelModel
{
    FGRBookbrackModel *oldModel = _novelModel;
    _novelModel = novelModel;
    self.updateView.hidden = !novelModel.novelModel.isUpdate;
    [self showHideLoadProgressView:NO];
    __weak __typeof(self)weakSelf = self;
    _novelModel.novelModel.loadProgressBlock = ^FGRProgressBlock(){
        return ^(CGFloat percent) {
            [weakSelf showHideLoadProgressView:YES];
            weakSelf.progressView.progress = percent;
            if (percent >= 1) {
                [weakSelf showHideLoadProgressView:NO];
            }
        } ;
    };
    
    self.btnSelect.selected = self.novelModel.isSelected;
    [self updateData];
    
    if ([_novelModel isEqual:oldModel] && self.iconView.image != nil) {
        return;
    }
    
    self.iconView.image = [UIImage imageNamed:@"default"];
    if (novelModel.imgURL == nil || novelModel.image == nil) {
        __weak __typeof(self)weakSelf = self;
        [novelModel.novelModel loadDataCompleteBlock:^(NSError *err) {
            if (novelModel == weakSelf.novelModel) {
                [weakSelf showData:novelModel];
            }
        }];
    } else if (self.novelModel.image){
        self.iconView.image = self.novelModel.image ?: [UIImage imageNamed:@"default"];
    } else {
        [self showData:novelModel];
    }
    self.lblName.text = self.novelModel.name;
    
    if (novelModel.novelModel.readPercent < 0) {
            self.lblPercentReaded.text = @"尚未开始阅读";
    } else {
        self.lblPercentReaded.text = [NSString stringWithFormat:@"已读%.2f%%", self.novelModel.novelModel.readPercent * 100];
    }

}

- (void)showData:(FGRBookbrackModel *)curNovelModel
{
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:self.novelModel.imgURL] options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (curNovelModel == self.novelModel) {
            self.iconView.image = image ?: [UIImage imageNamed:@"default"];
            self.novelModel.image = image;
        }
    }];
}

- (void)setEditable:(BOOL)editable
{
    self.coverAlpha.hidden = !editable;
    self.btnSelect.hidden = !editable;
}

- (void)endDisplaying
{
    self.novelModel.novelModel.loadProgressBlock = nil;
    self.progressView.hidden = YES;
    self.loadingCover.hidden = YES;
    [self.progressView stopAnimation];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat l = self.iconView.bounds.size.width * 0.6;
    self.progressView.bounds = CGRectMake(0, 0, l, l);
    self.progressView.center = self.iconView.center;
    self.loadingCover.frame = self.iconView.frame;
    self.updateView.center = CGPointMake(CGRectGetMaxX(self.iconView.frame), self.iconView.origin.x);
}

#pragma mark - Helper

- (void)showHideLoadProgressView:(BOOL)show
{
    if ((self.loadingCover.hidden == NO && show == YES) ||
        (self.loadingCover.hidden == YES && show == NO)) {
        return;
    }
    if (show == NO) {
        [self.progressView stopAnimation];
        self.novelModel.novelModel.loadProgressBlock = nil;
    }
    self.loadingCover.hidden = self.progressView.hidden = NO;
    self.progressView.alpha = self.loadingCover.alpha = show ? 0 : 1;
    [UIView animateWithDuration:0.5 animations:^{
        self.progressView.alpha = self.loadingCover.alpha = show ? 1 : 0;
    } completion:^(BOOL finished) {
        self.loadingCover.hidden = self.progressView.hidden = show ? NO : YES;
    }];
    
}

@end







