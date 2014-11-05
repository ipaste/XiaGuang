//
//  YTMajorArea.h
//  HighGuang
//
//  Created by Yuan Tao on 8/5/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTFloor.h"
@protocol YTMajorArea <NSObject>

@property (nonatomic,weak) NSString *identifier;
@property (nonatomic,weak) NSArray *minorAreas;
@property (nonatomic,weak) NSString *mapName;
@property (nonatomic,weak) id<YTFloor> floor;
@property (nonatomic,weak) NSArray *merchantLocations;
@property (nonatomic,weak) NSArray *elevators;
@property (nonatomic,weak) NSArray *bathrooms;
@property (nonatomic,weak) NSArray *exits;
@property (nonatomic) BOOL isParking;
@property (nonatomic) double worldToMapRatio;

@end
