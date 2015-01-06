//
//  YTAboutViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-28.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTAboutViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
@interface YTAboutViewController (){
    UIImageView *_iconView;
    UILabel *_titleLable;
    UILabel *_subTitleLabel;
    UILabel *_copyright;
}
@end

@implementation YTAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"关于虾逛";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_1"]];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat y = 0;
    if (size.height <= 480) {
        y = 80;
    }else{
        y = 130;
    }
    _iconView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) / 2 - 50, y, 100, 100)];
    _iconView.image = [UIImage imageNamed:@"set_img_logo"];
    _iconView.layer.cornerRadius = 10;
    _iconView.layer.masksToBounds = YES;
    [self.view addSubview:_iconView];
    
    _titleLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_iconView.frame), CGRectGetMaxY(_iconView.frame) + 10, CGRectGetWidth(_iconView.frame), 20)];
    _titleLable.textAlignment = 1;
    _titleLable.text = @"虾逛";
    _titleLable.textColor = [UIColor colorWithString:@"202020"];
    _titleLable.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:_titleLable];
    
    _subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_titleLable.frame), CGRectGetMaxY(_titleLable.frame) + 5, CGRectGetWidth(_titleLable.frame), 13)];
    _subTitleLabel.text = [NSString stringWithFormat:@"V%@",[[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleShortVersionString"]];
    _subTitleLabel.textAlignment = 1;
    _subTitleLabel.textColor = [UIColor colorWithString:@"909090"];
    _subTitleLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:_subTitleLabel];
    
    
    _copyright = [[UILabel alloc]initWithFrame:CGRectMake(0, size.height - 33 - 66, size.width, 15)];
    _copyright.text = @"Copyright©2014志展云图信息科技有限公司";
    _copyright.textColor = [UIColor colorWithString:@"909090"];
    _copyright.textAlignment = 1;
    _copyright.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:_copyright];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.clipsToBounds = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"all_bg_navbar"] forBarMetrics:UIBarMetricsDefault];
}


@end
