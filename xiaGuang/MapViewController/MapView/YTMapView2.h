//
//  YTMapView2.h
//  HighGuang
//
//  Created by Yuan Tao on 10/15/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mapbox.h"
#import "YTPoi.h"
#import "YTAnnotation.h"
#import "YTAnnotationSource.h"
#import "YTPoi.h"
#import "RMMapView+RMMapViewTileSourceHelpers.h"
#import "YTUserAnnotation.h"
#import "YTMerchantAnnotation.h"
#import "YTUserAnnotation.h"
#import "RMMapView+RMMapViewTileSourceHelpers.h"
#import "YTMinorAreaPoi.h"
#import "RMMarker+RMMarker_YTExtension.h"
#import "YTCanonicalCoordinate.h"
#import "YTMapGraph.h"
#import "YTPathAnnotation.h"    

typedef enum : NSUInteger {
    YTMapViewDetailStateNormal = 0,
    YTMapViewDetailStateShowDetail   = 1,
    YTMapViewDetailStateNavigating    = 2
} YTMapViewDetailState;

@class YTMapView2;

@protocol YTMapViewDelegate <NSObject>

-(void)mapView:(YTMapView2 *)mapView tapOnPoi:(YTPoi *)poi;

-(void)mapView:(YTMapView2 *)mapView singleTapOnMap:(CLLocationCoordinate2D)coordinate;

-(void)mapView:(YTMapView2 *)mapView doubleTapOnMap:(CLLocationCoordinate2D)coordinate;


-(void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction;

@end



@interface YTMapView2 : UIView<RMMapViewDelegate>

@property (nonatomic,weak) id<YTMapViewDelegate> delegate;
@property (nonatomic,readonly) RMMapView *map;
@property (nonatomic) BOOL isShowPath;


#pragma mark Map Annimations
-(void)setZoom:(double)zoom animated:(BOOL)animated;
-(void)zoomIn;
-(void)zoomOut;
-(void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
-(void)zoomToShowPoint1:(CLLocationCoordinate2D)point1 point2:(CLLocationCoordinate2D)point2;
-(void)setMapOffset:(CGFloat)offset;

#pragma mark Map data manipulation

-(void)showUserLocationAtCoordinate:(CLLocationCoordinate2D)coordinate;
-(void)setUserCoordinate:(CLLocationCoordinate2D)coordinate;
-(void)removeUserLocation;
-(void)displayMapNamed:(NSString *)mapName;
-(void)addPois:(NSArray *)pois;
-(void)addPoi:(YTPoi *)poi;
-(void)removePois:(NSArray *)pois;
-(void)reloadAnnotations;
-(void)removeAnnotations;
-(void)removeAnnotationForPoi:(YTPoi *)poi;

#pragma mark Annotation animations
-(void)highlightPois:(NSArray *)pois animated:(BOOL)animated;
-(void)highlightPoi:(YTPoi *)poi animated:(BOOL)animated;
-(void)superHighlightPoi:(YTPoi *)poi animated:(BOOL)animated;
-(void)hidePoi:(YTPoi *)poi animated:(BOOL)animated;
-(void)hidePois:(NSArray *)pois animated:(BOOL)animated;
-(void)showPathFromCoord1:(CLLocationCoordinate2D)c1
                 toCoord2:(CLLocationCoordinate2D)c2
             forMajorArea:(id<YTMajorArea>)majorArea;
-(void)removePath;
-(void)changePathFromStartCoord:(CLLocationCoordinate2D)coord;
-(void)setScore:(double)score
forMinorAreaPoi:(YTMinorAreaPoi *)minorPoi;

#pragma mark 导航相关的state
-(YTMapViewDetailState)currentState;
-(void)setMapViewDetailState:(YTMapViewDetailState)detailState;


-(double)canonicalDistanceFromCoordinate1:(CLLocationCoordinate2D)coordinate1
                            toCoordinate2:(CLLocationCoordinate2D)coordinate2;

@end
