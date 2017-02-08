//
//  FGRCollectionViewDataSource.m
//  CollectionViewAutoScroll
//
//  Created by Fenggeren on 16/10/28.
//  Copyright © 2016年 Fenggeren. All rights reserved.
//

#import "FGRCollectionViewDataSource.h"
#import "FGRCollectionViewCell.h"
#import "FGRCollectionViewLayout.h"
#import "FGRNovelModel.h"

#define kMultiCount 3


@interface UIScrollView(FGRShow)
@property (nonatomic, assign) CGFloat showCenterX;
@end

@interface FGRCollectionViewDataSource()
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation FGRCollectionViewDataSource
{
    FGRCollectionViewLayout * _collectionViewLayout;
}

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)configCollectionView:(UICollectionView *)collectionView
{
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerNib:[UINib nibWithNibName:@"FGRCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"FGRCollectionViewCell"];
    collectionView.collectionViewLayout = self.collectionViewLayout;
    _collectionView = collectionView;
}

- (void)defaultSetLayout
{
    FGRCollectionViewLayout *collectionViewLayout = (FGRCollectionViewLayout *)self.collectionView.collectionViewLayout;
    CGSize size = self.collectionView.bounds.size;
    collectionViewLayout.itemSize = CGSizeMake(size.width * 0.4, size.height * 0.7);
    collectionViewLayout.minimumLineSpacing = 20;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
}

- (FGRCollectionViewLayout *)collectionViewLayout
{
    if (!_collectionViewLayout) {
        _collectionViewLayout = [[FGRCollectionViewLayout alloc] init];
        _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _collectionViewLayout;
}

- (void)startAutoScroll
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:3. target:self selector:@selector(timeFir:) userInfo:nil repeats:YES];
}

- (void)timeFir:(NSTimer *)time
{
    CGPoint pos = [self.collectionViewLayout contentOffsetWithCellMove:1];
    [self.collectionView setContentOffset:pos animated:YES];
}
 
- (void)stopAutoScroll
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.models.count * kMultiCount;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FGRCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FGRCollectionViewCell" forIndexPath:indexPath];
    cell.novelModel = self.models[indexPath.item % self.models.count];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    if (self.didSelectedCell) {
        self.didSelectedCell([indexPath copy], self.models[indexPath.item % self.models.count]);
    }
    collectionView.userInteractionEnabled = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    CGFloat centerX = scrollView.showCenterX;
    CGFloat offsetX = [self scrollView:scrollView targetContentOffsetXWithProposedCenterX:centerX];
    [scrollView setContentOffset:CGPointMake(offsetX, scrollView.contentOffset.y) animated:NO];
    scrollView.userInteractionEnabled = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat centerX = scrollView.showCenterX;
    CGFloat offsetX = [self scrollView:scrollView targetContentOffsetXWithProposedCenterX:centerX];
    
    [scrollView setContentOffset:CGPointMake(offsetX, scrollView.contentOffset.y) animated:NO];
}

- (CGFloat)scrollView:(UIScrollView *)scrollView targetContentOffsetXWithProposedCenterX:(CGFloat)proposedCenterX
{
    NSInteger one_3 = scrollView.contentSize.width / 3;
    if (proposedCenterX < one_3) {
        proposedCenterX += one_3;
    } else if (proposedCenterX > one_3 * 2) {
        proposedCenterX -= one_3;
    }
    return [self.collectionViewLayout contentOffsetXForProposedOffsetX:proposedCenterX - scrollView.bounds.size.width * 0.5];
}


@end


@implementation UIScrollView(FGRShow)
@dynamic showCenterX;

- (CGFloat)showCenterX
{
    return self.contentOffset.x + self.bounds.size.width * 0.5;
}

@end








