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
        self = [super initWithMapView:mapView coordinate:((CLLocation *)[locs objectAtIndex:0]).coordinate andTitle:@"Home"];
    }
    
    if(self){
        self.userInfo = locs;
        [self setBoundingBoxFromLocations:locs];
    }
    
    return self;
}


-(void)changeStartPoint:(CGPoint)p{
    NSArray *newGrpha = [YTCanonicalCoordinate graphChangeStartPoint:p graph:_graph];
    _graph = newGrpha;
    NSMutableArray *locs = [NSMutableArray array];
    for (NSValue *val in newGrpha) {
        CGPoint point = [val CGPointValue];
        CLLocationCoordinate2D coord = [YTCanonicalCoordinate canonicalToMapCoordinate:point mapView:self.mapView];
        [locs addObject:[[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude]];
    }
    self.userInfo = locs;
    [_shape removeFromSuperlayer];
    _shape = nil;
    [self.mapView removeAnnotation:self];
    [self.mapView addAnnotation:self];
    
}

-(RMMapLayer *)produceLayer{
    if (!_shape) {
        _shape = [[RMShape alloc] initWithView:self.mapView];
        
        _shape.lineColor = [UIColor orangeColor];
        _shape.lineWidth = 3.0;
        
        for (CLLocation *location in (NSArray *)self.userInfo){
            [_shape addLineToCoordinate:location.coordinate];
        }
    }
    return _shape;

}
@end
