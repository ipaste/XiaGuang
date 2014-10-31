//
//  YTBeconManager.h
//  Demo
//
//  Created by Yuan Tao on 7/31/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ESTBeaconManager.h>
#import <ESTBeacon.h>
#import "ESTBeaconRegion.h"
#import "YTMall.h"
#import "ESTBeacon+YTExtension.h"
#import "YTDBManager.h"

@class YTBeaconManager;

@protocol YTBeaconManagerDelegate <NSObject>
@required
-(void)primaryBeaconShiftedTo:(ESTBeacon *)beacon;

-(void)noBeaconsFound;

@end




@interface YTBeaconManager : NSObject<ESTBeaconManagerDelegate>

@property (nonatomic, weak) id<YTBeaconManagerDelegate> delegate;

-(void)startRangingBeacons;

-(void)stopRanging;

+(id)sharedBeaconManager;

-(NSNumber *) computedDistanceForBeacon:(ESTBeacon *)beacon;

//-(NSArray *)activeBeacons;
-(ESTBeacon *)currentClosest;


-(BOOL) isBeaconInRange:(ESTBeacon *)beacon;

@end
