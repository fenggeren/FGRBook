//
//  FGRHomeNovelCell.h
//  FGRBook
//
//  Created by fenggeren on 16/9/19.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FGRNovelModel;

@interface FGRHomeNovelCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UILabel *lblName;

@property (nonatomic, strong) FGRNovelModel *novelModel;

@end
