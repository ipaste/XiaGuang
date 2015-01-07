//
//  YTNavigationBar.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-16.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTNavigationBar.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#define TopHeight 20
@interface YTNavigationBar(){
    UIButton *_backButton;
    UIButton *_searchButton;
    UIImageView *_backImageView;
    UILabel *_titleLabel;
    UIImage *_defaultBackImage;
    UIImage *_defaultSearchImage;
    UIImageView *_searchImageView;
}
@end
@implementation YTNavigationBar
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat height = CGRectGetHeight(self.frame) - TopHeight;
        
        _backButton = [[UIButton alloc]initWithFrame:CGRectMake(15, TopHeight, 100,  height)];
        [_backButton addTarget:self action:@selector(clickToBackButtonWithDown) forControlEvents:UIControlEventTouchDown];
        [_backButton addTarget:self action:@selector(clickToBackButtonWithUpInside) forControlEvents:UIControlEventTouchUpInside];
        
        _searchButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - height - 15, TopHeight, height, height)];
        [_searchButton addTarget:self action:@selector(clickToSearchButtonWithDown) forControlEvents:UIControlEventTouchDown];
        [_searchButton addTarget:self action:@selector(clickToSearchButtonWithUpInside) forControlEvents:UIControlEventTouchUpInside];
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, TopHeight,CGRectGetWidth(self.frame), height)];
        _titleLabel.text = @"地图导航"; 
        [self addSubview:_backButton];
        [self addSubview:_searchButton];
        [self addSubview:_titleLabel];
        
        _defaultBackImage = [UIImage imageWithImageName:@"nav_ico_back_un" andTintColor:[UIColor colorWithString:@"e65e37"]];
        
        
        _backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 0, _defaultBackImage.size.width, _defaultBackImage.size.height)];
        _backImageView.image = _defaultBackImage;
        [self addSubview:_backImageView];
        
        _defaultSearchImage = [UIImage imageNamed:@"icon_search"];
        _searchImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _defaultSearchImage.size.width, _defaultSearchImage.size.height)];
        _searchImageView.image = _defaultSearchImage;
        [_searchButton addSubview:_searchImageView];
        
    }
    return self;
}

-(void)layoutSubviews{
    self.backgroundColor = [UIColor clearColor];
    
    //[_backButton setTitle:self.backTitle forState:UIControlStateNormal];
    [_backButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [_backButton setTitleColor:[UIColor colorWithString:@"e65e37"] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor colorWithString:@"808080"] forState:UIControlStateHighlighted];
    [_backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, CGRectGetWidth(_backImageView.frame) + 5, 0, 0)];
    [_backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    _backImageView.center = CGPointMake(_backImageView.center.x, _searchButton.center.y);
    
    _titleLabel.backgroundColor = [UIColor clearColor];
    
    _titleLabel.textColor = [UIColor colorWithString:@"e65e37"];
    _titleLabel.textAlignment = 1;
    _titleLabel.font = [UIFont systemFontOfSize:17];
    
    _searchImageView.center = CGPointMake(CGRectGetWidth(_searchButton.frame) / 2 + CGRectGetWidth(_searchImageView.frame) / 2, CGRectGetHeight(_searchButton.frame) / 2 );
    
}
-(void)setTitleName:(NSString *)titleName{
    _titleLabel.text = titleName;
    _titleName = titleName;
}
-(void)changeSearchButton{
    _searchButton.hidden = !_searchButton.hidden;
}

-(void)changeSearchButtonWithHide:(BOOL)hide{
    _searchButton.hidden = hide;
}

-(void)changeBackButton{
    _backButton.hidden = !_backButton.hidden;
    _backImageView.hidden =_backButton.hidden;
}
-(void)changeBackButtonWithHide:(BOOL)hide{
    _backButton.hidden = hide;
    _backImageView.hidden = hide;
}

-(void)clickToBackButtonWithDown{
    _backImageView.image = [UIImage imageNamed:@"nav_ico_back_pr"];
}

-(void)clickToBackButtonWithUpInside{
    _backImageView.image = _defaultBackImage;
    if ([self.delegate respondsToSelector:@selector(backButtonClicked)]) {
        [self.delegate backButtonClicked];
    }
}
-(void)clickToSearchButtonWithDown{
    _searchImageView.image = [UIImage imageNamed:@"icon_searchOn"];
}

-(void)clickToSearchButtonWithUpInside{
    _searchImageView.image = _defaultSearchImage;
    if ([self.delegate respondsToSelector:@selector(searchButtonClicked)]) {
        [self.delegate searchButtonClicked];
    }
}

@end
