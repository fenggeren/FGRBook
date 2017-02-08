//
//  FGRPageView.m
//  FGRBook
//
//  Created by fenggeren on 16/9/13.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRPageView.h"
#import "NSTimer+FGRBlock.h"
#import "FGRPage.h"

@interface FGRPageView ()

@property (nonatomic, strong) IBOutlet UITextView *textView;

@end


@implementation FGRPageView

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setPage:(FGRPage *)page
{
    _page = page;
    
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    if (self.page.frameRef) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGAffineTransform transform = CGAffineTransformMake(1, 0, 0, -1, 0, self.bounds.size.height);
        CGContextConcatCTM(ctx, transform);
        
        CTFrameDraw(self.page.frameRef, ctx);
    }
}

@end

 







