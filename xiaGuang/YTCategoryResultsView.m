//
//  YTCategoryResultsView.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-22.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTCategoryResultsView.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "YTMerchant.h"
#import "YTCategory.h"
#import "YTCategoryResultsTableView.h"
@interface YTCategoryResultsView()<YTCategoryDelegate>{
    id<YTMall> _mall;
    NSMutableArray *_categoryCount;
    UIButton *_curSelectButton;
    UIButton *_mallButton;
    YTCategoryResultsTableView *_categoryResltsTableView;
    NSString *_buttonName;
}
@end

@implementation YTCategoryResultsView
-(id)initWithFrame:(CGRect)frame andmall:(id<YTMall>)mall categoryKey:(NSString *)key subCategory:(NSString *)subKey{
    self = [super initWithFrame:frame];
    if (self) {
        _mall = mall;
    
        _categoryCount = [NSMutableArray array];
       
        [self setKey:key subKey:subKey];
        
        NSArray *buttonNames = nil;
        if (!_mall) {
            buttonNames = @[_buttonName,@"全部商圈"];
        }else{
            buttonNames = @[_buttonName,@"全部楼层" ];
        }
        
        for (int i = 0 ; i < buttonNames.count; i++) {
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / buttonNames.count * i, 0, CGRectGetWidth(self.frame) / buttonNames.count, CGRectGetHeight(self.frame))];
            button.tag = i;
            [button setTitle:buttonNames[i] forState:UIControlStateNormal];
            [self addSubview:button];
            [_categoryCount addObject:button];
            if ([buttonNames[i] isEqualToString:@"全部商圈"]) {
                _mallButton = _categoryCount[i];
            }
        }
        
        
        _categoryResltsTableView = [[YTCategoryResultsTableView alloc]initWithFrame:CGRectMake(0, 40, CGRectGetWidth(frame), 0)];
        _categoryResltsTableView.delegate = self;
        [self addSubview:_categoryResltsTableView];
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
    }
    return self;
}

-(void)setKey:(NSString *)key subKey:(NSString *)subKey{
    if (subKey == nil && key == nil) {
        _buttonName = @"全部分类";
    }else{
        if (subKey == nil) {
            subKey = @"全部";
        }
        _buttonName = [NSString stringWithFormat:@"%@-%@",subKey,key];
    }
    
    
    NSArray *buttonNames = nil;
    if (!_mall) {
        buttonNames = @[_buttonName,@"全部商圈"];
    }else{
        buttonNames = @[_buttonName,@"全部楼层" ];
    }
    
    if (_categoryCount.count > 0) {
        for (int i = 0 ; i < buttonNames.count; i++) {
            UIButton *button = _categoryCount[i];
            [button setTitle:buttonNames[i] forState:UIControlStateNormal];
        }
    }
}


-(void)layoutSubviews{
    for (int i = 0 ; i < _categoryCount.count; i++) {
        UIButton *button = _categoryCount[i];
        [button setBackgroundImage:[UIImage imageNamed:@"type_img_tab_un"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"type_img_tab_pr"] forState:UIControlStateDisabled];
        [button setBackgroundImage:[UIImage imageNamed:@"type_img_tab_pr"] forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:@"type_img_arrow1"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageRotateOneHundredAndEightyDegreesWithImageName:@"type_img_arrow1"] forState:UIControlStateDisabled];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0,CGRectGetWidth(button.frame) - 17 , 0, 0)];
        [button setTitleColor:[UIColor colorWithString:@"606060"] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button addTarget:self action:@selector(clickToCategory:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

-(void)clickToCategory:(UIButton *)sender{
    _curSelectButton.enabled = YES;
    sender.enabled = NO;
    _curSelectButton = sender;
    
    CGRect frame = self.frame;
    frame.size.height = CGRectGetHeight([UIScreen mainScreen].bounds);
    self.frame = frame;
    
    switch (sender.tag) {
        case 0://所有分类
            [_categoryResltsTableView setShowStyle:YTCategoryResultsStyleAllCategory mallName:nil key:sender.titleLabel.text];
            break;
        case 1:
            if (!_mall) {
                [_categoryResltsTableView setShowStyle:YTCategoryResultsStyleAllMall mallName:nil key:sender.titleLabel.text];
            }else{
                [self allFloor];
            }
            break;
    }
}

-(void)allFloor{
    NSString *mallName = [_mall mallName];
    if (mallName == nil) {
        mallName = _mallButton.titleLabel.text;
    }
    [_categoryResltsTableView setShowStyle:YTCategoryResultsStyleAllFloor mallName:mallName  key:_curSelectButton.titleLabel.text];
    
}

-(void)selectKey:(NSString *)key{
    [self hideCategoryReslts];
    [_curSelectButton setTitle:key forState:UIControlStateDisabled];
    [_curSelectButton setTitle:key forState:UIControlStateNormal];
    NSString *category = nil;
    NSString *subCategory = nil;
    NSString *mallName = nil;
    NSString *floorName = nil;
    for (UIButton *tempButton in _categoryCount) {
        switch (tempButton.tag) {
            case 0:
                category = [[tempButton.titleLabel.text componentsSeparatedByString:@"-"] lastObject];
                subCategory = [[tempButton.titleLabel.text componentsSeparatedByString:@"-"] firstObject];
                break;
            case 1:
                if (_mallButton != nil) {
                    mallName = _mallButton.titleLabel.text;
                }else{
                    floorName = tempButton.titleLabel.text;
                }
                break;
        }
    }
    if ([category isEqualToString:@"全部分类"]) {
        category = @"全部";
        subCategory = @"全部";
    }
    if ([subCategory isEqualToString:@"全部"]) {
        subCategory = @"全部";
    }
    if ([mallName isEqualToString:@"全部商圈"]) {
        mallName = @"全部";
    }
    
    if ([floorName isEqualToString:@"全部楼层"]) {
        floorName = @"全部";
    }
    if (mallName == nil) {
        mallName = [_mall mallName];
    }
    [self.delegate searchKeyForCategoryTitle:category subCategoryTitle:subCategory mallName:mallName floor:floorName];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self hideCategoryReslts];
}

-(void)hideCategoryReslts{
    CGRect frame = self.frame;
    frame.size.height = 40;
    self.frame = frame;
    _curSelectButton.enabled = YES;
    _categoryResltsTableView.hidden = YES;
}
@end
