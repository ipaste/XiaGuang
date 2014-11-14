//
//  YTAnnotationSource.m
//  HighGuang
//
//  Created by Yuan Tao on 10/16/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTAnnotationSource.h"
#import "YTMerchantAnnotation.h"
#import "YTCanonicalCoordinate.h"

@implementation YTAnnotationSource{
    NSMutableDictionary *_internalDict;
    NSMutableDictionary *_poiDict;
    
    NSMutableArray *_merchantAnnoArray;
}

-(id)init{
    self = [super init];
    if(self){
        _internalDict = [[NSMutableDictionary alloc] init];
        _poiDict = [[NSMutableDictionary alloc] init];
        _merchantAnnoArray = [NSMutableArray array];
    }
    return self;
}

-(void)setAnnotation:(YTAnnotation *)annotation forPoi:(YTPoi *)poi{
    [_internalDict setObject:annotation forKey:poi.poiKey];
    [_poiDict setObject:poi forKey:annotation.annotationKey];
    
    if([annotation isMemberOfClass:[YTMerchantAnnotation class]]){
        [_merchantAnnoArray addObject:annotation];
    }
}

-(YTAnnotation *)annotationForPoi:(YTPoi *)poi{
    return [_internalDict objectForKey:poi.poiKey];
}

-(void)removeAnnotationForPoi:(YTPoi *)poi{
    YTAnnotation *anno = (YTAnnotation *)[_internalDict objectForKey:poi.poiKey];
    NSString *tmp = [(YTAnnotation *)[_internalDict objectForKey:poi.poiKey] annotationKey];
    if (tmp != nil) {
        [_internalDict removeObjectForKey:poi.poiKey];
        [_poiDict removeObjectForKey:tmp];
    }
    
    if([anno isMemberOfClass:[YTMerchantAnnotation class]]){
        [_merchantAnnoArray removeObject:anno];
    }

}
    

-(void)removeAllAnnotations{
    _internalDict = [[NSMutableDictionary alloc] init];
    _poiDict = [[NSMutableDictionary alloc] init];
    _merchantAnnoArray = [NSMutableArray array];
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

-(YTAnnotation *)closestAnnotationForCoordinate:(CLLocationCoordinate2D)tapCoordinate
                                        mapView:(RMMapView *)mapView{
    
    CGPoint targetCord = [YTCanonicalCoordinate mapToCanonicalCoordinate:tapCoordinate mapView:mapView];
    YTAnnotation *result = nil;
    YTAnnotation *tmp;
    double curMinDistance = MAXFLOAT;
    CGPoint tmpCoord;
    for(int i = 0; i<_merchantAnnoArray.count; i++){
        tmp = _merchantAnnoArray[i];
        tmpCoord = [YTCanonicalCoordinate mapToCanonicalCoordinate:tmp.coordinate mapView:mapView];
        double tmpDist = [self distanceFromPoint1:tmpCoord toPoint2:targetCord];
        if(result == nil || tmpDist<curMinDistance){
            curMinDistance = tmpDist;
            result = tmp;
        }
        
    }
    
    return result;
}

-(double)distanceFromPoint1:(CGPoint)point1
                  toPoint2:(CGPoint)point2{
    
    double xdiff = point1.x - point2.x;
    double ydiff = point1.y - point2.y;
    return sqrt(xdiff*xdiff + ydiff*ydiff);
}

@end
