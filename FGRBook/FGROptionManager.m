//
//  FGROptionManager.m
//  CollectionViewAutoScroll
//
//  Created by HuanaoGroup on 16/11/2.
//  Copyright © 2016年 HuanaoGroup. All rights reserved.
//

#import "FGROptionManager.h"


#define kFontSize   @"fontSizeIndex"
#define kLineSpace  @"lineSpaceIndex"
#define kFontStyle  @"fontStyleIndex"
#define kFlipStyle  @"flipStyleIndex"
#define kLanguages @"languagesIndex"
#define kBGColorIndex @"backgroundColorIndex"
@interface FGROptionManager()

@end


@implementation FGROptionManager
@synthesize textShowAttribute = _textShowAttribute;

+ (instancetype)sharedInstance
{
    static FGROptionManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self config];
    }
    return self;
}

- (void)config
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"FGRReadOptions.plist" ofType:nil];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
 
    _fontSizes = dict[@"fontSize"];
    _flipStyles = dict[@"flipStyle"];
    _languages = dict[@"languages"];
    
 
    NSDictionary<NSString*, NSNumber*> *lineSpaceDict = dict[@"lineSpace"];
    NSArray *lineSpaceKeys = [lineSpaceDict keysSortedByValueUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return obj1.integerValue >= obj2.integerValue;
    }];
    NSMutableArray *values = [NSMutableArray array];
    for(NSString *lineSpaceKey in lineSpaceKeys) {
        NSNumber *lineSpace = lineSpaceDict[lineSpaceKey];
        [values addObject:lineSpace];
    }
    _lineSpaceNames = lineSpaceKeys;
    _lineSpaceValues = values;
    
    
    NSDictionary *fontStyleDict = dict[@"fontStyle"];
    _fontStyleNames = fontStyleDict[@"keys"];
    _fontStyleValues = fontStyleDict[@"values"];
    
    _fontSizeIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kFontSize];
    _lineSpaceIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kLineSpace];
    _flipStyleIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kFlipStyle];
    _fontStyleIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kFontStyle];
    _languagesIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kLanguages];
    _backgroundColorIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kBGColorIndex];
}

- (void)setFontSizeIndex:(NSInteger)fontSizeIndex
{
    if (_fontSizeIndex != fontSizeIndex) {
        _fontSizeIndex = fontSizeIndex;
        [[NSUserDefaults standardUserDefaults] setInteger:_fontSizeIndex forKey:kFontSize];
        [self updateShowAttributeBlock];
        [[NSNotificationCenter defaultCenter] postNotificationName:FGRReadTextShowChangeNoti object:nil];
    }
}

- (void)setLineSpaceIndex:(NSInteger)lineSpaceIndex
{
    if (_lineSpaceIndex != lineSpaceIndex) {
        _lineSpaceIndex = lineSpaceIndex;
        [[NSUserDefaults standardUserDefaults] setInteger:lineSpaceIndex forKey:kLineSpace];
        [self updateShowAttributeBlock];
        [[NSNotificationCenter defaultCenter] postNotificationName:FGRReadTextShowChangeNoti object:nil];
    }
}

- (void)setFlipStyleIndex:(NSInteger)flipStyleIndex
{
    if (_flipStyleIndex != flipStyleIndex) {
        _flipStyleIndex = flipStyleIndex;
        [[NSUserDefaults standardUserDefaults] setInteger:flipStyleIndex forKey:kFlipStyle];
    }
}

- (void)setFontStyleIndex:(NSInteger)fontStyleIndex
{
    if (_fontStyleIndex != fontStyleIndex) {
        _fontStyleIndex = fontStyleIndex;
        [[NSUserDefaults standardUserDefaults] setInteger:fontStyleIndex forKey:kFontStyle];
        [self updateShowAttributeBlock];
        [[NSNotificationCenter defaultCenter] postNotificationName:FGRReadTextShowChangeNoti object:nil];
    }
}


- (void)setLanguagesIndex:(NSInteger)languagesIndex
{
    if (_languagesIndex != languagesIndex) {
        _languagesIndex = languagesIndex;
        [[NSUserDefaults standardUserDefaults] setInteger:languagesIndex forKey:kLanguages];
    }
}

- (void)setBackgroundColorIndex:(NSInteger)backgroundColorIndex
{
    if (_backgroundColorIndex == backgroundColorIndex) {
        return;
    }
    _backgroundColorIndex = backgroundColorIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:backgroundColorIndex forKey:kBGColorIndex]; 
}

