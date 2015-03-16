//
//  YTBeaconBasedLocator.h
//  xiaGuang
//
//  Created by Meng Hu on 11/5/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YTBeaconManager.h"
#import "YTMajorArea.h"

#import <CoreLocation/CoreLocation.h>

#import <RMMapView.h>

@class YTBeaconBasedLocator;

@protocol YTBeaconBasedLocatorDelegate

- (void)YTBeaconBasedLocator:(YTBeaconBasedLocator *)locator
           coordinateUpdated:(CLLocationCoordinate2D)coordinate;

@end

@interface YTBeaconBasedLocator : NSObject <YTBeaconManagerUpdateListener>

@property (nonatomic, weak) id<YTBeaconBasedLocatorDelegate> delegate;

- (id)initWithMapView:(RMMapView *)mapView
        beaconManager:(YTBeaconManager *)beaconManager
            majorArea:(id<YTMajorArea>)majorArea
            mapOffset:(double)offset;


- (void)start;

@end
