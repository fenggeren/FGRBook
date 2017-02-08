//
//  FGRHomeTableViewCell.m
//  FGRBook
//
//  Created by fenggeren on 16/9/19.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRHomeTableViewCell.h"
#import "FGRHomeNovelCell.h"
#import "FGRHomeSectionNovels.h"
#import "FGRHomeSectionNovelsDataSource.h"


@interface FGRHomeTableViewCell ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) FGRHomeSectionNovelsDataSource *dataSource;

@end

@implementation FGRHomeTableViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ([super initWithCoder:aDecoder]) {
     }
    return self;
}

- (void)afterShowConfig
{
    self.sectionNovels.contentOffset = self.collectionView.contentOffset;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.dataSource = [[FGRHomeSectionNovelsDataSource alloc] init];
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self.dataSource;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
}


- (void)setSectionNovels:(FGRHomeSectionNovels *)sectionNovels
{
    _sectionNovels = sectionNovels;
    self.lblType.text = sectionNovels.typeName;
    
    self.dataSource.novelModels = sectionNovels.novels;
    self.collectionView.contentOffset = sectionNovels.contentOffset;
    [self.collectionView reloadData];
}


#pragma mark -

- (IBAction)clkShowAll:(UIButton *)sender {
    
}


@end













