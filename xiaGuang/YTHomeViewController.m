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
}

- (void)viewWillLayoutSubviews{
    _panel.center = self.view.center;
    
    self.navigationItem.title = @"虾逛";
    self.view.backgroundColor = [UIColor whiteColor];
}
-(void)clickedPanelAtIndex:(NSInteger)index{
    UIViewController *controller = nil;
    switch (index) {
        case 0:
            
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
@end
