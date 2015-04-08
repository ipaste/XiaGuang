//
//  YTPathAnnotation.m
//  虾逛
//
//  Created by Yuan Tao on 1/5/15.
//  Copyright (c) 2015 YunTop. All rights reserved.
//

#import "YTPathAnnotation.h"

typedef NS_ENUM(NSInteger, YTPathStyle) {
    YTPathStyleNormal = 0,
    YTPathStyleShortPath
};

@implementation YTPathAnnotation{
    NSArray *_graph;
    RMShape *_shape;
    RMMarker *_layer;
}


-(id)initWithMapView:(RMMapView *)mapView
             majorArea:(id<YTMajorArea>)majorArea
            fromPoint1:(CGPoint)p1
              toPoint2:(CGPoint)p2{
   YTMapGraph *mapGraph = [[YTMapGraphDict sharedInstance] getGraphFromMajorArea:majorArea usingMapview:mapView];
    
    if(mapGraph == nil)
        return nil;
    
    
    NSArray *points = [mapGraph shortestPathWithProjectionFrom:p1 to:p2];
    
    _graph = points;
    NSMutableArray *locs = [[NSMutableArray alloc] init];
    
    
    for (NSValue *val in points) {
        
        CGPoint p = [val CGPointValue];
        CLLocationCoordinate2D coord = [YTCanonicalCoordinate canonicalToMapCoordinate:p mapView:mapView];
        
        [locs addObject:[[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude]];
    }
    
    if(locs != nil && locs.count > 0){
        self = [super initWithMapView:mapView points:locs];
    }
    
    if(self){
        self.lineColor = [UIColor orangeColor];
        self.lineWidth = 3;
    }
    
    return self;
}

@end
