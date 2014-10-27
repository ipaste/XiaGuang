//
//  YTPoiButton.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-16.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTPoiButton.h"
@interface YTPoiButton(){
    UIImageView *_backgroundImageView;
}
@end

@implementation YTPoiButton
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(4, 4,CGRectGetWidth(frame) - 8,CGRectGetHeight(frame) - 8)];
        _backgroundImageView.image = [UIImage imageNamed:@"nav_ico_more_un"];
        [self addTarget:self action:@selector(clickToButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backgroundImageView];
    }
    return self;
}

-(void)layoutSubviews{
    
    
    self.backgroundColor = [UIColor colorWithRed:233/255.0f green:94/255.0 blue:55/255.0 alpha:0.9];
    self.layer.cornerRadius = CGRectGetWidth(self.frame) / 2;
}

-(void)clickToButton:(UIButton *)sender{
    [self.delegate poiButtonClicked];
}
@end
