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
    
        
        [self addSubview:_iconView];
        [self addSubview:_merchantNameLabel];
        [self addSubview:_addressLable];
        [self addSubview:_line];
    
    }
    return self;
}

-(void)layoutSubviews{
    _iconView.layer.cornerRadius = MERCHANT_ICON_SIZE / 2;
    _iconView.layer.masksToBounds = YES;
    _iconView.layer.borderWidth = 0.5;
    _iconView.layer.borderColor = [UIColor colorWithString:@"c8c8c8"].CGColor;
    
    _line.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5);
    _line.backgroundColor = [UIColor colorWithString:@"dcdcdc"];
    
    _merchantNameLabel.text = [self.merchant merchantName];
    [_merchantNameLabel setTextColor:[UIColor colorWithString:@"404040"]];
    
    _addressLable.text = [self.merchant address];
    [_addressLable setFont:[UIFont systemFontOfSize:11]];
    [_addressLable setTextColor:[UIColor colorWithString:@"aaaaaa"]];
    
    NSArray *subType = [self.merchant type];
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
    
    
    
    if (![[_merchant mercantId] isEqualToString:[_oldMerchant mercantId]]) {
        _iconView.hidden = YES;
        [self.merchant getThumbNailWithCallBack:^(UIImage *result, NSError *error) {
            _iconView.hidden = NO;
            _iconView.image = result;
        }];
    }
    _oldMerchant = _merchant;
    
}


@end