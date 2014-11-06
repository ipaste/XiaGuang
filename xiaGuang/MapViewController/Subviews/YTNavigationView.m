//
//  YTNavigationView.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-4.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTNavigationView.h"
#import "YTNavigationInstruction.h"
#import "POP.h"
#import "YTMessageBox.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#define TEXTCOLOR_AND_ARROWCOLOR [UIColor colorWithRed:139/255.0f green:139/255.0f blue:139/255.0f alpha:1.0]


@interface YTNavigationView ()<YTMessageBoxDelegate>{
    UILabel *_label;
    UILabel *_subLabel;
    UIButton *_startNavigation;
    UIButton *_switchButton;
    UIImageView *_icon;
    YTMessageBox *_messageBox;
    id <YTPoiSource> _poiSource;
}
@end

@implementation YTNavigationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 200, 30)];
        _subLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_label.frame) + 22, CGRectGetMaxY(_label.frame), 200, 20)];
        
        _icon = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_label.frame), CGRectGetMaxY(_label.frame), 20, 20)];
        
        
        _startNavigation = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(frame) - 85, 4, 75, 57)];
        
        _switchButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_startNavigation.frame) - CGRectGetWidth(_startNavigation.frame) - 5, CGRectGetMinY(_startNavigation.frame), CGRectGetWidth(_startNavigation.frame), CGRectGetHeight(_startNavigation.frame))];
        _messageBox = [[YTMessageBox alloc]initWithTitle:@"导航进行中..." Message:@"确定退出导航"];
        _messageBox.delegate = self;
        [self addSubview:_icon];
        [self addSubview:_switchButton];
        [self addSubview:_startNavigation];
        [self addSubview:_label];
        [self addSubview:_subLabel];
        _isCancelling = NO;
    }
    return self;
}

-(void)layoutSubviews{
    
    _label.font = [UIFont systemFontOfSize:14];
    _label.textColor = TEXTCOLOR_AND_ARROWCOLOR;
    _label.text = [NSString stringWithFormat:@"终点:%@",_poiSource.name];
    
    
    _subLabel.font = [UIFont systemFontOfSize:17];
    _subLabel.textColor = [UIColor whiteColor];
    
    
    [_startNavigation setTitle:@"结束" forState:UIControlStateNormal];
    [_startNavigation setBackgroundColor:[UIColor colorWithString:@"464646"]];
    _startNavigation.layer.cornerRadius = CGRectGetHeight(_startNavigation.frame) / 2;
    _startNavigation.layer.borderWidth = 5;
    [_startNavigation addTarget:self action:@selector(clickStopNavigationButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [_switchButton setTitle:@"切换" forState:UIControlStateNormal];
    [_switchButton setBackgroundColor:[UIColor colorWithString:@"0084ff"]];
    _switchButton.layer.borderWidth = _startNavigation.layer.borderWidth;
    _switchButton.layer.cornerRadius = (CGRectGetHeight(self.frame) - 8) / 2;
    [_switchButton addTarget:self action:@selector(jumToBeacon:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)setIsShowSwitchButton:(BOOL)isShowSwitchButton{
    _switchButton.hidden = !isShowSwitchButton;
    
    _isShowSwitchButton = isShowSwitchButton;
    if (!_switchButton.hidden) {
        [self showSwitchAnimation];
    }
}

-(void)startNavigationAndSetDestination:(id <YTPoiSource>)source{
    
    _poiSource = source;
    _isNavigating = YES;
    [self setNeedsLayout];
}

-(void)clickStopNavigationButton:(UIButton *)sender{
    [_messageBox show];
}

-(void)jumToBeacon:(UIButton *)sender{
    [self.delegate jumToUserFloor];
}


-(void)updateInstruction{
   
    YTNavigationInstruction *instruction = [self.plan getInstruction];
    
    NSString *target = [[[[self.plan.targetPoiSource majorArea] floor] floorName] componentsSeparatedByString:@"F"][0];
    NSString *current = [[[[self.plan.userMinorArea majorArea] floor] floorName]componentsSeparatedByString:@"F"][0];
    if ([target integerValue] > [current integerValue]) {
        
        _icon.image = [UIImage imageNamed:@"nav_img_tip_up"];
        
    }else if ([target integerValue] < [current integerValue]){
        
        _icon.image = [UIImage imageNamed:@"nav_img_tip_down"];
        
    }else{
        
        _icon.image = [UIImage imageNamed:@"nav_img_tip_end"];
    }
    
    if (instruction.leftInstruction != nil) {
        _label.text = [NSString stringWithFormat:@"%@,%@",instruction.leftInstruction,instruction.rightInstruction];
    }else{
        _label.text = instruction.rightInstruction;
    }
    
    
    _subLabel.text = instruction.mainInstruction;
}

-(void)showSwitchAnimation{
    [_switchButton.layer removeAllAnimations];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.toValue = [NSNumber numberWithFloat:0];
    animation.fromValue = [NSNumber numberWithFloat:1];
    animation.duration = 1;
    animation.repeatCount = 2;
    [_switchButton.layer addAnimation:animation forKey:@"animation"];
}


-(void)clickToButtonAtTag:(NSInteger)tag{
    
    if (tag == 1) {        
        [self stopNavigationMode];
    }
}


-(void)stopNavigationMode{
    _isCancelling = YES;
    [self.delegate stopNavigationMode];
    _isCancelling = NO;
    _isNavigating = NO;
}


-(void)shakeView{
    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    positionAnimation.velocity = @1000;
    positionAnimation.springBounciness = 20;
    [self.layer pop_addAnimation:positionAnimation forKey:@"positionAnimation"];
}
@end
