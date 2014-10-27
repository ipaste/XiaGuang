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
@protocol YTMall <NSObject>

@property(weak,nonatomic)NSString *identifier;
@property(weak,nonatomic)UIImage *background;
@property(weak,nonatomic)UIImage *logo;
@property(weak,nonatomic)UIImage *infoBackground;
@property(weak,nonatomic)UIImage *mallInfoTitleImage;
@property(weak,nonatomic)NSString *mallName;
@property(weak,nonatomic)NSArray *blocks;
@property(weak,nonatomic)NSArray *merchantLocations;
@property(weak,nonatomic)NSArray *merchants;
@property(nonatomic)CLLocationCoordinate2D coord;


-(void)getMallInfoTitleWithCallBack:(void (^)(UIImage *result,NSError* error))callback;
-(void)getBackgroundWithCallBack:(void (^)(UIImage *result,NSError* error))callback;
-(void)getInfoBackgroundImageWithCallBack:(void (^)(UIImage *result,NSError* error))callback;
-(void)iconsFromStartIndex:(int)start
                     toEnd:(int)end
                  callBack:(void (^)(NSArray *result,NSError *error))callback;
-(void)iconsFromStartIndex:(int)start
                fetchCount:(int)numberOfIcons
                  callBack:(void (^)(NSArray *result,NSArray *merchants,NSError *error))callback;
@end
