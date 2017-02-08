//
//  FGRSearchResultCell.m
//  FGRBook
//
//  Created by fenggeren on 2016/10/5.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRSearchResultCell.h"
#import "FGRNovelModel.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImage+FGRExtension.h"

@interface FGRSearchResultCell()
@property (weak, nonatomic) IBOutlet UIImageView *ivIcon;

@property (weak, nonatomic) IBOutlet UILabel *lblName;

@property (weak, nonatomic) IBOutlet UILabel *lblAuthor;

@end

@implementation FGRSearchResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setNovelModel:(FGRNovelModel *)novelModel
{
    _novelModel = novelModel;
    self.imageView.image = nil;
    if (novelModel.imgURL == nil) {
        __weak __typeof(self)weakSelf = self;
        [self.novelModel loadDataCompleteBlock:^(NSError *err) {
            if (novelModel == weakSelf.novelModel) {
                [weakSelf showData:novelModel];
            }
        }];
    } else {
        [self showData:novelModel];
    }
    self.lblName.text = self.novelModel.name;
    self.lblAuthor.text = self.novelModel.author;
}

- (void)showData:(FGRNovelModel *)curNovelModel
{
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:self.novelModel.imgURL] options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (curNovelModel == self.novelModel) {
//            self.ivIcon.image = [image imageWithSize:self.ivIcon.bounds.size];
            self.ivIcon.image = image;
        }
    }];
}


@end
