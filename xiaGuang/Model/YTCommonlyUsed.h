//
//  YTCommonlyUsed.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-21.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface YTCommonlyUsed : NSObject
@property (weak, nonatomic) NSString *name;
@property (weak, nonatomic) UIImage *icon;
+(NSArray *)commonlyUsed;
@end