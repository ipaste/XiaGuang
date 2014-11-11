//
//  YTSwitchFloorView.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-10.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTSwitchFloorView.h"
#import "YTFloorView.h"
#define WIDTH_AND_HEIGHT 40
#define BUTTON_PADDING 4
@interface YTSwitchFloorView()<YTFloorViewDelegate>{
    id<YTMajorArea> _majorArea;
    UIButton *_floorButton;
    YTFloorView *_floorView;
    id<YTFloor> _floor;
}
@end

@implementation YTSwitchFloorView

-(id)initWithPosition:(CGPoint)position AndCurrentMajorArea:(id<YTMajorArea>)majorArea{
    self = [super initWithFrame:CGRectMake(position.x,position.y, WIDTH_AND_HEIGHT, WIDTH_AND_HEIGHT)];
    if (self) {
        _majorArea = majorArea;
        _floor = [majorArea floor];
        _floorButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, WIDTH_AND_HEIGHT, WIDTH_AND_HEIGHT)];
        
        _floorView = [[YTFloorView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_floorButton.frame), CGRectGetMaxY(_floorButton.frame), WIDTH_AND_HEIGHT,WIDTH_AND_HEIGHT) andItem:[[[_majorArea floor]block]floors]];
        [_floorButton setTitle:[[_majorArea floor]floorName] forState:UIControlStateNormal];
        _floorView.floorDelegate = self;
        _floorView.curFloor = [_majorArea floor];
        [self addSubview:_floorView];
        [self addSubview:_floorButton];
        UIImageView *floorImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"nav_ico_floor"]];
        floorImage.frame = CGRectMake(BUTTON_PADDING, BUTTON_PADDING, WIDTH_AND_HEIGHT - BUTTON_PADDING*2, WIDTH_AND_HEIGHT - BUTTON_PADDING * 2);
        [_floorButton addSubview:floorImage];
    }
    return self;
}

-(void)redrawWithMajorArea:(id<YTMajorArea>)majorArea{
    
    _majorArea = majorArea;
    
    _floor = [majorArea floor];
    
    [_floorButton removeFromSuperview];
    [_floorView removeFromSuperview];
    
    _floorButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, WIDTH_AND_HEIGHT, WIDTH_AND_HEIGHT)];
    
    _floorView = [[YTFloorView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_floorButton.frame), CGRectGetMaxY(_floorButton.frame), WIDTH_AND_HEIGHT,WIDTH_AND_HEIGHT) andItem:[[[_majorArea floor]block]floors]];
    [_floorButton setTitle:[[_majorArea floor]floorName] forState:UIControlStateNormal];
    _floorView.floorDelegate = self;
    _floorView.curFloor = [_majorArea floor];
    [self addSubview:_floorView];
    [self addSubview:_floorButton];
    UIImageView *floorImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"nav_ico_floor"]];
    floorImage.frame = CGRectMake(BUTTON_PADDING, BUTTON_PADDING, WIDTH_AND_HEIGHT - BUTTON_PADDING*2, WIDTH_AND_HEIGHT - BUTTON_PADDING * 2);
    [_floorButton addSubview:floorImage];
    
}

-(void)layoutSubviews{
   
    
    [_floorButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_floorButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_floorButton addTarget:self action:@selector(toggleFloorControl:) forControlEvents:UIControlEventTouchUpInside];
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    self.layer.cornerRadius = WIDTH_AND_HEIGHT / 2;
    self.layer.masksToBounds = YES;
}
-(void)toggleFloor{
    
    [self toggleFloorControl:_floorButton];
}
-(void)toggleFloorControl:(UIButton *)sender{
    if (self.toggle) {
        self.toggle = NO;
        [UIView animateWithDuration:.2 animations:^{
            CGRect frame = self.frame;
            frame.size.height = WIDTH_AND_HEIGHT;
            self.frame = frame;
        }];
    }else{
        self.toggle = YES;
        [UIView animateWithDuration:.2 animations:^{
            NSArray *floorItem = [[[_majorArea floor] block]floors];
            CGRect frame = self.frame;
            if (floorItem.count < 3) {
                frame.size.height = (floorItem.count + 1 ) * WIDTH_AND_HEIGHT + 24;
            }else{
                frame.size.height = 4.2 * WIDTH_AND_HEIGHT + 12;
            }
            self.frame = frame;
        }];
    }
}
-(void)promptFloorChange:(id<YTFloor>)floor{
    _majorArea = [floor majorAreas][0];
    [_floorButton  setTitle:[floor floorName] forState:UIControlStateNormal];
    _floorView.curFloor = floor;
}
-(void)floorView:(YTFloorView *)floorView clickButtonAtFloor:(id <YTFloor>)floor{
    [self toggleFloorControl:_floorButton];
    [self promptFloorChange:floor];
    [self.delegate switchFloor:floor];
}
@end
