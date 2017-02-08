//
//  FGRBottomMenuProtocol.h
//  FGRBook
//
//  Created by fenggeren on 2016/11/3.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FGRReadProgressView, FGRReadBottomShowView;

@protocol FGRReadProgressViewProtocol <NSObject>

- (void)nextChapterProgressView:(FGRReadProgressView *)progressView;
- (void)previousChapterProgressView:(FGRReadProgressView *)progressView;
- (void)readProgressView:(FGRReadProgressView *)progressView readPercentChange:(CGFloat)percent;

@end

@protocol FGRReadBottomShowViewProtocol <NSObject>
@optional
- (void)readBottomShowView:(FGRReadBottomShowView *)showView changeBrightness:(CGFloat)brightness;
- (void)readBottomShowView:(FGRReadBottomShowView *)showView changeBackgroundTheme:(NSInteger)theme;

@end


@class FGRReadNovelMoreMenu, FGRReadNovelMoreMenuItem;

@protocol FGRReadNovelMoreMenuProtocol <NSObject>

- (NSArray<FGRReadNovelMoreMenuItem *> *)menuItemsInReadNovelMoreMenu:(FGRReadNovelMoreMenu *)menu;
@end
