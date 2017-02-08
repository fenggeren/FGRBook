//
//  FGRPage.h
//  FGRBook
//
//  Created by fenggeren on 2016/9/23.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface FGRPage : NSObject

@property (nonatomic, assign) CTFrameRef frameRef;

@property (nonatomic, copy) NSAttributedString *content;

@property (nonatomic, assign) NSInteger index;

@end
