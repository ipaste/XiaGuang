//
//  YTMerchantPoi.m
//  HighGuang
//
//  Created by Yuan Tao on 10/17/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTMerchantPoi.h"

@implementation YTMerchantPoi{
    id<YTMerchantLocation> _merchantLocation;
    NSString *_key;
}

-(id)initWithMerchantInstance:(id<YTMerchantLocation>)merchantLocation{
    self = [super init];
    if(self){
        _merchantLocation = merchantLocation;
    }
    return self;
}

@synthesize poiKey;

-(NSString *)poiKey{
    if(_key==nil){
        _key = [NSString stringWithFormat:@"merchant-%@",[_merchantLocation merchantLocationName]];
        
    }
    return _key;
}

-(YTAnnotation *)produceAnnotationWithMapView:(RMMapView *)mapView{
    YTMerchantAnnotation *resultAnnotation = [[YTMerchantAnnotation alloc] initWithMapView:mapView andMerchantLocation:_merchantLocation];
    resultAnnotation.annotationKey = [self poiKey];
    
    return resultAnnotation;
}

-(id)sourceModel{
    return _merchantLocation;
}

@end
