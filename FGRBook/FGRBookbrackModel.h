//
//  FGRBookbrackModel.h
//  FGRBook
//
//  Created by fenggeren on 2016/10/16.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FGRNovelModel;


@interface FGRBookbrackModel : NSObject

+ (NSArray<FGRBookbrackModel *> *)bookbrackModelsWith:(NSArray<FGRNovelModel *> *)novels;

- (instancetype)initWithNovel:(FGRNovelModel *)novel;

@property (nonatomic, readonly) FGRNovelModel *novelModel;

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *imgURL;

@property (nonatomic, strong) UIImage *image;


@property (nonatomic, copy) NSIndexPath *indexPath;
@property (nonatomic, assign, getter=isSelected) BOOL select;

@end
