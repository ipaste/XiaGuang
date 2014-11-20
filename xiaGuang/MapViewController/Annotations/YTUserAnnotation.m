//
//  YTUserAnnotation.m
//  HighGuang
//
//  Created by Yuan Tao on 10/20/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTUserAnnotation.h"

@implementation YTUserAnnotation{
    RMMarker *_resultLayer;
    CLLocationManager *_locationManager;
}

@synthesize annotationKey;

-(id)initWithMapView:(RMMapView *)aMapView andCoordinate:(CLLocationCoordinate2D)acoordinate{
    self = [super initWithMapView:aMapView coordinate:acoordinate andTitle:nil];
    if(self){
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.headingFilter = kCLHeadingFilterNone;
        [_locationManager startUpdatingHeading];
        self.annotationType = @"user";
    }
    return self;
}

-(NSNumber *)displayLevel{
    //always display
    return [NSNumber numberWithInt:0];
}

-(RMMapLayer *)produceLayer{
    _resultLayer = [[RMMarker alloc] initWithUserLocation];
    
    return _resultLayer;
}

-(void)highlightAnimated:(BOOL)animated{
    [super highlightAnimated:animated];
}

-(void)hideAnimated:(BOOL)animated{
    [super hideAnimated:animated];
}

-(void)deactiveAnimated:(BOOL)animated{
    [super superHighlight:animated];
    
}
- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading{
    for(RMMarker * marker in _resultLayer.sublayers){
        if([marker.name isEqualToString:@"arrow"]){
            
            marker.transform = CATransform3DIdentity;
            
            CATransform3D transform3d = CATransform3DMakeRotation(M_PI *  newHeading.magneticHeading / 180, 0.0, 0.0, 1.0);
            
            marker.transform = transform3d;
            break;
        }
    }
}
-(NSString *)annotationKey{
    return @"user";
}

@end
