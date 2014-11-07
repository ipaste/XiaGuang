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
@property(weak,nonatomic)UIImage *image;
@property(weak,nonatomic)UIImage *smallImage;
@property(weak,nonatomic)NSString *text;
@property(weak,nonatomic)NSArray *subText;
@property(weak,nonatomic)UIColor *tintColor;
@property(weak,nonatomic)UIColor *titleColor;
+(NSArray *)commonlyCategorysWithAddMore:(BOOL)isMore;
+(NSArray *)allCategorys;
+(YTCategory *)moreCategory;
+(CGFloat)calculateHeightForCategory:(YTCategory *)category;
@end
