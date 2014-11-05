//
//  YTCanonicalCoordinate.m
//  Bee
//
//  Created by Meng Hu on 10/13/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import "YTCanonicalCoordinate.h"

#define WORLD_LAT 85
#define WORLD_LONG  180

@implementation YTCanonicalCoordinate

+ (CGPoint)mapToCanonicalCoordinate:(CLLocationCoordinate2D)coord
                            mapView:(RMMapView *)view {
    
    CGPoint topLeft = [view coordinateToPixel:CLLocationCoordinate2DMake(WORLD_LAT, -WORLD_LONG)];
    CGPoint bottomLeft = [view coordinateToPixel:CLLocationCoordinate2DMake(-WORLD_LAT, -WORLD_LONG)];
    
    double verticalDist = bottomLeft.y - topLeft.y;
    
    double scale = kYTCanonicalCoordinateDimension / verticalDist;
    
    
    CGPoint point = [view coordinateToPixel:coord];
    CGPoint adjustedPoint = CGPointMake(point.x - topLeft.x,
                                        point.y - topLeft.y);
    
    double finalX;
    double finalY;
    
    finalX = adjustedPoint.x * scale;
    finalY = adjustedPoint.y * scale;
    
    return CGPointMake(finalX,finalY);
}

+ (CLLocationCoordinate2D)canonicalToMapCoordinate:(CGPoint)point
                                           mapView:(RMMapView *)view {
    
    CGPoint topLeft = [view coordinateToPixel:CLLocationCoordinate2DMake(WORLD_LAT, -WORLD_LONG)];
    CGPoint bottomLeft = [view coordinateToPixel:CLLocationCoordinate2DMake(-WORLD_LAT, -WORLD_LONG)];
    
    double verticalDist = bottomLeft.y - topLeft.y;
    
    double scale = verticalDist/ kYTCanonicalCoordinateDimension;
    
    CGPoint adjustedPoint = CGPointMake(point.x * scale + topLeft.x,
                                        point.y * scale + topLeft.y);
    
    CLLocationCoordinate2D loc = [view pixelToCoordinate:adjustedPoint];
    
    double finalLat;
    double finalLong;
    
    finalLat = loc.latitude;
    finalLong = loc.longitude;
    
    if (finalLat <= -WORLD_LAT) {
        finalLat = finalLat + 0.1;
    }
    
    if (finalLong <= -WORLD_LONG) {
        finalLong = finalLong + 0.1;
    }
    
    return CLLocationCoordinate2DMake(finalLat, finalLong);
}

+ (double)worldToCanonicalDistance:(double)dist
                           mapView:(RMMapView *)view
                         majorArea:(id<YTMajorArea>)majorArea {
    
    CGPoint topLeft = [view coordinateToPixel:CLLocationCoordinate2DMake(WORLD_LAT, -WORLD_LONG)];
    CGPoint bottomLeft = [view coordinateToPixel:CLLocationCoordinate2DMake(-WORLD_LAT, -WORLD_LONG)];
    
    double verticalDist = bottomLeft.y - topLeft.y;
    
    double pixelToCanonicalScale = kYTCanonicalCoordinateDimension / verticalDist;
    
    return (dist * majorArea.worldToMapRatio * pixelToCanonicalScale) / view.metersPerPixel;
}

+ (double)canonicalToWorldDistance:(double)dist
                           mapView:(RMMapView *)view
                         majorArea:(id<YTMajorArea>)majorArea {
                             
    CGPoint topLeft = [view coordinateToPixel:CLLocationCoordinate2DMake(WORLD_LAT, -WORLD_LONG)];
    CGPoint bottomLeft = [view coordinateToPixel:CLLocationCoordinate2DMake(-WORLD_LAT, -WORLD_LONG)];
    
    double verticalDist = bottomLeft.y - topLeft.y;
    
    double canonicalToPixelScale = verticalDist / kYTCanonicalCoordinateDimension;
    
    return dist * canonicalToPixelScale * view.metersPerPixel / majorArea.worldToMapRatio;
}

@end
