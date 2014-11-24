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
    NSMutableArray *_merchantsButton;
    NSArray *_merchants;
}
@end

@implementation YTMallCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _mallLogo = [[UIImageView alloc]init];
        
        _merchantsButton = [NSMutableArray array];
        
        _mallBackground = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 300, 85)];
        
        [self addSubview:_mallBackground];
        [_mallBackground addSubview:_mallLogo];
        
        _shadowView = [[UIView alloc]init];
        [self addSubview:_shadowView];
    }
    
    return self;
}

-(void)layoutSubviews{
    _mallLogo.image = nil;
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

    _mallBackground.layer.cornerRadius = 10;
    _mallBackground.layer.masksToBounds = YES;
    _mallBackground.image = nil;
    
    //mallbackground image;
    if(self.mallMerchantBundle.mallBackgroundImageReady){
        _mallBackground.image = self.mallMerchantBundle.mallBackgroundImage;
    }
    else{
        [self.mallMerchantBundle mallBackgroundWithCallBack:^(UIImage *result, NSError *error) {
            if(error != nil){
                NSLog(@"error getting mall pic");
                return;
            }
            _mallBackground.image = result;
            CGRect frame = _mallBackground.frame;
            frame.size.height = result.size.height / 2;
            _mallBackground.frame = frame;
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

    
    //_shadowView.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), 3);
    //_shadowView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home1_img_shadow"]];
    self.backgroundColor = [UIColor clearColor];
}




@end
