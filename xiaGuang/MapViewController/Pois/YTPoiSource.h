//
//  YTPoiSource.h
//  HighGuang
//
//  Created by Yuan Tao on 10/17/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTMinorArea.h"
#import "YTPoi.h"

@protocol YTPoiSource <NSObject>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (weak,nonatomic) NSNumber *displayLevel;
@property (weak,nonatomic) id<YTMinorArea> inMinorArea;
@property (weak,nonatomic) id<YTMajorArea> majorArea;
@property (weak,nonatomic) NSString *name;
@property (weak,readonly,nonatomic) NSString *iconName;

-(YTPoi *)producePoi;

@end