- (NSAttributedString *(^)(NSString *))textShowAttribute
{
    if (!_textShowAttribute) {
        [self updateShowAttributeBlock];
    }
    return _textShowAttribute;
}

- (UIColor *)readBgColor
{
    NSString *name = [NSString stringWithFormat:@"reader_bg%ld", self.backgroundColorIndex + 1];
    return [UIColor colorWithPatternImage:[UIImage imageNamed:name]];
}

- (void)updateShowAttributeBlock
{
    CGFloat fontSize = [[self valueForSelectIndexWithType:FGRReadOptionTypeFontSize] floatValue];
    NSString *fontName = [self valueForSelectIndexWithType:FGRReadOptionTypeFontStyle];
    CGFloat lineSpace = [[self valueForSelectIndexWithType:FGRReadOptionTypeLineSpace] floatValue];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = lineSpace;
    
    UIFont *font = nil;
    if ([fontName isEqualToString:@""] || fontName == nil) {
        font = [UIFont systemFontOfSize:fontSize];
    } else {
        font = [UIFont fontWithName:fontName size:fontSize];
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: font, NSParagraphStyleAttributeName: style};
    
    _textShowAttribute = ^NSAttributedString *(NSString *text) {
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    };
}

#pragma mark -

- (void)setSelectIndex:(NSInteger)selectIndex forType:(FGRReadOptionType)type
{
    switch (type) {
        case FGRReadOptionTypeFontSize:
            self.fontSizeIndex = selectIndex;
            break;
        case FGRReadOptionTypeLanguage:
            self.languagesIndex = selectIndex;
            break;
        case FGRReadOptionTypeFlipStyle:
            self.flipStyleIndex = selectIndex;
            break;
        case FGRReadOptionTypeFontStyle:
            self.fontStyleIndex = selectIndex;
            break;
        case FGRReadOptionTypeLineSpace:
            self.lineSpaceIndex = selectIndex;
            break;
    }
}

- (NSInteger)selectIndexWith:(FGRReadOptionType)type
{
    switch (type) {
        case FGRReadOptionTypeFontSize:
            return self.fontSizeIndex;
        case FGRReadOptionTypeLanguage:
            return self.languagesIndex;
        case FGRReadOptionTypeFlipStyle:
            return self.flipStyleIndex;
        case FGRReadOptionTypeFontStyle:
            return self.fontStyleIndex;
        case FGRReadOptionTypeLineSpace:
            return self.lineSpaceIndex;
    }
}

- (NSArray *)keysWith:(FGRReadOptionType)type
{
    switch (type) {
        case FGRReadOptionTypeLineSpace:
            return self.lineSpaceNames;
        case FGRReadOptionTypeFontStyle:
            return self.fontStyleNames;
        case FGRReadOptionTypeFlipStyle:
            return self.flipStyles;
        case FGRReadOptionTypeLanguage:
            return self.languages;
        case FGRReadOptionTypeFontSize:
            return self.fontSizes;
    }
}

- (id)valueForSelectIndexWithType:(FGRReadOptionType)type
{
    switch (type) {
        case FGRReadOptionTypeLineSpace:
            return self.lineSpaceValues[self.lineSpaceIndex];
        case FGRReadOptionTypeFontStyle:
            return self.fontStyleValues[self.fontStyleIndex];
        case FGRReadOptionTypeFlipStyle:
            return self.flipStyles[self.flipStyleIndex];
        case FGRReadOptionTypeLanguage:
            return self.languages[self.languagesIndex];
        case FGRReadOptionTypeFontSize:
            return self.fontSizes[self.fontSizeIndex];
    }
}

- (NSString *)keyForSelectIndexWithType:(FGRReadOptionType)type
{
    switch (type) {
        case FGRReadOptionTypeLineSpace:
            return self.lineSpaceNames[self.lineSpaceIndex];
        case FGRReadOptionTypeFontStyle:
            return self.fontStyleNames[self.fontStyleIndex];
        case FGRReadOptionTypeFlipStyle:
            return self.flipStyles[self.flipStyleIndex];
        case FGRReadOptionTypeLanguage:
            return self.languages[self.languagesIndex];
        case FGRReadOptionTypeFontSize:
            return self.fontSizes[self.fontSizeIndex].description;
    }
}

@end


























