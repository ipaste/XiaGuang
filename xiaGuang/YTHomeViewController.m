//
//  ViewController.m
//  xiaGuang
//
//  Created by YunTop on 14-10-24.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTHomeViewController.h"

@interface YTHomeViewController (){
    YTPanel *_panel;
}
@end

@implementation YTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _panel = [[YTPanel alloc]initWithFrame:CGRectMake(0, 0, 300, 300) items:@[@"商城",@"停车",@"设置",@"地图"]];
    _panel.delegate = self;
    [self.view addSubview:_panel];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButtonItemCustomView]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self rightBarButtonItemCustomView]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"all_bg_navbar-1"] forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.title = @"虾逛";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillLayoutSubviews{
    _panel.center = CGPointMake(self.view.center.x, self.view.center.y - 64);
    
}

-(UIView *)leftBarButtonItemCustomView{
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 60, 40)];
    [leftButton setTitle:@"深圳" forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor colorWithString:@"#fac890"] forState:UIControlStateHighlighted];
    [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0 , -10, 0, 0)];
    [leftButton setImage:[UIImage imageNamed:@"home1_ico_location_un"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"home1_ico_location_pr"] forState:UIControlStateHighlighted];
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    return leftButton;
}

-(UIView *)rightBarButtonItemCustomView{
    UIImage *image = [UIImage imageNamed:@"nav_ico_search_un"];
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, image.size.width, image.size.height)];
    [rightButton setImage:image forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(jumpToSearch:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImage:[UIImage imageNamed:@"nav_ico_search_pr"] forState:UIControlStateHighlighted];
    return rightButton;
}


-(void)clickedPanelAtIndex:(NSInteger)index{
    UIViewController *controller = nil;
    switch (index) {
        case 0:
            controller = [[YTMallViewController alloc]init];
            break;
        case 1:
            
            break;
        case 2:
        {
            controller = [[YTSettingViewController alloc]init];
        }
            break;
        case 3:
            
            break;
    }
    [self.navigationController pushViewController:controller animated:NO];
}

-(void)jumpToSearch:(UIButton *)sender{
    YTSearchViewController *searchVC = [[YTSearchViewController alloc]init];
    [self.navigationController pushViewController:searchVC animated:YES];
}
@end
