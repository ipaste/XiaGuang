//
//  YTMoveTargetLocationButton.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-16.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTMoveTargetLocationButton.h"
@interface YTMoveTargetLocationButton (){
    UIImageView *_backgroundImageView;
    UIImage *_defaultImage;
}
@end

@implementation YTMoveTargetLocationButton
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(4, 4, CGRectGetWidth(self.frame) - 8, CGRectGetHeight(self.frame) - 8)];
        _defaultImage = [UIImage imageNamed:@"nav_ico_end_un"];
        _backgroundImageView.image = _defaultImage;
        [self addTarget:self action:@selector(letTheButton) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(pressTheButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backgroundImageView];
        
    }
    return self;
}
-(void)layoutSubviews{
    self.layer.cornerRadius = CGRectGetWidth(self.frame) / 2;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
}

-(void)pressTheButton{
    _backgroundImageView.image = _defaultImage;
}

-(void)letTheButton{
    _backgroundImageView.image = [UIImage imageNamed:@"nav_ico_end_pr"];
    [self.delegate moveToTargetLocationButtonClicked];
}
@end
