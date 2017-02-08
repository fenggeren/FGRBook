//
//  FGRPage.m
//  FGRBook
//
//  Created by fenggeren on 2016/9/23.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRPage.h"


@interface FGRPage ()

@end


@implementation FGRPage

- (void)dealloc
{
    if (_frameRef) {
        CFRelease(_frameRef);
    }
}


- (void)setFrameRef:(CTFrameRef)frameRef
{
    if (_frameRef) {
        CFRelease(_frameRef);
    }
    _frameRef = frameRef;
}

@end
