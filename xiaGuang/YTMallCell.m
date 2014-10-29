//
//  YTMallCell.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-11.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTMallCell.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#define MALL_LOGO 20
#define MERCHANTSCROLL 53
@interface YTMallCell(){
    UIImageView *_mallLogo;
    UIImageView *_mallBackground;
    UIView *_shadowView;
    UIScrollView *_merchantScroll;
    NSMutableArray *_merchantsButton;
    NSArray *_merchants;
}
@end

@implementation YTMallCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _mallLogo = [[UIImageView alloc]init];
        
       // _merchantScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 170 - MERCHANTSCROLL - 10, CGRectGetWidth(self.frame), MERCHANTSCROLL)];
        _merchantScroll.delegate = self;
        
        _merchantsButton = [NSMutableArray array];
        
        
//        for (int i = 0; i < 20; i++) {
//            UIButton *merchantButton = [[UIButton alloc]initWithFrame:CGRectMake(10 + i * 60, 0, MERCHANTSCROLL, MERCHANTSCROLL)];
//            [_merchantsButton addObject:merchantButton];
//            [_merchantScroll addSubview:merchantButton];
//            merchantButton.tag = i;
//            merchantButton.layer.cornerRadius = CGRectGetWidth(merchantButton.frame) / 2;
//            merchantButton.backgroundColor = [UIColor whiteColor];
//            merchantButton.layer.masksToBounds = YES;
//            merchantButton.layer.borderWidth = 0.5;
//            merchantButton.layer.borderColor = [UIColor colorWithString:@"c8c8c8"].CGColor;
//        }
        
        _mallBackground = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 300, 90)];
        
        [self addSubview:_mallBackground];
        [_mallBackground addSubview:_mallLogo];
       // [self addSubview:_merchantScroll];
        
        _shadowView = [[UIView alloc]init];
        [self addSubview:_shadowView];
    }
    
    return self;
}

-(void)layoutSubviews{
    
    //mallInfoImage;
    if(self.mallMerchantBundle.mallInfoImageReady){
        _mallLogo.image = self.mallMerchantBundle.mallInfoImage;
        _mallLogo.frame = CGRectMake(15, 20, _mallLogo.image.size.width / 2, _mallLogo.image.size.height / 2);
    }
    else{
        [self.mallMerchantBundle mallInfoTitleWithCallBack:^(UIImage *result, NSError *error) {
            if(error != nil){
                NSLog(@"error getting mall pic");
                return;
            }
            _mallLogo.image = result;
            _mallLogo.frame = CGRectMake(15, 20, _mallLogo.image.size.width / 2, _mallLogo.image.size.height / 2);
        }];
    }
    
    //scroll;
//    _merchantScroll.contentSize = CGSizeMake(10 + _merchantsButton.count * 60, CGRectGetHeight(_merchantScroll.frame));
//    _merchantScroll.showsVerticalScrollIndicator = NO;
    
    
    //mallbackground image;
    if(self.mallMerchantBundle.mallBackgroundImageReady){
        _mallBackground.image = self.mallMerchantBundle.mallBackgroundImage;
        _mallBackground.layer.cornerRadius = 10;
        _mallBackground.layer.masksToBounds = YES;
    }
    else{
        [self.mallMerchantBundle mallBackgroundWithCallBack:^(UIImage *result, NSError *error) {
            if(error != nil){
                NSLog(@"error getting mall pic");
                return;
            }
            _mallBackground.image = result;
            _mallBackground.layer.cornerRadius = 10;
            _mallBackground.layer.masksToBounds = YES;
        }];
    }
    
    
//    if(self.mallMerchantBundle.merchantsIconReady){
//        
//        _merchants = self.mallMerchantBundle.merchants;
//        
//        for (int i = 0 ; i < _merchantsButton.count; i++) {
//            UIButton *merchantButton = _merchantsButton[i];
//            [merchantButton addTarget:self action:@selector(clickToMerchantButton:) forControlEvents:UIControlEventTouchUpInside];
//            [merchantButton setImage:self.mallMerchantBundle.icons[i] forState:UIControlStateNormal];
//        }
//    }
//    
//    else{
//        
//        [self.mallMerchantBundle getIconsWithCallBack:^(NSArray *result, NSError *error) {
//        
//            
//            if(error){
//                NSLog(@"error in fetching icons");
//            }
//            _merchants = self.mallMerchantBundle.merchants;
//        
//            for (int i = 0 ; i < _merchantsButton.count; i++) {
//                UIButton *merchantButton = _merchantsButton[i];
//                [merchantButton addTarget:self action:@selector(clickToMerchantButton:) forControlEvents:UIControlEventTouchUpInside];
//                [merchantButton setImage:result[i] forState:UIControlStateNormal];
//            }
//
//        }];
//    
//    }

    
    _shadowView.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), 3);
    _shadowView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home1_img_shadow"]];
}

-(void)clickToMerchantButton:(UIButton *)sender{
    id<YTMerchant> merchant = _merchants[sender.tag];
    [self.delegate selectMerchant:merchant];
}



@end
