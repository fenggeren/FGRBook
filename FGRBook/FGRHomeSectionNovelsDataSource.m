//
//  FGRHomeSectionNovelsDataSource.m
//  FGRBook
//
//  Created by fenggeren on 16/9/19.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRHomeSectionNovelsDataSource.h"
#import "FGRHomeNovelCell.h"
#import "FGRGlobalFunction.h"
#import "FGRNovelViewController.h"


@interface FGRHomeSectionNovelsDataSource ()

@end

@implementation FGRHomeSectionNovelsDataSource


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FGRNovelModel *novel = self.novelModels[indexPath.item];
    FGRNovelViewController *novelVC = [FGRNovelViewController controller];
    novelVC.novelModel = novel;
    
    UIViewController *vc = topViewController();
    [vc.navigationController pushViewController:novelVC animated:YES];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.novelModels.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FGRHomeNovelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(FGRHomeNovelCell.class) forIndexPath:indexPath];
    cell.novelModel = self.novelModels[indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(105, 145);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

@end
