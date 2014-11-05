//
//  YTPoi.h
//  HighGuang
//
//  Created by Yuan Tao on 10/16/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "YTAnnotation.h"
@interface YTPoi : NSObject

@property (readonly,nonatomic) NSString *poiKey;

-(id)sourceModel;
-(YTAnnotation *)produceAnnotationWithMapView:(RMMapView *)mapView;

@end
