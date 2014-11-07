//
//  Header.h
//  xiaGuang
//
//  Created by Yuan Tao on 11/7/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "YTMajorArea.h"
#import "YTMinorArea.h"
#import "YTPoiSource.h"

@protocol YTEscalator <NSObject,YTPoiSource>


@property (nonatomic,weak) NSString *identifier;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,weak) id<YTMajorArea> majorArea;
@property (nonatomic,weak) id<YTMinorArea> inMinorArea;

@end