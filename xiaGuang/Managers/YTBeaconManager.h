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

@protocol YTBeaconManagerUpdateListener <NSObject>

-(void)YTBeaconManager:(YTBeaconManager *)manager
         rangedBeacons:(NSArray *)beacons;

@end


@interface YTBeaconManager : NSObject<ESTBeaconManagerDelegate>

@property (nonatomic, weak) id<YTBeaconManagerDelegate> delegate;
@property (nonatomic,readonly,weak) NSArray *readbeacons;

-(void)startRangingBeacons;

-(void)stopRanging;

+(id)sharedBeaconManager;

-(NSNumber *) computedDistanceForBeacon:(ESTBeacon *)beacon;

//-(NSArray *)activeBeacons;
-(ESTBeacon *)currentClosest;


-(BOOL) isBeaconInRange:(ESTBeacon *)beacon;

#pragma mark -
#pragma mark Listener

- (void)addListener:(id<YTBeaconManagerUpdateListener>)listener;
- (void)removeListener:(id<YTBeaconManagerUpdateListener>)listener;

@end
