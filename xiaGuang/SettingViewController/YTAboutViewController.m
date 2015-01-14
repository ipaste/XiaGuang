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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButton]];
    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
    
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
    backgroundView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
    [self.view addSubview:backgroundView];
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat y = 0;
    if (size.height <= 480) {
        y = 80 + CGRectGetMaxY(self.navigationController.navigationBar.frame);
    }else{
        y = 130 + CGRectGetMaxY(self.navigationController.navigationBar.frame);
    }
    _iconView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) / 2 - 50, y, 100, 100)];
    _iconView.image = [UIImage imageNamed:@"set_img_logo"];
    _iconView.layer.cornerRadius = 15;
    _iconView.layer.masksToBounds = YES;
    [self.view addSubview:_iconView];
    
    _titleLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_iconView.frame), CGRectGetMaxY(_iconView.frame) + 10, CGRectGetWidth(_iconView.frame), 20)];
    _titleLable.textAlignment = 1;
    _titleLable.text = @"虾逛";
    _titleLable.textColor = [UIColor colorWithString:@"333333"];
    _titleLable.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:_titleLable];
    
    _subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_titleLable.frame), CGRectGetMaxY(_titleLable.frame) + 5, CGRectGetWidth(_titleLable.frame), 13)];
    _subTitleLabel.text = [NSString stringWithFormat:@"V%@",[[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleShortVersionString"]];
    _subTitleLabel.textAlignment = 1;
    _subTitleLabel.textColor = [UIColor colorWithString:@"666666"];
    _subTitleLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:_subTitleLabel];
    
    
    _copyright = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 15 - 18, size.width, 15)];
    _copyright.text = @"Copyright©2014志展云图信息科技有限公司";
    _copyright.textColor = [UIColor colorWithString:@"909090"];
    _copyright.textAlignment = 1;
    _copyright.font = [UIFont systemFontOfSize:11];
    [self.view addSubview:_copyright];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.clipsToBounds = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithString:@"e65e37"] forKey:NSForegroundColorAttributeName]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
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


@end
