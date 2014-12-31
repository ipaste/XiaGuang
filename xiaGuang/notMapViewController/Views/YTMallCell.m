//
//  YTMallCell.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-11.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTMallCell.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"

@interface YTMallCell(){
    UIImageView *_mallBackgroundView;
    UIImageView *_titleImageView;
    UIImageView *_cellBackground;
    BOOL _isFetch;
}
@end

@implementation YTMallCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        _mallBackgroundView = [[UIImageView alloc]init];
        _mallBackgroundView.frame = CGRectMake(10, 4, 300, 123);
        _titleImageView = [[UIImageView alloc]init];
        _mallBackgroundView.layer.cornerRadius = 10;
        _mallBackgroundView.layer.masksToBounds = true;
        self.backgroundColor = [UIColor clearColor];
        _titleImageView.frame = CGRectMake(20, 90, 150, 30);
        
        _cellBackground = [[UIImageView alloc]init];
        _cellBackground.image = [UIImage imageNamed:@"bg_box"];
        
        _cellBackground.frame = CGRectMake(0, 0, 320, 130);
        [self addSubview:_mallBackgroundView];
        [self addSubview:_titleImageView];
        [self addSubview:_cellBackground];
    }
    
    return self;
}



-(void)layoutSubviews{
    
    [super layoutSubviews];
    _mallBackgroundView.layer.cornerRadius = 8;
    _mallBackgroundView.layer.masksToBounds = true;
    self.backgroundColor = [UIColor clearColor];
    
    
}




-(void)setMall:(id<YTMall>)mall{
    
    _mallBackgroundView.image = nil;
    _titleImageView.image = nil;
    _isFetch = false;
    [mall getPosterTitleImageAndBackground:^(UIImage *titleImage, UIImage *background, NSError *error) {

        if (!error) {
            _titleImageView.image = titleImage;
            
            _mallBackgroundView.image = background;
            
            _isFetch = true;
        }
        
    }];
    _mall = mall;
}
-(BOOL)isFetch{
    return _isFetch;
}

@end
