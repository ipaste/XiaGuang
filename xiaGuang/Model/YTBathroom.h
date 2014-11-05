//
//  YTBathroom.h
//  HighGuang
//
//  Created by Yuan Tao on 10/22/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTMajorArea.h"
#import "YTMinorArea.h"
#import "YTPoiSource.h"

@protocol YTBathroom <NSObject,YTPoiSource>

@property (nonatomic,weak) NSString *identifier;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,weak) id<YTMajorArea> majorArea;
@property (nonatomic,weak) id<YTMinorArea> inMinorArea;
@property (nonatomic,weak) NSNumber *displayLevel;

@end
