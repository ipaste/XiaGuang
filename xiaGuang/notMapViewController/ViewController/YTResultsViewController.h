//
//  YTResultsViewController.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-12.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMall.h"

@interface YTResultsViewController : UIViewController
@property (nonatomic) BOOL isSearch;
-(instancetype)initWithPreferntialInMall:(id <YTMall>)mall;
-(id)initWithSearchInMall:(id<YTMall>)mall andResutsKey:(NSString *)key;
-(id)initWithSearchInMall:(id<YTMall>)mall andResutsKey:(NSString *)key andSubKey:(NSString *)subKey;
-(instancetype)initWithSearchInMall:(id<YTMall>)mall andResultsLocalDBIds:(NSArray *)ids;
@end
