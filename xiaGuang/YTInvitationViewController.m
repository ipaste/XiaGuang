//
//  YTInvitationViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-28.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTInvitationViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
@interface YTInvitationViewController (){
    UIView *_mainView;
    NSMutableArray *_invitationButtons;
    UIImageView *_QrCodeImageView;
    UILabel *_titleLable;
    UILabel *_subTitleLabel;
}
@end

@implementation YTInvitationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"邀请好友使用虾逛";
    _mainView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 142)];
    _mainView.backgroundColor = [UIColor whiteColor];
    UIImageView *shadowView = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(_mainView.frame), CGRectGetWidth(_mainView.frame), 3)];
    shadowView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"set_img_shadow"]];
    [_mainView addSubview:shadowView];
    [self.view addSubview:_mainView];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_1"]];

    NSArray *buttonNames = @[@"微信好友",@"微信朋友圈",@"QQ好友",@"短信"];
    NSArray *buttonImages = @[@"set_ico_wx_un",@"set_ico_pyq_un",@"set_ico_qq_un",@"set_ico_dx_un"];
    NSArray *buttonHigLight = @[@"set_ico_wx_pr",@"set_ico_pyq_pr",@"set_ico_qq_pr",@"set_ico_dx_pr"];
    
    for (int i = 0 ; i < buttonImages.count; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16 + i % 4 * 76, 30, 60, 60)];
        button.tag = i;
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",buttonImages[i]]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",buttonHigLight[i]]] forState:UIControlStateHighlighted];
        [_mainView addSubview:button];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(button.frame) + 10, 60, 12)];
        label.center = CGPointMake(button.center.x, label.center.y);
        label.textColor = [UIColor colorWithString:@"404040"];
        label.textAlignment = 1;
        label.font = [UIFont systemFontOfSize:12];
        label.text = buttonNames[i];
        [_mainView addSubview:label];
    }
    
    CGPoint center = CGPointMake(self.view.center.x,( CGRectGetHeight(self.view.frame) - CGRectGetHeight(_mainView.frame)) / 2 + CGRectGetMaxY(_mainView.frame) - 41);
    _QrCodeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 154, 154)];
    _QrCodeImageView.center = center;
    _QrCodeImageView.image = [UIImage imageNamed:@"set_img_scan"];
    [self.view addSubview:_QrCodeImageView];
    
    _titleLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_QrCodeImageView.frame), CGRectGetMaxY(_QrCodeImageView.frame) + 8, CGRectGetWidth(_QrCodeImageView.frame), 16)];
    _titleLable.text = @"直接扫描二维码";
    _titleLable.textAlignment = 1;
    _titleLable.textColor = [UIColor colorWithString:@"202020"];
    _titleLable.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:_titleLable];
    
    _subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_titleLable.frame), CGRectGetMaxY(_titleLable.frame) + 5, CGRectGetWidth(_titleLable.frame), 14)];
    _subTitleLabel.text = @"邀请好友安装虾逛";
    _subTitleLabel.textColor = [UIColor colorWithString:@"909090"];
    _subTitleLabel.font = [UIFont systemFontOfSize:14];
    _subTitleLabel.textAlignment = 1;
    [self.view addSubview:_subTitleLabel];
    
}

@end
