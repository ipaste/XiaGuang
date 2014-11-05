//
//  YTDirectionIndicator.h
//  HighGuang
//
//  Created by Yuan Tao on 8/18/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface YTDirectionIndicator : UIView

@property (nonatomic) CLLocationCoordinate2D targetCordinate;

- (id)initWithScaleInPx:(int)scale andOrigin:(CGPoint)origin;
-(void)showDirectionForCurrentLocation:(CLLocationCoordinate2D)coord;

@end
