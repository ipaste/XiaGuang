//
//  YTMinorArea.h
//  HighGuang
//
//  Created by Yuan Tao on 8/5/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "YTMajorArea.h"
@protocol YTMinorArea <NSObject>

@property (nonatomic,weak) NSString *identifier;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,weak) NSArray * beacons;
@property (nonatomic,weak) id<YTMajorArea> majorArea;
@property (nonatomic,weak) NSString *minorAreaName;

@end

