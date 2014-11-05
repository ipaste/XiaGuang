//
//  YTKalmanFilteredPositionBot.h
//  Bee
//
//  Created by Meng Hu on 10/24/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import <RMMapView.h>

@interface YTKalmanFilteredPositionBot : NSObject

- (id)initWithTimeUpdateInterval:(double)interval
                         mapView:(RMMapView *)mapView;

- (void)start;

- (CGPoint)reportSample:(CGPoint)sample;

@end
