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
        _mapImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        _mapImageView.image = image;
        
        _mapImageView.contentMode =UIViewContentModeScaleAspectFill;
        [self.view addSubview:_mapImageView];
        
        self.navigationItem.title = @"商圈位置";
        
        
        _detailsView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 101)];
        _detailsView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_detailsView];
        
        _phoneNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(38, 51, CGRectGetWidth(self.view.frame), 50)];
        if (phoneNumber.length <= 0) {
            phoneNumber = @"无";
        }
        _phoneNumberLabel.text = phoneNumber;
        _phoneNumberLabel.textColor = [UIColor colorWithString:@"202020"];
        _phoneNumberLabel.font = [UIFont systemFontOfSize:15];
        [_detailsView addSubview:_phoneNumberLabel];
        
        UIImageView *phoneIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mall_img_call"]];
        phoneIcon.center = CGPointMake(15 + CGRectGetWidth(phoneIcon.frame) / 2, _phoneNumberLabel.center.y);
        [_detailsView addSubview:phoneIcon];
        

        _addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(38, 0, CGRectGetWidth(self.view.frame), 50)];
        _addressLabel.text = address;
        _addressLabel.textColor = [UIColor colorWithString:@"202020"];
        _addressLabel.font = [UIFont systemFontOfSize:15];
        [_detailsView addSubview:_addressLabel];
        
        UIImageView *addressIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mall_img_locationinfor"]];
        addressIcon.center = CGPointMake(15 + CGRectGetWidth(addressIcon.frame) / 2, _addressLabel.center.y);
        [_detailsView addSubview:addressIcon];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(_detailsView.frame) / 2, CGRectGetWidth(self.view.frame), 0.5)];
        line.backgroundColor = [UIColor colorWithString:@"dcdcdc"];
        [_detailsView addSubview:line];
    }
    return self;
}
-(void)viewWillLayoutSubviews{
    CGFloat topHeight = [self.topLayoutGuide length];
    CGRect frame = _detailsView.frame;
    frame.origin.y = CGRectGetHeight(self.view.frame) - CGRectGetHeight(frame) - topHeight;
    _detailsView.frame = frame;
    
    
}

-(void)dealloc{
    NSLog(@"dealloc MALLPOSITIONVIEW");
}
@end
