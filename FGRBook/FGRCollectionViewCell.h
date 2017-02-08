//
//  MyCollectionViewCell.h
//  CollectionViewAutoScroll
//
//  Created by Fenggeren on 16/10/28.
//  Copyright © 2016年 Fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FGRNovelModel;

@interface FGRCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (nonatomic, strong) FGRNovelModel *novelModel;

@end
