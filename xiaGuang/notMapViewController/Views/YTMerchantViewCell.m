//
//  YTMerchantViewCell.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-12.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTMerchantViewCell.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#define MERCHANT_ICON_SIZE 60

@interface YTMerchantViewCell(){
    UIImageView *_iconView;
    UIView *_line;
    UILabel *_merchantNameLabel;
    UILabel *_addressLable;
    UIImageView *_preferentialImageView;
    UIImageView *_soleImageView;
    UIImageView *_otherImageView;
    NSMutableArray *_subCategoryImageView;
    NSMutableArray *_subCategoryLabel;
    id<YTMerchant> _oldMerchant;
}
@end
@implementation YTMerchantViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIView *backgroundView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, CGRectGetWidth(self.frame), 90)];
        backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_2_un"]];
        self.backgroundView = backgroundView;
        
        backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_2_pr"]];
        
        self.selectedBackgroundView = backgroundView;
        
        _iconView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, MERCHANT_ICON_SIZE, MERCHANT_ICON_SIZE)];
        _iconView.image = [UIImage imageNamed:@"imgshop_default"];
        
        _merchantNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_iconView.frame) + 15.0f, CGRectGetMinY(_iconView.frame), 150, 17)];
        
        _addressLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_merchantNameLabel.frame), CGRectGetMaxY(_merchantNameLabel.frame) + 5, 150, 14)];
        
        
        _line = [[UIView alloc]init];
        
        _subCategoryImageView = [NSMutableArray array];
        _subCategoryLabel = [NSMutableArray array];
        
        for (int i = 0; i < 3; i++) {
            UIImageView *subCategory = [[UIImageView alloc]init];
            [self addSubview:subCategory];
            [_subCategoryImageView addObject:subCategory];
            
            UILabel *subLabel = [[UILabel alloc]init];
            [subCategory addSubview:subLabel];
            [_subCategoryLabel addObject:subLabel];
        }
        self.titleColor = [UIColor colorWithString:@"e95e37"];
        
        UIImage *preferentialImage = [UIImage imageNamed:@"flag"];
        _preferentialImageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - preferentialImage.size.width, 0, preferentialImage.size.width, preferentialImage.size.height)];
        _preferentialImageView.image = preferentialImage;
        _preferentialImageView.hidden = true;
        
        
        _otherImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ico_tuan"]];
        _otherImageView.hidden = true;
        
        _soleImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ico_du"]];
        _soleImageView.hidden = true;
        
        [self addSubview:_iconView];
        [self addSubview:_merchantNameLabel];
        [self addSubview:_addressLable];
        [self addSubview:_line];
        [self addSubview:_preferentialImageView];
        [self addSubview:_otherImageView];
        [self addSubview:_soleImageView];
        
        
    }
    return self;
}

-(void)layoutSubviews{
    _iconView.layer.cornerRadius = MERCHANT_ICON_SIZE / 2;
    _iconView.layer.masksToBounds = YES;
    _iconView.layer.borderWidth = 0.5;
    _iconView.layer.borderColor = [UIColor colorWithString:@"c8c8c8"].CGColor;
    
    _line.frame = CGRectMake(10, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame) - 20, 0.5);
    _line.backgroundColor = [UIColor colorWithString:@"b2b2b2"];
    
    
    _merchantNameLabel.font = [UIFont systemFontOfSize:16];
    [_merchantNameLabel setTextColor:self.titleColor];
    
    [_addressLable setFont:[UIFont systemFontOfSize:11]];
    [_addressLable setTextColor:[UIColor colorWithString:@"999999"]];
}


