//
//  YTPathAnnotation.m
//  虾逛
//
//  Created by Yuan Tao on 1/5/15.
//  Copyright (c) 2015 YunTop. All rights reserved.
//

#import "YTPathAnnotation.h"

@implementation YTPathAnnotation


-(id)initWithMapView:(RMMapView *)mapView
             majorArea:(id<YTMajorArea>)majorArea
            fromPoint1:(CGPoint)p1
              toPoint2:(CGPoint)p2{
    
    YTMapGraph *graph = [[YTMapGraph alloc] initWithMajorArea:majorArea mapView:mapView];
    
    if(graph == nil)
        return nil;
    
    NSArray *points = [graph shortestPathWithProjectionFrom:p1 to:p2];
    
    NSMutableArray *locs = [[NSMutableArray alloc] init];
    
    for (NSValue *val in points) {
        
        CGPoint p = [val CGPointValue];
        CLLocationCoordinate2D coord = [YTCanonicalCoordinate canonicalToMapCoordinate:p mapView:mapView];
        
        [locs addObject:[[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude]];
    }
    
    if(locs != nil && locs.count > 0){
        self = [super initWithMapView:mapView coordinate:((CLLocation *)[locs objectAtIndex:0]).coordinate andTitle:@"Home"];
    }
    
    if(self){
        self.userInfo = locs;
        [self setBoundingBoxFromLocations:locs];
    }
    
    return self;
}



-(RMMapLayer *)produceLayer{
    
    RMShape *shape = [[RMShape alloc] initWithView:self.mapView];
    
    shape.lineColor = [UIColor orangeColor];
    shape.lineWidth = 3.0;
    
    /*
    shape.enableShadow = YES;
    shape.shadowColor = [[UIColor blackColor] CGColor];
    shape.shadowOpacity = 0.7;
    */
    
    for (CLLocation *location in (NSArray *)self.userInfo)
        [shape addLineToCoordinate:location.coordinate];
    
    return shape;
    
}
@end
