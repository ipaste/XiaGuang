//
//  YTClassification.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-12.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface YTCategory : NSObject
@property(strong,nonatomic)UIImage *image;
@property(strong,nonatomic)UIImage *smallImage;
@property(strong,nonatomic)NSString *text;
@property(strong,nonatomic)NSArray *subText;
@property(strong,nonatomic)UIColor *tintColor;
@property(strong,nonatomic)UIColor *titleColor;
+(NSArray *)commonlyCategorysWithAddMore:(BOOL)isMore;
+(NSArray *)allCategorys;
+(YTCategory *)moreCategory;
+(CGFloat)calculateHeightForCategory:(YTCategory *)category;
@end
