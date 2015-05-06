//
//  YTPoiView.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-10.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTPoiView.h"
#import "AppDelegate.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
@interface YTPoiView(){
   __weak UIWindow *_window;
    
    JWBlurView *_background;
    
    NSMutableArray *_commons;
    
    NSInteger _selectedButtonIndex;
    
    UIImageView *_chooseImageView;
}
@end
@implementation YTPoiView
-(id)initWithShow:(BOOL)show{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        
        _selectedButtonIndex = -1;
        
        _window = [(AppDelegate *)[UIApplication sharedApplication].delegate window];

        _commons = [NSMutableArray arrayWithArray:[YTCommonlyUsed commonlyUsed]];
        
        _background = [[JWBlurView alloc]initWithFrame:CGRectMake(0, -CGRectGetHeight(self.bounds), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        [_background setBlurAlpha:0.7];
        [_background setAlpha:0.9];
        [_background setBlurColor:[UIColor whiteColor]];
        [self addSubview:_background];
        
        for (int i = 0; i < _commons.count; i++) {
            YTCommonlyUsed *commonly = _commons[i];
            UIButton *usedButton = [[UIButton alloc]initWithFrame:CGRectMake(40 + i % 4 * 64, (CGRectGetHeight(self.frame) / 2) - 80 + i / 4 * 79 , 44, 44)];
            [usedButton setImage:commonly.icon forState:UIControlStateNormal];
            
            usedButton.tag = i;
            [usedButton addTarget:self action:@selector(clickedOnCommonButton:) forControlEvents:UIControlEventTouchDown];
            
            [_background addSubview:usedButton];
            
            UILabel *usedLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(usedButton.frame), CGRectGetMaxY(usedButton.frame) + 5 , 44, 20)];
            usedLabel.text = commonly.name;
            usedLabel.textAlignment = 1;
            usedLabel.textColor = [UIColor colorWithString:@"404040"];
            usedLabel.tag = i;
            usedLabel.font = [UIFont systemFontOfSize:11];
            usedLabel.center = CGPointMake(usedButton.center.x, usedLabel.center.y);
            
            [_background addSubview:usedLabel];
        }
        
        UIButton *cancel = [[UIButton alloc]initWithFrame:CGRectMake(70, CGRectGetHeight(_background.frame) - 65,44, 44)];
        [cancel setImage:[UIImage imageNamed:@"nav_ico_more_pr"] forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [_background addSubview:cancel];
        
        [_window addSubview:self];
        if (show) {
            self.hidden = NO;
        }else{
            self.hidden = YES;
        }
        UIImage *chooseImage = [UIImage imageNamed:@"nav_img_choose"];
        _chooseImageView = [[UIImageView alloc]initWithFrame:CGRectMake(33, 33, chooseImage.size.width, chooseImage.size.height)];
        _chooseImageView.image = chooseImage;

    }
    return self;
}

-(void)deleteSelectedPoi{
    [_chooseImageView removeFromSuperview];
}

-(void)show{
    self.hidden = NO;
    [UIView animateWithDuration:.3 animations:^{
        CGRect frame = _background.frame;
        frame.origin.y = 0;
        _background.frame = frame;
    
    }];
    
}
-(void)hide{
    [UIView animateWithDuration:.3 animations:^{
        CGRect frame = _background.frame;
        frame.origin.y =  -CGRectGetHeight(self.frame);
        _background.frame = frame;

    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

-(void)cancel:(UIButton *)sender{
    [self hide];
}

-(void)clickedOnCommonButton:(UIButton *)sender{
    [sender addSubview:_chooseImageView];
    [self.delegate highlightTargetGroupOfPoi:_commons[sender.tag]];
    [self hide];
    
}




@end
