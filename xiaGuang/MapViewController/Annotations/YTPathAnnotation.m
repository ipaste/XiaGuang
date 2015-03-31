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
    CGPoint _endPoint;
    
    YTMapGraph *_mapGraph;
    
    YTPathStyle _style;
}


-(id)initWithMapView:(RMMapView *)mapView
             majorArea:(id<YTMajorArea>)majorArea
            fromPoint1:(CGPoint)p1
              toPoint2:(CGPoint)p2{
   _mapGraph = [[YTMapGraphDict sharedInstance] getGraphFromMajorArea:majorArea usingMapview:mapView];
    
    if(_mapGraph == nil)
        return nil;
    _endPoint = p2;
    
    NSArray *points = [_mapGraph shortestPathWithProjectionFrom:p1 to:p2];
    
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
        _style = YTPathStyleShortPath;
        [self setBoundingBoxFromLocations:locs];
    }
    
    return self;
}

-(instancetype) initWithMapView:(RMMapView *)mapView majorArea:(id<YTMajorArea>)majorArea{
    NSString *file = [[NSBundle mainBundle] pathForResource:[majorArea mapName] ofType:@"csv"];
    if (file == nil) {
        return NO;
    }
    
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSMutableArray *paths = [NSMutableArray array];
    
    for (NSString *line in lines) {
        if ([line isEqualToString:@""]) {
            continue;
        }
        NSArray *components = [line componentsSeparatedByString:@","];
        double x_1 = [components[1] doubleValue];
        double y_1 = [components[2] doubleValue];
        double x_2 = [components[3] doubleValue];
        double y_2 = [components[4] doubleValue];
        
        CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake(x_1, y_1);
        CLLocationCoordinate2D endCoord = CLLocationCoordinate2DMake(x_2, y_2);
        CGPoint startPoint = [YTCanonicalCoordinate mapToCanonicalCoordinate:startCoord mapView:mapView];
        CGPoint endPoint = [YTCanonicalCoordinate mapToCanonicalCoordinate:endCoord mapView:mapView];
        
        [paths addObject:@[[NSValue valueWithCGPoint:startPoint],[NSValue valueWithCGPoint:endPoint]]];
        
    }
    
    self = [super initWithMapView:mapView coordinate:CLLocationCoordinate2DMake(0, 0) andTitle:@"Home"];
    
    if (self) {
        _style = YTPathStyleNormal;
        self.userInfo = paths;
       
    }
    return self;
}

-(void)changeStartPoint:(CGPoint)p{
    NSArray *points = [_mapGraph shortestPathWithProjectionFrom:p to:_endPoint];
}

-(RMMapLayer *)produceLayer{
    
    if (_style == YTPathStyleShortPath) {
        RMShape *shape = [[RMShape alloc] initWithView:self.mapView];
        
        shape.lineColor = [UIColor orangeColor];
        shape.lineWidth = 3.0;
        
        for (CLLocation *location in (NSArray *)self.userInfo){
            [shape addLineToCoordinate:location.coordinate];
        }
        return shape;
    }
    return nil;
}
@end
