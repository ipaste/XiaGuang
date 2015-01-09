//
//  YTMallPosistionViewController.m
//  xiaGuang
//
//  Created by YunTop on 14/11/5.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTMallPosistionViewController.h"

@implementation YTMallPosistionViewController{
    UIView *_detailsView;
    UIImageView *_mapImageView;
    UILabel *_phoneNumberLabel;
    UILabel *_addressLabel;
}

-(instancetype)initWithImage:(UIImage *)image address:(NSString *)address phoneNumber:(NSString *)phoneNumber{
    self = [super init];
    if (self) {
        
        
        self.navigationItem.title = @"商圈位置";
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButton]];
        self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
        
        
        _mapImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, CGRectGetMaxY(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame) - 165)];
        _mapImageView.contentMode = UIViewContentModeScaleAspectFill;
        _mapImageView.clipsToBounds = true;
        _mapImageView.image = image;
        [self.view addSubview:_mapImageView];
        
        _detailsView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame) - 101, CGRectGetWidth(self.view.frame), 101)];
        _detailsView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_detailsView];
        
        _phoneNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(38, 51, CGRectGetWidth(self.view.frame), 50)];
        if (phoneNumber.length <= 0) {
            phoneNumber = @"无";
        }
        _phoneNumberLabel.text = phoneNumber;
        _phoneNumberLabel.textColor = [UIColor colorWithString:@"ffffff"];
        _phoneNumberLabel.font = [UIFont systemFontOfSize:15];
        [_detailsView addSubview:_phoneNumberLabel];
        
        UIImageView *phoneIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_phone"]];
        phoneIcon.center = CGPointMake(15 + CGRectGetWidth(phoneIcon.frame) / 2, _phoneNumberLabel.center.y);
        [_detailsView addSubview:phoneIcon];
        

        _addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(38, 0, CGRectGetWidth(self.view.frame), 50)];
        _addressLabel.text = address;
        _addressLabel.textColor = [UIColor colorWithString:@"ffffff"];
        _addressLabel.font = [UIFont systemFontOfSize:15];
        [_detailsView addSubview:_addressLabel];
        
        UIImageView *addressIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_location"]];
        addressIcon.center = CGPointMake(15 + CGRectGetWidth(addressIcon.frame) / 2, _addressLabel.center.y);
        [_detailsView addSubview:addressIcon];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(_detailsView.frame) / 2, CGRectGetWidth(self.view.frame), 0.5)];
        line.backgroundColor = [UIColor colorWithString:@"dcdcdc"];
        //[_detailsView addSubview:line];
        
        self.view.clipsToBounds = YES;

    }
    return self;
}
-(void)viewWillLayoutSubviews{
    _mapImageView.center = CGPointMake(self.view.center.x, _mapImageView.center.y + CGRectGetMaxY(self.navigationController.navigationBar.frame));
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
    NSLog(@"dealloc MALLPOSITIONVIEW");
}
@end
