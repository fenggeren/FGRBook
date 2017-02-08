//
//  FGRChapter.m
//  FGRBook
//
//  Created by fenggeren on 2016/9/23.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRChapter.h"
#import "FGRDataManager.h"
#import "FGROptionManager.h"
#import "FGRChapterInfoModel.h"

@interface FGRChapter ()
{
    NSArray<FGRPage *> *_pages;
}


@end

@implementation FGRChapter
@dynamic indexStr;


- (instancetype)initWithSize:(CGSize)size chapter:(FGRChapterInfoModel *)model
{
    if (self = [super init]) {
        _size = size;
        _title = [model.name copy];
        _infoModel = model;
        _curIndex = 0;
    }
    return self;
}

- (void)setCurIndex:(NSInteger)curIndex
{
    _curIndex = curIndex;
    [[NSNotificationCenter defaultCenter] postNotificationName:kFGRNotiChapterPageIndexChangeKey object:nil userInfo:@{@"value": @(curIndex)}];
}

#pragma mark -

- (void)formate
{
    NSAttributedString *attriStr = self.attributeContent;
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attriStr);
    
    NSInteger offset = 0;
    CGPathRef path = CGPathCreateWithRect((CGRect){{0}, self.size}, NULL);
    
    NSMutableArray *pages = [NSMutableArray array];
    while (offset < attriStr.length) {
        FGRPage *page = [[FGRPage alloc] init];
        
        CFRange stringRange = CFRangeMake(offset, 0);
        CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, stringRange, path, NULL);
        CFRange visibleRange = CTFrameGetVisibleStringRange(frameRef);
        if (visibleRange.location == NSNotFound || visibleRange.length == 0) {
            // TODO.
            CFRelease(frameRef);
            CFRelease(framesetterRef);
            NSAssert(false, @"%@", NSStringFromSelector(_cmd));
            return;
        } else {
            page.frameRef = frameRef;
            page.content = [attriStr attributedSubstringFromRange:NSMakeRange(visibleRange.location, visibleRange.length)];
            [pages addObject:page];
            offset = visibleRange.location + visibleRange.length;
        }
    }
    _pages = pages;
    CFRelease(framesetterRef);
    
    if (self.curIndex > _pages.count - 1) {
        self.curIndex = _pages.count - 1;
    }
}


- (NSAttributedString *)attributeContent
{
    if (self.content == nil || self.content.length == 0) {
        return [FGROptionManager sharedInstance].textShowAttribute(@"没有下载该章节内容");
    }
    NSAttributedString *str = [FGROptionManager sharedInstance].textShowAttribute(self.content);
    return str;
}

- (NSString *)indexStr
{
    return [NSString stringWithFormat:@"%ld/%ld", self.curIndex + 1, _pages.count];
}

- (NSString *)content
{
    return self.infoModel.content;
}

- (FGRPage *)curPage
{
    if ((self.curIndex > _pages.count - 1) || (self.curIndex < 0)) {
        if (self.curIndex < 0) {
            self.curIndex = 0;
        } else if (self.curIndex > _pages.count - 1) {
            self.curIndex = _pages.count - 1;
        }
        return nil;
    }
    return _pages[self.curIndex];
}

- (FGRPage *)lastPage
{
    self.curIndex = _pages.count - 1;
    return [self curPage];
}

- (FGRPage *)nextPage
{
    self.curIndex ++;
    return [self curPage];
}

- (FGRPage *)prePage
{
    self.curIndex--;
    return [self curPage];
}

- (void)flipNext
{
    self.curIndex++;
}
- (void)flipPrevious
{
    self.curIndex--;
}


@end
