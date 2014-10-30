//
//  YTPoiView.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-10.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTPoiView.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
@interface YTPoiView(){
    UIWindow *_window;
    JWBlurView *_topView;
    JWBlurView *_bottomView;
    
    NSMutableArray *_categorys;
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
        
        _window = [UIApplication sharedApplication].windows[0];
        
        _topView = [[JWBlurView alloc]initWithFrame:CGRectMake(0, -(CGRectGetHeight(self.frame) / 2), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)/2)];
        
        _bottomView = [[JWBlurView alloc]initWithFrame:CGRectMake(0,CGRectGetHeight(self.frame), CGRectGetWidth(_topView.frame), CGRectGetHeight(_topView.frame))];
        [_bottomView setBlurAlpha:0.01];
        
        [self addSubview:_topView];
        [self addSubview:_bottomView];
        
        _categorys = [NSMutableArray arrayWithArray:[YTCategory commonlyCategorysWithAddMore:NO]];
        _commons = [NSMutableArray arrayWithArray:[YTCommonlyUsed commonlyUsed]];
        
        for (int i = 0; i < 7; i++) {
            YTCategory *category = _categorys[i];
            UIButton *classButton = [[UIButton alloc]initWithFrame:CGRectMake(40 + i % 4 * 64  , 90 + i / 4 * 79 , 44, 44)];
            
            [classButton setImage:category.image forState:UIControlStateNormal];
            
            classButton.tag = i;
            [classButton addTarget:self action:@selector(clickedOnCategoryButton:) forControlEvents:UIControlEventTouchDown];
            
            [_topView addSubview:classButton];
            
            UILabel *classLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 135 + i / 4 * 79, 44, 20)];
            classLabel.text = category.text;
            classLabel.textAlignment = 1;
            classLabel.textColor = [UIColor colorWithString:@"404040"];
            classLabel.tag = i;
            classLabel.font = [UIFont systemFontOfSize:11];
            classLabel.center = CGPointMake(classButton.center.x, classLabel.center.y);
            [_topView addSubview:classLabel];
        }
        
        for (int i = 0; i < 6; i++) {
            YTCommonlyUsed *commonly = _commons[i];
            UIButton *usedButton = [[UIButton alloc]initWithFrame:CGRectMake(40 + i % 4 * 64, 20 + i / 4 * 79 , 44, 44)];
            [usedButton setImage:commonly.icon forState:UIControlStateNormal];
            
            usedButton.tag = i;
            [usedButton addTarget:self action:@selector(clickedOnCommonButton:) forControlEvents:UIControlEventTouchDown];
        
            
            [_bottomView addSubview:usedButton];
            
            UILabel *usedLabel = [[UILabel alloc]initWithFrame:CGRectMake(40 + i % 4 * 64, 70 + i / 4 * 79 , 44, 20)];
            usedLabel.text = commonly.name;
            usedLabel.textAlignment = 1;
            usedLabel.textColor = [UIColor colorWithString:@"404040"];
            usedLabel.tag = i;
            usedLabel.font = [UIFont systemFontOfSize:11];
            usedLabel.center = CGPointMake(usedButton.center.x, usedLabel.center.y);
            
            [_bottomView addSubview:usedLabel];
        }
        
        UIButton *cancel = [[UIButton alloc]initWithFrame:CGRectMake(70, CGRectGetHeight(_bottomView.frame) - 65,44, 44)];
        [cancel setImage:[UIImage imageNamed:@"nav_ico_more_pr"] forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:cancel];
        
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
        CGRect frame = _topView.frame;
        frame.origin.y = 0;
        _topView.frame = frame;
        
        frame = _bottomView.frame;
        frame.origin.y = CGRectGetHeight(self.frame) / 2;
        _bottomView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
    
}
-(void)hide{
    [UIView animateWithDuration:.3 animations:^{
        CGRect frame = _topView.frame;
        frame.origin.y =  -CGRectGetHeight(self.frame);
        _topView.frame = frame;
        
        frame = _bottomView.frame;
        frame.origin.y = CGRectGetHeight(self.frame);
        _bottomView.frame = frame;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

-(void)cancel:(UIButton *)sender{
    [self hide];
}

-(void)clickedOnCategoryButton:(UIButton *)sender{
    [sender addSubview:_chooseImageView];
    [self.delegate highlightTargetGroupOfPoi:_categorys[sender.tag]];
    [self hide];
}

-(void)clickedOnCommonButton:(UIButton *)sender{
    [sender addSubview:_chooseImageView];
    [self.delegate highlightTargetGroupOfPoi:_commons[sender.tag]];
    [self hide];
    
}




@end
