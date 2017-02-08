//
//  FGRReadNovelMoreMenu.m
//  FGRBook
//
//  Created by fenggeren on 2016/10/26.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRReadNovelMoreMenu.h"

#define kAlphaBlackColor [UIColor darkGrayColor]
#define kAnimateDuration 0.3

@interface FGRReadNovelMoreMenu ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FGRReadNovelMoreMenu

+ (instancetype)showInView:(UIView *)v delegate:(id<FGRReadNovelMoreMenuProtocol>)delegate
{
    FGRReadNovelMoreMenu *menu = [[UINib nibWithNibName:@"FGRReadNovelMoreMenu" bundle:nil] instantiateWithOwner:self options:nil].firstObject;
    menu.delegate = delegate;
    [v addSubview:menu];
    [menu show];
    return menu;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = 40;
    self.tableView.backgroundColor = kAlphaBlackColor;
    self.tableView.scrollEnabled = NO;
}


#pragma mark - 


- (void)show
{
    NSArray *items = [self.delegate menuItemsInReadNovelMoreMenu:self];
    CGFloat height = self.tableView.rowHeight * items.count + 10;
    CGFloat width = 180;
    CGFloat oriX = self.superview.width - width - 8;
    
    __block CGRect frame = CGRectMake(oriX, -height, width, height);
    self.frame = frame;
    [UIView animateWithDuration:kAnimateDuration animations:^{
        frame.origin = CGPointMake(oriX, 64);
        self.frame = frame;
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:kAnimateDuration animations:^{
        CGRect frame = self.frame;
        frame.origin = CGPointMake(frame.origin.x, -frame.size.height);
        self.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.delegate menuItemsInReadNovelMoreMenu:self].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = kAlphaBlackColor;
        cell.contentView.backgroundColor = kAlphaBlackColor;
    }
    
    FGRReadNovelMoreMenuItem *item = [self.delegate menuItemsInReadNovelMoreMenu:self][indexPath.row];
    cell.imageView.image = [UIImage imageNamed:item.iconName];
    cell.detailTextLabel.text = item.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FGRReadNovelMoreMenuItem *item = [self.delegate menuItemsInReadNovelMoreMenu:self][indexPath.row];
    if (item.clickAction) {
        item.clickAction();
    }
    [self dismiss];
}

@end




@implementation FGRTriangle

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(rect.size.width * 0.5, 0)];
    [path addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    [path addLineToPoint:CGPointMake(0, rect.size.height)];
    [kAlphaBlackColor set];
    [path fill];
}

@end


@implementation FGRReadNovelMoreMenuItem

- (instancetype)initWith:(NSString *)iconName title:(NSString *)title clickAction:(dispatch_block_t)action
{
    if (self = [super init]) {
        self.iconName = iconName;
        self.title = title;
        self.clickAction = action;
    }
    return self;
}

@end
