//
//  YTMoreCategoryViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-18.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTMoreCategoryViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "YTCategory.h"
#import "YTResultsViewController.h"
#import "YTMoreCategoryViewCell.h"
@interface YTMoreCategoryViewController (){
    NSArray *_categorys;
}
@end

@implementation YTMoreCategoryViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"all_bg_navbar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"更多分类";
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_1"]];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _categorys = [YTCategory allCategorys];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(jumpToCategory:) name:@"YTMoreCategoryTitle" object:nil];
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"YTMoreCategoryTitle" object:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _categorys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YTMoreCategoryViewCell *cell = [[YTMoreCategoryViewCell alloc]initWithCategory:_categorys[indexPath.row] reuseIdentifier:@"Cell"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [YTCategory calculateHeightForCategory:_categorys[indexPath.row]];
}

-(void)jumpToCategory:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSString *key = userInfo[@"title"];
    NSString *subKey = userInfo[@"subTitle"];
    YTResultsViewController *resultsVC =  nil;
    if ([subKey isEqualToString:@"全部"]) {
        subKey = nil;
    }
    resultsVC = [[YTResultsViewController alloc]initWithSearchInMall:_mall andResutsKey:key andSubKey:subKey];
    [self.navigationController pushViewController:resultsVC animated:YES];
}

-(void)dealloc{
    NSLog(@"YTMoreCategory页面销毁");
}

@end