-(void)setMerchant:(id<YTMerchant>)merchant{
    _soleImageView.hidden = true;
    _otherImageView.hidden = true;
    _merchantNameLabel.text = [merchant merchantName];
    CGSize size = [[merchant merchantName] boundingRectWithSize:CGSizeMake(MAXFLOAT, CGRectGetHeight(_merchantNameLabel.frame)) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :_merchantNameLabel.font} context:nil].size;
    
    CGRect frame = _merchantNameLabel.frame;
    if (size.width < 150) {
        frame.size.width = size.width;
    }else{
        frame.size.width = 150;
    }
    _merchantNameLabel.frame = frame;
    
    [merchant existenceOfPreferentialInformationQueryMall:^(BOOL isExistence) {
        YTCloudMerchant *cloudMerchant = (YTCloudMerchant *)merchant;
        if (cloudMerchant.isSole) {
            _soleImageView.hidden = false;
            CGRect frame = _soleImageView.frame;
            frame.origin = CGPointMake(CGRectGetMaxX(_merchantNameLabel.frame) + 10, CGRectGetMinY(_merchantNameLabel.frame));
            _soleImageView.frame = frame;
        }else{
            _soleImageView.hidden = true;
        }
        if (cloudMerchant.isOther){
            _otherImageView.hidden = false;
            if (cloudMerchant.isSole){
                CGRect frame = _otherImageView.frame;
                frame.origin = CGPointMake(CGRectGetMaxX(_soleImageView.frame) + 5, CGRectGetMinY(_otherImageView.frame));
                _otherImageView.frame = frame;
            }else{
                CGRect frame = _otherImageView.frame;
                frame.origin = CGPointMake(CGRectGetMaxX(_merchantNameLabel.frame) + 10, CGRectGetMinY(_merchantNameLabel.frame));
                _otherImageView.frame = frame;
            }
        }else{
            _otherImageView.hidden = true;
        }
    }];
    
    _addressLable.text = [merchant address];
    
    _iconView.image = [UIImage imageNamed:@"imgshop_default"];
    [merchant getThumbNailWithCallBack:^(UIImage *result, NSError *error) {
        _iconView.image = result;
    }];
    
    NSArray *subType = [merchant type];
    if (subType.count > 0 && subType != nil){
        UIImageView *beforeImageView = nil;
        for (int i = 0; i < _subCategoryImageView.count; i++) {
            UIImageView *imageView = _subCategoryImageView[i];
            if ( i < subType.count ) {
                imageView.hidden = NO;
                NSString *typeName = subType[i];
                CGRect frame = CGRectMake(0, CGRectGetMaxY(_addressLable.frame) + 8, 0, 16);;
                UIImage *image = nil;
                if (typeName.length > 2) {
                    frame.origin.x = CGRectGetMaxX(beforeImageView.frame) == 0 ? CGRectGetMinX(_addressLable.frame):CGRectGetMaxX(beforeImageView.frame) + 5;
                    frame.size.width = 60;
                    image = [UIImage imageNamed:@"shop_img_label_4"];
                }else{
                    frame.origin.x = CGRectGetMaxX(beforeImageView.frame) == 0 ? CGRectGetMinX(_addressLable.frame):CGRectGetMaxX(beforeImageView.frame) + 5;
                    frame.size.width = 42;
                    image = [UIImage imageNamed:@"shop_img_label_2"];
                }
                
                imageView.image = image;
                imageView.frame = frame;
                beforeImageView = imageView;
                
                UILabel *label = _subCategoryLabel[i];
                label.text = subType[i];
                label.frame = imageView.bounds;
                label.font = [UIFont systemFontOfSize:10];
                label.textAlignment = 1;
                label.textColor = [UIColor colorWithString:@"e95e37"];
            }else{
                imageView.hidden = YES;
            }
        }
    }else{
        for (int i = 0 ; i < _subCategoryImageView.count; i++) {
            UIImageView *imageView = _subCategoryImageView[i];
            UILabel *label = _subCategoryLabel[i];
            imageView.hidden = YES;
            label.hidden = YES;
        }
        
    }
    _merchant = merchant;
}

-(void)setIsShowMark:(BOOL)isShowMark{
   // _preferentialImageView.hidden = !isShowMark;
}


@end
