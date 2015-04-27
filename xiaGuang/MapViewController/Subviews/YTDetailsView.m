//
//  YTDetailsView.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-8-15.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTDetailsView.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#define TEXTCOLOR_AND_ARROWCOLOR [UIColor colorWithRed:139/255.0f green:139/255.0f blue:139/255.0f alpha:1.0]
@implementation YTDetailsView{
    UILabel *_label;
    UIButton *_startNavigationButton;
    UIImageView *_merchantLogo;
    id<YTPoiSource> _poiSource;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _merchantLogo = [[UIImageView alloc]initWithFrame:CGRectMake(15, 17.5, frame.size.height- 35, frame.size.height- 35)];
        _merchantLogo.image = [UIImage imageNamed:@"imgshop_default"];
        _merchantLogo.backgroundColor = [UIColor whiteColor];
        
         _label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_merchantLogo.frame) + 10, 21, 160, 25)];
        _startNavigationButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(frame) - (CGRectGetHeight(frame) - 29) - 18, 14.5, 51, 51)];
        
        [self addSubview:_merchantLogo];
        [self addSubview:_startNavigationButton];
        [self addSubview:_label];
    }
    return self;
}

-(void)layoutSubviews{

    _label.font = [UIFont systemFontOfSize:16];
    _label.textColor = [UIColor whiteColor];
    
    
    _merchantLogo.layer.cornerRadius = CGRectGetWidth(_merchantLogo.frame) / 2;
    _merchantLogo.layer.masksToBounds = YES;
    
    [_startNavigationButton setTitle:@"导航" forState:UIControlStateNormal];
//    [_startNavigationButton setBackgroundColor:[UIColor colorWithString:@"0084ff"]];
//    _startNavigationButton.layer.cornerRadius = (CGRectGetHeight(self.frame) - 8) / 2;
    [_startNavigationButton setBackgroundImage:[UIImage imageNamed:@"btn_orange"] forState:UIControlStateNormal];
    [_startNavigationButton addTarget:self action:@selector(clickStartNavigationButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setClipsToBounds:YES];
    self.backgroundColor = [UIColor colorWithString:@"000000" alpha:0.6];
//    self.layer.cornerRadius = CGRectGetHeight(self.frame) / 2;
//    self.layer.masksToBounds = YES;
}

-(void)setMerchantInfo:(id<YTMerchantLocation>)merchantLocation{
    _merchantLogo.image = [UIImage imageNamed:@"imgshop_default"];
    _merchantLogo.backgroundColor = [UIColor clearColor];
    _label.text = [merchantLocation merchantLocationName];
   
    [merchantLocation getCloudMerchantTypeWithCallBack:^(NSArray *result, NSError *error) {
        [self setType:result];
    }];
    
    [merchantLocation getCloudThumbNailWithCallBack:^(UIImage *result, NSError *error) {
        if (error) {
            _merchantLogo.image = [UIImage imageNamed:@"imgshop_default"];
        }else{
            if (result != nil){
                _merchantLogo.image = result;
            }
        }
    }];
    _poiSource = merchantLocation;
}


-(void)setCommonPoi:(id<YTPoiSource>)poi{
    if([poi isMemberOfClass:[YTLocalMerchantInstance class]]){
        [self setMerchantInfo:(id<YTMerchantLocation>)poi];
        return;
    }
    _label.text = poi.name;
    _merchantLogo.image = [UIImage imageNamed:poi.iconName];
    _merchantLogo.backgroundColor = [UIColor whiteColor];
    _poiSource = poi;
    [self setType:@[@"公共设施"]];
}

-(void)setPoiSource:(id<YTPoiSource>)source{
    
}

-(void)clickStartNavigationButton:(UIButton *)sender{
    [self.delegate navigatingToPoiSourceClicked:_poiSource];
}


-(void)setType:(NSArray *)types{
    for (UIView *view in self.subviews) {
        if (view.tag == 1) {
            [view removeFromSuperview];
        }
    }

    UIImageView *beforeImageView = nil;
    for (int i = 0 ; i < types.count; i++) {
        NSString *type = types[i];
        CGFloat x = 0;
        CGFloat height = 42;
        UIImage *image = [UIImage imageNamed:@"nav_img_label_2"];
        if (type.length > 2) {
            height = 60;
            image = [UIImage imageNamed:@"nav_img_label_4"];
        }
        
        if (beforeImageView == nil) {
            x = CGRectGetMinX(_label.frame) + i * height;
        }else{
            x = CGRectGetMaxX(beforeImageView.frame) + 5;
        }
        
        UIImageView *categoryImageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, CGRectGetMaxY(_label.frame), height, 16)];
        categoryImageView.tag = 1;
        categoryImageView.image = image;
        [self addSubview:categoryImageView];

        UILabel *categoryLabel = [[UILabel alloc]initWithFrame:categoryImageView.bounds];
        categoryLabel.text = type;
        categoryLabel.font = [UIFont systemFontOfSize:10];
        categoryLabel.textAlignment = 1;
        categoryLabel.textColor = [UIColor colorWithString:@"fbbb4c"];
        [categoryImageView addSubview:categoryLabel];
        beforeImageView = categoryImageView;
    }
}


@end
