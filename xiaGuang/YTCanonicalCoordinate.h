//
//  YTCanonicalCoordinate.h
//  Bee
//
//  Created by Meng Hu on 10/13/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MapBox.h"
#import "YTMajorArea.h"

#define kYTCanonicalCoordinateDimension 180

/**
 *  180 X 180 Coordinate System, with top-left corner being (0,0)
 */
@interface YTCanonicalCoordinate : NSObject

+ (CGPoint)mapToCanonicalCoordinate:(CLLocationCoordinate2D)coord
                            mapView:(RMMapView *)view;

+ (CLLocationCoordinate2D)canonicalToMapCoordinate:(CGPoint)point
                                           mapView:(RMMapView *)view;

+ (double)worldToCanonicalDistance:(double)dist
                           mapView:(RMMapView *)view
                         majorArea:(id<YTMajorArea>)majorArea;

+ (double)canonicalToWorldDistance:(double)dist
                           mapView:(RMMapView *)view
                         majorArea:(id<YTMajorArea>)majorArea;

+ (NSArray *)graphChangeStartPoint:(CGPoint)startPoint
                             graph:(NSArray *)graph;

+ (CGPoint)projectPoint:(CGPoint)point
                 toNode:(CGPoint)node1
                andNode:(CGPoint)node2;

@end
