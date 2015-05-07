//
//  YTMall.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-8-5.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "YTCityAndRegion.h"

#define MERCHANTLOCATION_CLASS_NAME @"MerchantLocation"
#define MERCHANTLOCATION_CLASS_MALL_KEY @"Mall"
@protocol YTMall <NSObject>

@property(weak,nonatomic)NSString *identifier;
@property(weak,nonatomic)NSString *localDB;
@property(weak,nonatomic)NSString *mallName;
@property(weak,nonatomic)NSArray *blocks;
@property(weak,nonatomic)NSArray *merchantLocations;
@property(weak,nonatomic)NSArray *merchants;
@property(weak,nonatomic)NSString *uniId;
@property(nonatomic)CGFloat offset;
@property(nonatomic)CLLocationCoordinate2D coord;
@property(nonatomic)BOOL isShowPath;
@property(readonly ,nonatomic)YTRegion *region;
@property (strong ,nonatomic) NSString *version;


-(void)getPosterTitleImageAndBackground:(void(^)(UIImage *titleImage,UIImage *background,NSError *error))callback;

-(void)getMallBasicMallInfoWithCallBack:(void(^)(NSString *mallName,NSString *address,CLLocationCoordinate2D coord,NSError *error))callback;

-(void)iconsFromStartIndex:(int)start
                fetchCount:(int)numberOfIcons
                  callBack:(void (^)(NSArray *result,NSArray *merchants,NSError *error))callback;

-(void)existenceOfPreferentialInformationQueryMall:(void (^)(BOOL isExistence))callBack;

@end
