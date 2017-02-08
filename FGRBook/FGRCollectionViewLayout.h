//
//  MyCollectionViewLayout.h
//  CollectionViewAutoScroll
//
//  Created by Fenggeren on 16/10/28.
//  Copyright © 2016年 Fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface FGRCollectionViewLayout : UICollectionViewFlowLayout

- (CGPoint)contentOffsetWithCellMove:(NSInteger)num;

- (CGFloat)contentOffsetXForProposedOffsetX:(CGFloat)proposedOffsetX;
@end


@interface UICollectionViewLayoutAttributes(FGRExtension)
//@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, assign) CGFloat shadowRadius;

@end
