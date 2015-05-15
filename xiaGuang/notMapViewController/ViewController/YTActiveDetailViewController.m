//
//  YTActiveDetailViewController.m
//  虾逛
//
//  Created by Yuntop on 15/5/14.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTActiveDetailViewController.h"
#import "YTActiveDetailCell.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface YTActiveDetailViewController ()<UITableViewDataSource,UITableViewDelegate> {
    UITableView *_mainTableView;
    UIImageView *_imgView;
}

@end

@implementation YTActiveDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame)) style:UITableViewStylePlain];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    [_mainTableView setBackgroundColor:[UIColor clearColor]];
    _mainTableView.separatorColor = [UIColor colorWithString:@"e5e5e5"];
    _mainTableView.separatorInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
    _mainTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_mainTableView];
    
    self.navigationItem.title = @"活动详情";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButton]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithString:@"e65e37"] forKey:NSForegroundColorAttributeName]];
    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    _imgView = [[UIImageView alloc]init];
    

    if (indexPath.row == 0) {
        _imgView.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, 232.0f);
        _imgView.image = [UIImage imageNamed:@"details_01.jpg"];
        [cell addSubview:_imgView];
        //cell.imgView.image = [UIImage imageNamed:@"details_01.jpg"];
    }
    else if (indexPath.row == 1) {
        _imgView.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, 266.0f);
        _imgView.image = [UIImage imageNamed:@"details_02.jpg"];
        [cell addSubview:_imgView];
        //cell.imgView.image = [UIImage imageNamed:@"details_02.jpg"];
    }
    else if (indexPath.row == 2) {
        _imgView.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, 238.0f);
        _imgView.image = [UIImage imageNamed:@"details_03.jpg"];
        [cell addSubview:_imgView];
        
        //cell.imgView.image = [UIImage imageNamed:@"details_03.jpg"];
    }
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 232.0f;
    }else if (indexPath.row == 1){
        return 266.0;
    }else {
        return 238.0f;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    NSLog(@"ActiveDetailDealloc");
}


@end
