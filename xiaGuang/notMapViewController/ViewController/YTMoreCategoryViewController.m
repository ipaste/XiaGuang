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
@interface YTMoreCategoryViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSArray *_categorys;
    UITableView *_tableView;
}
@end

@implementation YTMoreCategoryViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButton]];
    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.navigationItem.title = @"更多分类";
    
    _tableView = [[UITableView alloc]init];
     _tableView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame));
    _tableView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    
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

-(UIView *)leftBarButton{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 35, 20, 20, 20)];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icon_backOn"] forState:UIControlStateHighlighted];
    return button;
}

-(void)back:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)dealloc{
    NSLog(@"YTMoreCategory页面销毁");
}

@end
