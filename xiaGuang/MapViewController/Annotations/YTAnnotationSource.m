//
//  YTAnnotationSource.m
//  HighGuang
//
//  Created by Yuan Tao on 10/16/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTAnnotationSource.h"

@implementation YTAnnotationSource{
    NSMutableDictionary *_internalDict;
    NSMutableDictionary *_poiDict;
}

-(id)init{
    self = [super init];
    if(self){
        _internalDict = [[NSMutableDictionary alloc] init];
        _poiDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)setAnnotation:(YTAnnotation *)annotation forPoi:(YTPoi *)poi{
    [_internalDict setObject:annotation forKey:poi.poiKey];
    [_poiDict setObject:poi forKey:annotation.annotationKey];
}

-(YTAnnotation *)annotationForPoi:(YTPoi *)poi{
    return [_internalDict objectForKey:poi.poiKey];
}

-(void)removeAnnotationForPoi:(YTPoi *)poi{
    NSString *tmp = [(YTAnnotation *)[_internalDict objectForKey:poi.poiKey] annotationKey];
    [_internalDict removeObjectForKey:poi.poiKey];
    [_poiDict removeObjectForKey:tmp];
}

-(void)removeAllAnnotations{
    _internalDict = [[NSMutableDictionary alloc] init];
    _poiDict = [[NSMutableDictionary alloc] init];
}

-(void)removeAnnotationsForPois:(NSArray *)pois{
    
    NSMutableArray *poiKeys = [[NSMutableArray alloc] init];
    NSMutableArray *annoKeys = [[NSMutableArray alloc] init];
    for(YTPoi *tmpPoi in pois){
        [poiKeys addObject:tmpPoi.poiKey];
        YTAnnotation *tmpAnno = [_internalDict objectForKey:tmpPoi.poiKey];
        [annoKeys addObject:tmpAnno.annotationKey];
    }
    
    [_internalDict removeObjectsForKeys:poiKeys];
    [_poiDict removeObjectsForKeys:annoKeys];
    
}

-(YTPoi *)poiForAnnotation:(YTAnnotation *)anno{
    return [_poiDict objectForKey:anno.annotationKey];
}


@end
