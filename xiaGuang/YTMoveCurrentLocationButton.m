//
//  YTMoveCurrentLocationButton.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-15.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTMoveCurrentLocationButton.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
@interface YTMoveCurrentLocationButton(){
    UIImageView *_backgroundImageView;
    UIImage *_defaultImage;
}
@end
@implementation YTMoveCurrentLocationButton
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
        _defaultImage = [UIImage imageNamed:@"nav_ico_me_un"];
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

-(void)promptFloorChange:(NSString *)floorName{
    _backgroundImageView.image = [UIImage imageNamed:@"nav_ico_floor"];
    [self setTitle:floorName forState:UIControlStateNormal];
    [self.layer removeAllAnimations];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.toValue = [NSNumber numberWithFloat:0];
    animation.fromValue = [NSNumber numberWithFloat:1];
    animation.duration = 0.5;
    animation.delegate = self;
    animation.repeatCount = 5;
    [self.layer addAnimation:animation forKey:@"animation"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        _backgroundImageView.image = _defaultImage;
        [self setTitle:@"" forState:UIControlStateNormal];
    }
}

-(void)pressTheButton{
    _backgroundImageView.image = [UIImage imageNamed:@"nav_ico_me_pr"];
}

-(void)letTheButton{
    _backgroundImageView.image = _defaultImage;
    [self.delegate moveToUserLocationButtonClicked];
}
@end
