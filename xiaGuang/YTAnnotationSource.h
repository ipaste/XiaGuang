//
//  YTAnnotationSource.h
//  HighGuang
//
//  Created by Yuan Tao on 10/16/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTAnnotation.h"
#import "YTPoi.h"
@interface YTAnnotationSource : NSObject

-(id)init;
-(void)setAnnotation:(YTAnnotation *)annotation forPoi:(YTPoi *)poi;
-(YTAnnotation *)annotationForPoi:(YTPoi *)poi;
-(void)removeAnnotationForPoi:(YTPoi *)poi;
-(void)removeAllAnnotations;
-(void)removeAnnotationsForPois:(NSArray *)pois;
-(YTPoi *)poiForAnnotation:(YTAnnotation *)anno;

@end
