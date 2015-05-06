//
//  YTElevator.h
//  HighGuang
//
//  Created by Yuan Tao on 8/26/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "YTMajorArea.h"
#import "YTMinorArea.h"
#import "YTPoiSource.h"
#import "YTTransport.h"

@protocol YTElevator <NSObject,YTPoiSource,YTTransport>


@property (nonatomic,weak) NSString *identifier;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,weak) id<YTMajorArea> majorArea;
@property (nonatomic,weak) id<YTMinorArea> inMinorArea;

@end
