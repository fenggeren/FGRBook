//
//  MyCollectionViewCell.m
//  CollectionViewAutoScroll
//
//  Created by Fenggeren on 16/10/28.
//  Copyright © 2016年 Fenggeren. All rights reserved.
//

#import "FGRCollectionViewCell.h"
#import "FGRNovelModel.h"

@implementation FGRCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)setNovelModel:(FGRNovelModel *)novelModel
{
    FGRNovelModel *oldModel = _novelModel;
    _novelModel = novelModel;
    if ([novelModel isEqual:oldModel] && self.imgView.image != nil) {
        return;
    }
    self.imgView.image = [UIImage imageNamed:kDefaultPlaceholder];
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
}

- (void)showData:(FGRNovelModel *)curNovelModel
{
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:self.novelModel.imgURL] options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (curNovelModel == self.novelModel) {
            self.imgView.image = image;
        }
    }];
}

@end
