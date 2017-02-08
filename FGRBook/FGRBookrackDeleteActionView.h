//
//  FGRBookrackDeleteActionView.h
//  FGRBook
//
//  Created by fenggeren on 2016/11/2.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FGRBookrackDeleteActionView : UIView

+ (instancetype)showInView:(UIView *)superView clickBlock:(void(^)(NSInteger index))block;

- (void)show;
- (void)dismiss;

@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@end
