//
//  FGRHomeTableViewCell.h
//  FGRBook
//
//  Created by fenggeren on 16/9/19.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>


@class FGRHomeSectionNovels;

@interface FGRHomeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblType;

@property (nonatomic, strong) FGRHomeSectionNovels *sectionNovels;

- (void)afterShowConfig;


@end
