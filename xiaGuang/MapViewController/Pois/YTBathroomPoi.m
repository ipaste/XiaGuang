//
//  YTBathroomPoi.m
//  HighGuang
//
//  Created by Yuan Tao on 10/22/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTBathroomPoi.h"

@implementation YTBathroomPoi{
    id<YTBathroom> _bathroom;
    NSString *_key;
}

-(id)initWithBathroom:(id<YTBathroom>)bathroom{
    self = [super init];
    if(self){
        _bathroom = bathroom;
        
    }
    return self;
}

@synthesize poiKey;

-(NSString *)poiKey{
    if(_key==nil){
        
        _key = [NSString stringWithFormat:@"bathroom-%@",[_bathroom identifier]];
        
    }
    return _key;
}

-(YTAnnotation *)produceAnnotationWithMapView:(RMMapView *)mapView{
    YTBathroomAnnotation *resultAnnotation = [[YTBathroomAnnotation alloc] initWithMapView:mapView andBathroom:_bathroom];
    resultAnnotation.annotationKey = [self poiKey];
    
    return resultAnnotation;
}

-(id)sourceModel{
    return _bathroom;
}

@end
