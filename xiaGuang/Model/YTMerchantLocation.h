//
//  YTMerchantLocation.h
//  HighGuang
//
//  Created by Yuan Tao on 8/14/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTFloor.h"
#import "YTMajorArea.h"
#import "YTMall.h"
#import "YTMinorArea.h"
#import <CoreLocation/CoreLocation.h>
#import "YTPoiSource.h"
@protocol YTMerchantLocation <YTPoiSource>

@property (weak,nonatomic) NSString *identifier;
@property (weak,nonatomic) NSString *merchantLocationName;
@property (weak,nonatomic) NSString *address;
@property (weak,nonatomic) id<YTFloor> floor;
@property (weak,nonatomic) id<YTMajorArea> majorArea;
@property (weak,nonatomic) id<YTMall> mall;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (weak,nonatomic) NSNumber *displayLevel;
@property (weak,nonatomic) id<YTMinorArea> inMinorArea;
@property (weak,nonatomic) NSString  *uniId;

@property (nonatomic) float lableWidth;
@property (nonatomic) float lableHeight;

-(void)getCloudThumbNailWithCallBack:(void (^)(UIImage *result,NSError *error))callback;

-(void)getCloudMerchantTypeWithCallBack:(void (^)(NSArray *result,NSError *error))callback;
@end
