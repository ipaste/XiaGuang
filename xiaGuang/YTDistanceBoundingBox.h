//
//  YTDistanceBoundingBox.h
//  Bee
//
//  Created by Meng Hu on 11/3/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <RMMapView.h>

@interface YTDistanceBoundingBox : NSObject

- (id)initWithMapView:(RMMapView *)mapView;

- (CGPoint)updateAndGetCurrentPoint:(CGPoint)newPoint;

@end
