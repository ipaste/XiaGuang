//
//  YTSwitchMallView.m
//  虾逛
//
//  Created by YunTop on 14/11/14.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTSwitchMallView.h"
#define DEFAULT_HEIGHT 120
@implementation YTSwitchMallView{
    CGRect _screenFrame;
    
    UIView *_backgroundView;
    
    UIButton *_downPullButton;
    
    UILabel *_promptLabel;
    
    
    NSMutableArray *_malls;
    
}
-(instancetype)init{
    self = [super init];
    if (self) {
        _screenFrame =  [UIScreen mainScreen].bounds;
        
        _malls = [NSMutableArray array];
        
        FMDatabase *dbBase = [YTDBManager sharedManager].db;
        FMResultSet *result = [dbBase executeQuery:@"select * from Mall"];
        
        while ([result next]) {
            YTLocalMall *tmpMall = [[YTLocalMall alloc]initWithDBResultSet:result];
            [_malls addObject:tmpMall];
        }
        
        self.frame = CGRectMake(50, 0, CGRectGetWidth(_screenFrame) - 100, DEFAULT_HEIGHT);
        
        _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        [self addSubview:_backgroundView];
        
        _downPullButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, CGRectGetWidth(self.frame) - 20, 50)];
        [_downPullButton addTarget:self action:@selector(downpullButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_downPullButton];
        
    }
    return self;
}


-(void)layoutSubviews{
    _backgroundView.layer.cornerRadius = 10;
    _backgroundView.backgroundColor = [UIColor colorWithString:@"000000" alpha:0.7];
    
    _downPullButton.backgroundColor = [UIColor colorWithString:@"505050"];
    _downPullButton.layer.cornerRadius = 5;
    [_downPullButton setTitleColor:[UIColor colorWithString:@"ffffff"] forState:UIControlStateNormal];
    _downPullButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_downPullButton setImage:[UIImage originImage:[UIImage imageNamed:@"type_img_arrow1"] scaleToSize:CGSizeMake(14, 8)] forState:UIControlStateNormal];
    [_downPullButton setImage:[UIImage originImage:[UIImage imageWithImageName:@"type_img_arrow1" rotate:M_PI] scaleToSize:CGSizeMake(14, 8)] forState:UIControlStateSelected];
    [_downPullButton setImageEdgeInsets:UIEdgeInsetsMake(0, CGRectGetWidth(_downPullButton.frame) - 24, 0, 0)];
    self.center = CGPointMake(CGRectGetWidth(_screenFrame) / 2, CGRectGetHeight(_screenFrame) / 2 - 25);
}

-(void)downpullButtonClicked{
    _downPullButton.selected = !_downPullButton.selected;
}

-(void)setMall:(id<YTMall>)mall{
    [_downPullButton setTitle:[mall mallName] forState:UIControlStateNormal];
    _mall = mall;
}
@end
