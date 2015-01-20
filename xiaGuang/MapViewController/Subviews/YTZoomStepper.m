//
//  YTZoomSteeper.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-8-13.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTZoomStepper.h"
#define BORDERWIDTH 0.5
@implementation YTZoomStepper{
    UIButton *_increasing;
    UIButton *_diminishing;
    UIView *_centerBorder;
}

-(id)init{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _increasing = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 41)];
        [self addSubview:_increasing];
       
        _diminishing = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(frame) / 2, CGRectGetWidth(_increasing.frame), 41)];
        [self addSubview:_diminishing];
        
        _centerBorder = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(frame) / 2, CGRectGetWidth(frame), BORDERWIDTH)];
        [self addSubview:_centerBorder];
    }
    return self;
}

-(void)layoutSubviews{
    [_diminishing setImage:[UIImage imageNamed:@"nav_btn_minus"] forState:UIControlStateNormal];
    [_diminishing setImage:[UIImage imageNamed:@"nav_btn_minusOn"] forState:UIControlStateHighlighted];
    [_diminishing addTarget:self action:@selector(diminishing:) forControlEvents:UIControlEventTouchUpInside];
    
    [_increasing setImage:[UIImage imageNamed:@"nav_btn_plus"] forState:UIControlStateNormal];
    [_increasing setImage:[UIImage imageNamed:@"nav_btn_plusOn"] forState:UIControlStateHighlighted];
    [_increasing addTarget:self action:@selector(increasing:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)increasing:(UIButton *)sender{
    [self.delegate increasing];
}

-(void)diminishing:(UIButton *)sender{
    [self.delegate diminishing];
}

@end
