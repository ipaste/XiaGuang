//
//  YTSwitchFloorView.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-10.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTSwitchFloorView.h"
#import "YTFloorView.h"
#define WIDTH_AND_HEIGHT 41
#define BUTTON_PADDING 4
@interface YTSwitchFloorView()<YTFloorViewDelegate>{
    id<YTMajorArea> _majorArea;
    UIButton *_floorButton;
    UIImageView *_backgroundView;
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
        
        _backgroundView = [[UIImageView alloc]initWithFrame:self.bounds];
        _backgroundView.image = [UIImage imageNamed:@"btbg_blockOn"];
        [self addSubview:_backgroundView];
        _floorButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, WIDTH_AND_HEIGHT, WIDTH_AND_HEIGHT)];
        _floorView = [[YTFloorView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_floorButton.frame), CGRectGetMinY(_floorButton.frame), WIDTH_AND_HEIGHT,WIDTH_AND_HEIGHT) andItem:[[[_majorArea floor]block]floors]];
        _floorView.alpha = 0;
        [_floorButton setTitle:[[_majorArea floor]floorName] forState:UIControlStateNormal];
        _floorView.floorDelegate = self;
        _floorView.curFloor = [_majorArea floor];
        [self addSubview:_floorView];
        [self addSubview:_floorButton];

        [_floorButton setBackgroundImage:[UIImage imageNamed:@"btbg_floor"] forState:UIControlStateNormal];
    }
    return self;
}

-(void)redrawWithMajorArea:(id<YTMajorArea>)majorArea{
    
    _majorArea = majorArea;
    
    _floor = [majorArea floor];
    
    //[_floorButton removeFromSuperview];
    [_floorView removeFromSuperview];
    
    //_floorButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, WIDTH_AND_HEIGHT, WIDTH_AND_HEIGHT)];
    
    _floorView = [[YTFloorView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_floorButton.frame), CGRectGetMinY(_floorButton.frame) + 5, WIDTH_AND_HEIGHT,WIDTH_AND_HEIGHT) andItem:[[[_majorArea floor]block]floors]];
    _floorView.alpha = 0;
    [_floorButton setTitle:[[_majorArea floor]floorName] forState:UIControlStateNormal];
    _floorView.floorDelegate = self;
    _floorView.curFloor = [_majorArea floor];
    [self addSubview:_floorView];
}

-(void)layoutSubviews{
    [_floorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_floorButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [_floorButton addTarget:self action:@selector(toggleFloorControl:) forControlEvents:UIControlEventTouchDown];
    
    _backgroundView.frame = self.bounds;
   // self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    self.layer.cornerRadius = WIDTH_AND_HEIGHT / 2;
    self.layer.masksToBounds = YES;
}

-(void)toggleFloor{
    
    [self toggleFloorControl:_floorButton];
}

-(void)toggleFloorControl:(UIButton *)sender{
    if (self.toggle) {
        self.toggle = NO;
        _floorButton.alpha = 1;
        _floorView.alpha = 0;
        [UIView animateWithDuration:.2 animations:^{
            CGRect frame = self.frame;
            frame.size.height = WIDTH_AND_HEIGHT;
            self.frame = frame;
        }];
    }else{
        self.toggle = YES;
        _floorButton.alpha = 0;
        _floorView.alpha = 1;
        [UIView animateWithDuration:.2 animations:^{
            NSArray *floorItem = [[[_majorArea floor] block]floors];
            CGRect frame = self.frame;
            if (floorItem.count < 3) {
                frame.size.height = floorItem.count * WIDTH_AND_HEIGHT;
            }else{
                frame.size.height = 3.3 * WIDTH_AND_HEIGHT;
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
