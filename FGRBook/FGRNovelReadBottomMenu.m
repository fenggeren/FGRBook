//
//  FGRNovelReadBottomMenu.m
//  FGRBook
//
//  Created by fenggeren on 2016/9/25.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRNovelReadBottomMenu.h"

@interface FGRNovelReadBottomMenu()
{
    NSArray *_buttons;
}


@end


@implementation FGRNovelReadBottomMenu

- (instancetype)init
{
    if (self = [super init]) {
        [self config];
    }
    return self;
}

- (void)config
{
    NSArray *titles = @[@"目录", @"进度", @"选项", @"显示", @"评论"];
    NSMutableArray *btns = [NSMutableArray array];
    for (NSInteger i = 0; i < titles.count; i++) {
        UIButton *btn = [self buttonWithTitle:titles[i] tag:i];
        [self addSubview:btn];
        [btns addObject:btn];
    }
    
    _buttons = btns;
}

- (UIButton *)buttonWithTitle:(NSString *)title tag:(NSInteger)tag
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.tag = tag;
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)btnClick:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(clickMenu:typeForItem:)]) {
        [self.delegate clickMenu:self typeForItem:(FGRNovelReadBottomMenuType)btn.tag];
    } 
}

#pragma mark - 

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat oriY = 8;
    CGFloat width = self.bounds.size.width / _buttons.count;
    CGFloat height = self.bounds.size.height - oriY;
    CGFloat oriX = 0;
    for (UIButton *btn in _buttons) {
        btn.frame = CGRectMake(oriX, oriY, width, height);
        oriX += width;
    }
}

@end
