//
//  FGRHomeNovelCell.m
//  FGRBook
//
//  Created by fenggeren on 16/9/19.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRHomeNovelCell.h"
#import "FGRNovelModel.h"
#import "UIImage+FGRExtension.h"


@implementation FGRHomeNovelCell


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
    self.lblName.text = self.novelModel.name;
}

- (void)showData:(FGRNovelModel *)curNovelModel
{
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:self.novelModel.imgURL] options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (curNovelModel == self.novelModel) {
            [image clipCornerRadius:5 withSize:self.imgView.bounds.size completeBlock:^(UIImage *img) {
                self.imgView.image = img;
            }];
        }
    }];
}


@end
