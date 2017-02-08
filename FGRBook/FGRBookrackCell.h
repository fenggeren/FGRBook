//
//  FGRBookrackCell.h
//  FGRBook
//
//  Created by fenggeren on 2016/10/8.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FGRBookbrackModel, FGRBookrackCell;

@protocol FGRBookrackCellProtocol <NSObject>

- (void)bookrackCellBeginEditing:(FGRBookrackCell *)cell;
- (void)bookrackCell:(FGRBookrackCell *)cell didSelect:(BOOL)isSelect;

@end

@interface FGRBookrackCell : UICollectionViewCell

@property (nonatomic, strong) FGRBookbrackModel *novelModel;

@property (nonatomic, weak) id<FGRBookrackCellProtocol> delegate;

- (void)setEditable:(BOOL)editable;

- (void)endDisplaying;

@end
