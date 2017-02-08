//
//  FGRChapterListController.m
//  FGRBook
//
//  Created by fenggeren on 16/9/16.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRChapterListController.h"
#import "FGRDataManager.h"
#import "FGRChapterInfoModel.h" 
#import "FGRNovelModel.h"
#import "UIImage+FGRExtension.h"

@interface FGRChapterListController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readonly) NSArray *chapters;
@end

@implementation FGRChapterListController

@dynamic chapters;

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    self.title = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger curIndex = self.novelModel.curIndex;
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:curIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    });
}

#pragma mark --

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chapters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FGRChapterInfoModel *model = self.chapters[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class) forIndexPath:indexPath];
    cell.textLabel.text = model.name;
    if (self.novelModel.curIndex == indexPath.row) {
        cell.textLabel.textColor = [UIColor redColor];
    }else if (model.isLoaded) {
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.selectBlock) {
        if (self.selectBlock(indexPath.row)) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - 

- (NSArray *)chapters
{
    return self.novelModel.chapters;
}

@end








