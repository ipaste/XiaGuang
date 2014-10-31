//
//  YTCurrentParkingButton.m
//  xiaGuang
//
//  Created by YunTop on 14/10/31.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTCurrentParkingButton.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
@interface YTCurrentParkingButton(){
    UIImageView *_backgroundImageView;
    UIImage *_defaultImage;
}
@end
@implementation YTCurrentParkingButton
-(instancetype)init{
    return nil;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    return nil;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(4, 4, CGRectGetWidth(self.frame) - 8, CGRectGetHeight(self.frame) - 8)];
        _defaultImage = [UIImage imageNamed:@"parking_ico_car_un"];
        _backgroundImageView.image = _defaultImage;
        [self addSubview:_backgroundImageView];
        [self addTarget:self action:@selector(pressTheButton) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(letTheButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)layoutSubviews{
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    self.layer.cornerRadius = CGRectGetWidth(self.frame) / 2;
    [self.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self setTitleColor:[UIColor colorWithString:@"ff4200"] forState:UIControlStateNormal];
}

-(void)pressTheButton{
    _backgroundImageView.image = [UIImage imageNamed:@"parking_ico_car_pr"];
}

-(void)letTheButton{
    _backgroundImageView.image = _defaultImage;
    if ([self.delegate respondsToSelector:@selector(moveCurrentParkingPositionClicked)]) {
        [self.delegate moveCurrentParkingPositionClicked];
    }
}
@end
