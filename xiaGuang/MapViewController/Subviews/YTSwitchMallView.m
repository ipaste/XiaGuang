//
//  YTSwitchMallView.m
//  虾逛
//
//  Created by YunTop on 14/11/14.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTSwitchMallView.h"
#define DEFAULT_HEIGHT 150
@implementation YTSwitchMallView{
    CGRect _screenFrame;
    
    UIView *_backgroundView;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        _screenFrame =  [UIScreen mainScreen].bounds;
        self.frame = CGRectMake(50, 0, CGRectGetWidth(_screenFrame) - 100, DEFAULT_HEIGHT);
        
        _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        [self addSubview:_backgroundView];
    }
    return self;
}


-(void)layoutSubviews{
    _backgroundView.layer.cornerRadius = 10;
    _backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    
    
    self.center = CGPointMake(CGRectGetWidth(_screenFrame) / 2, CGRectGetHeight(_screenFrame) / 2 - 25);
}
@end
