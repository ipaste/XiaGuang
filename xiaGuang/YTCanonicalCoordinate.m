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
    
    
    //interesting here
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

+ (NSArray *)graphChangeStartPoint:(CGPoint)startPoint
                             graph:(NSArray *)graph{
    
    NSMutableArray *newGraph = [NSMutableArray arrayWithArray:graph];
    NSRange range;
    double minDistance = MAXFLOAT;
    CGPoint point;
    for (NSInteger index = 0; index < graph.count / 2; index ++) {
        CGPoint point1 = [graph[index * 2] CGPointValue];
        CGPoint point2 = [graph[index * 2 + 1] CGPointValue];
        CGPoint bitchPoint = [YTCanonicalCoordinate projectPoint:startPoint toNode:point1 andNode:point2];
        double distance = sqrt(pow(startPoint.x - bitchPoint.x, 2) + pow(startPoint.y - bitchPoint.y, 2));
        if (distance < minDistance) {
            minDistance = distance;
            range = NSMakeRange(0, index * 2);
            point = bitchPoint;
        }
    }
    [newGraph removeObjectsInRange:range];
    [newGraph insertObject:[NSValue valueWithCGPoint:point] atIndex:0];
    return newGraph;
}

+ (CGPoint)projectPoint:(CGPoint)point
                 toNode:(CGPoint)node1
                andNode:(CGPoint)node2 {
    
    
    double x = 0;
    double y = 0;
    
    double x1 = node1.x;
    double y1 = node1.y;
    
    double x2 = node2.x;
    double y2 = node2.y;
    
    double x0 = point.x;
    double y0 = point.y;
    
    /* by Hu Meng
    if (abs(x1 - x2) <= 0.1) {
        // vertical
        x = x1;
        y = y0;
    } else if (abs(y1 - y2) <= 0.1) {
        // horizontal
        x = x0;
        y = y1;
    } else {
        
        double a = (y2 - y1) / (x2 - x1);
        double b = -1;
        double c = y1 - a * x1;
        
        x = (b * (b*x0 - a*y0) - a*c) / (a*a + b*b);
        y = (a * (a*y0 - b*x0) - b*c) / (a*a + b*b);
    }
    
    
    
    if (x < MIN(x1, x2)) {
        if (x1 < x2) {
            return CGPointMake(x1, y1);
        } else {
            return CGPointMake(x2, y2);
        }
    } else if (x > MAX(x1,x2)) {
        if (x1 > x2) {
            return CGPointMake(x1, y1);
        } else {
            return CGPointMake(x2, y2);
        }
    } else if (abs(x1 - x2) < 0.1) {
        if (y < MIN(y1, y2)) {
            if (y1 < y2) {
                return CGPointMake(x1, y1);
            } else {
                return CGPointMake(x2, y2);
            }
        } else if (y > MAX(y1, y2)) {
            if (y1 > y2) {
                return CGPointMake(x1, y1);
            } else {
                return CGPointMake(x2, y2);
            }
        } else {
            return CGPointMake(x, y);
        }
    } else {
        return CGPointMake(x, y);
    }*/
    
    //euwen modified
    double cross = (x2-x1)*(x0-x1)+(y2-y1)*(y0-y1);
    
    if (cross <= 0) {
        return CGPointMake(x1, y1);
    }
    
    double d2 = (x2-x1)*(x2-x1)+(y2-y1)*(y2-y1);
    if (cross >= d2) {
        return CGPointMake(x2, y2);
    }
    
    double r0 = cross/d2;
    return CGPointMake(x1+(x2-x1)*r0, y1+(y2-y1)*r0);
    
}


@end
