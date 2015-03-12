//
//  YTMapView2.m
//  HighGuang
//
//  Created by Yuan Tao on 10/15/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTMapView2.h"

@implementation YTMapView2{
    
    RMMapView *_internalMapView;
    YTAnnotationSource *_annotationSource;
    YTMapViewDetailState _detailState;
    YTUserAnnotation *_userAnnotation;
    CGFloat _offset;
    YTPathAnnotation *_pathAnnotation;
}

#pragma mark init
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        
        RMMBTilesSource *source = [[RMMBTilesSource alloc]initWithTileSetResource:@""];
        source.cacheable = NO;
        _internalMapView = [[RMMapView alloc] initWithFrame:CGRectMake(-CGRectGetWidth(frame) / 2, -CGRectGetHeight(frame) / 2, CGRectGetWidth(frame), CGRectGetHeight(frame)) andTilesource:source centerCoordinate:CLLocationCoordinate2DMake(0, 0) zoomLevel:2 maxZoomLevel:6 minZoomLevel:0 backgroundImage:nil];
        _internalMapView.hideAttribution = YES;
        _internalMapView.showLogoBug = NO;
        _internalMapView.delegate = self;
        _internalMapView.layer.anchorPoint = CGPointMake(0, 0);
        _annotationSource = [[YTAnnotationSource alloc] init];
        [self addSubview:_internalMapView];
        _map = _internalMapView;
    }
    return self;
}

#pragma mark Map Annimations
-(void)setZoom:(double)zoom animated:(BOOL)animated{
    [_internalMapView setZoom:zoom animated:animated];
}

-(void)zoomIn{
    [_internalMapView setZoom:_internalMapView.zoom + 0.2];
}

-(void)zoomOut{
    [_internalMapView setZoom:_internalMapView.zoom - 0.2];
}

-(void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated{
    [_internalMapView setCenterCoordinate:coordinate animated:animated];
}

-(void)setMapOffset:(CGFloat)offset{
    _offset = offset;
}

#pragma mark Map data manipulation
-(void)displayMapNamed:(NSString *)mapName{
    
    [_internalMapView addAndDisplayTileSourceNamed:mapName];
}

-(void)addPois:(NSArray *)pois{
    
    NSMutableArray *annos = [NSMutableArray array];
    for(YTPoi *tmpPoi in pois){
        
        YTAnnotation *tmpAnnotation = [tmpPoi produceAnnotationWithMapView:_internalMapView];
        [_annotationSource setAnnotation:tmpAnnotation forPoi:tmpPoi];
        [annos addObject:tmpAnnotation];
        
    }
    
    [_internalMapView addAnnotations:annos];
    
}

-(void)addPoi:(YTPoi *)poi{
    YTAnnotation *tmpAnnotation = [poi produceAnnotationWithMapView:_internalMapView];
    [_annotationSource setAnnotation:tmpAnnotation forPoi:poi];
    [_internalMapView addAnnotation:tmpAnnotation];
}

-(void)removePois:(NSArray *)pois{
    
    NSMutableArray *annotations = [NSMutableArray array];
    for(YTPoi *tmpPoi in pois){
        [annotations addObject:[_annotationSource annotationForPoi:tmpPoi]];
    }
    
    [_annotationSource removeAnnotationsForPois:pois];
    [_internalMapView removeAnnotations:annotations];
    
}

-(void)reloadAnnotations{
    
}

-(void)removeAnnotations{
    [_annotationSource removeAllAnnotations];
    [_internalMapView removeAllAnnotations];
}

-(void)removeAnnotationForPoi:(YTPoi *)poi{
    YTAnnotation *tmp = [_annotationSource annotationForPoi:poi];
    if(tmp != nil){
        [_annotationSource removeAnnotationForPoi:poi];
        [_internalMapView removeAnnotation:tmp];
    }
}


#pragma mark 导航相关的state
-(YTMapViewDetailState)currentState{
    
    return _detailState;
    
}

-(void)setMapViewDetailState:(YTMapViewDetailState)detailState{
//    CGRect frame = _internalMapView.bounds;
//    if (detailState == YTMapViewDetailStateNormal) {
//        if (_detailState == YTMapViewDetailStateShowDetail) {
//            frame.size.height += 70;
//        }else if (_detailState == YTMapViewDetailStateNavigating){
//            frame = self.frame;
//            frame.origin.y += 44;
//            frame.size.height -= 44;
//            self.frame = frame;
//            
//            
//            frame = _internalMapView.bounds;
//            frame.origin.y = 0;
//            frame.size.height += 26;
//        }
//        
//    }else if (detailState == YTMapViewDetailStateShowDetail){
//        frame.size.height -= 70;
//    }else{
//        frame = self.frame;
//        frame.origin.y -= 44;
//        frame.size.height += 44;
//        self.frame = frame;
//        
//        frame = _internalMapView.bounds;
//        frame.origin.y = CGRectGetMinY(self.frame);
//        frame.size.height += 44;
//    }
//    _internalMapView.bounds = frame;
    _detailState = detailState;
}


#pragma mark Annotation animations
-(void)highlightPois:(NSArray *)pois animated:(BOOL)animated{
    for(YTPoi *tmpPoi in pois){
        YTAnnotation *tmpAnnotation = [_annotationSource annotationForPoi:tmpPoi];
        [tmpAnnotation highlightAnimated:animated];
    }
    
}

-(void)highlightPoi:(YTPoi *)poi animated:(BOOL)animated{
    
    YTAnnotation *tmpAnnotation = [_annotationSource annotationForPoi:poi];
    [tmpAnnotation highlightAnimated:animated];
    
}

-(void)superHighlightPoi:(YTPoi *)poi animated:(BOOL)animated{
    YTAnnotation *tmpAnnotation = [_annotationSource annotationForPoi:poi];
    [tmpAnnotation superHighlight:animated];
}

-(void)hidePoi:(YTPoi *)poi animated:(BOOL)animated{
    
    YTAnnotation *tmpAnnotation = [_annotationSource annotationForPoi:poi];
    [tmpAnnotation hideAnimated:animated];
    
}

-(void)setScore:(double)score
forMinorAreaPoi:(YTMinorAreaPoi *)minorPoi
{
    YTMinorAreaAnnotation *minorAnno = [_annotationSource annotationForPoi:minorPoi];
    RMMarker * layer = minorAnno.layer;
    [layer writeScore:score];
}

-(void)hidePois:(NSArray *)pois animated:(BOOL)animated{
    for(YTPoi *tmpPoi in pois){
        YTAnnotation *tmpAnnotation = [_annotationSource annotationForPoi:tmpPoi];
        [tmpAnnotation hideAnimated:animated];
    }
}

-(void)showUserLocationAtCoordinate:(CLLocationCoordinate2D)coordinate{
    if(_userAnnotation == nil){
        _userAnnotation = [[YTUserAnnotation alloc] initWithMapView:_internalMapView andCoordinate:coordinate];
        [_userAnnotation setOffset:_offset];
        [_internalMapView addAnnotation:_userAnnotation];
    }
    else{
        
        [_userAnnotation setCoordinate:coordinate];
        
    }
}

-(void)setUserCoordinate:(CLLocationCoordinate2D)coordinate{
    [_userAnnotation setCoordinate:coordinate];
}

-(void)removeUserLocation{
    
    if(_userAnnotation != nil){
        [_internalMapView removeAnnotation:_userAnnotation];
    }
    _userAnnotation = nil;
    
}



#pragma mark RMMapViewDelegate methods
-(void)doubleTapOnMap:(RMMapView *)map at:(CGPoint)point{
    CLLocationCoordinate2D coord = [map pixelToCoordinate:point];
    
    [self.delegate mapView:self doubleTapOnMap:[_internalMapView pixelToCoordinate:point]];
}

-(void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    
    if([annotation.annotationType isEqualToString:@"user"] || [annotation.annotationType isEqualToString:@"minor"]){
        return;
    }
    YTPoi *resultPoi = [_annotationSource poiForAnnotation:(YTAnnotation *)annotation];
    [self.delegate mapView:self tapOnPoi:resultPoi];
}

-(RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation{
    
    RMMapLayer *layer = [(YTAnnotation *)annotation produceLayer];
    return layer;
}

-(void)singleTapOnMap:(RMMapView *)map at:(CGPoint)point{
    YTAnnotation *anno = [_annotationSource closestAnnotationForCoordinate:[_internalMapView pixelToCoordinate:point] mapView:_internalMapView];
    
    if (anno == nil) {
        [self.delegate mapView:self singleTapOnMap:[_internalMapView pixelToCoordinate:point]];
    }else{
        YTPoi *resultPoi = [_annotationSource poiForAnnotation:anno];
        [self.delegate mapView:self tapOnPoi:resultPoi];
    }
   
}



-(void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction{

    
    NSLog(@"zoom %f",map.zoom);
    //[self refilterAnnotations];
    
}


-(void)refilterAnnotations{
    
    for(YTAnnotation *anno in _internalMapView.annotations){
        
        if(![anno isMemberOfClass:[YTMerchantAnnotation class]]){
            continue;
        }
        
        //如果是highlight的annotation则不做处理
        if(anno.state == YTAnnotationStateHighlighted){
            continue;
        }
        
        if([anno.displayLevel floatValue] < _internalMapView.zoom || anno.state != YTAnnotationStateHidden){
            anno.layer.opacity = 1;
            anno.enabled = YES;
        }
        else{
            anno.layer.opacity = 0;
            anno.enabled = NO;
        }
        
    }
    
}


-(void)zoomToShowPoint1:(CLLocationCoordinate2D)point1 point2:(CLLocationCoordinate2D)point2{
    float neLatitude = MAX(point1.latitude,point2.latitude);
    float neLongtitude = MAX(point1.longitude, point2.longitude);
    
    float swLatitude = MIN(point1.latitude,point2.latitude);
    float swLongtitude = MIN(point1.longitude, point2.longitude);
    
    
    neLatitude = MIN(neLatitude+10, 90);
    neLongtitude = MIN(neLongtitude+20, 180);
    
    swLatitude = MAX(swLatitude-10, -90);
    swLongtitude = MAX(swLongtitude-20, -180);
    
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(neLatitude, neLongtitude);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(swLatitude, swLongtitude);
    
    [_internalMapView zoomWithLatitudeLongitudeBoundsSouthWest:southWest northEast:northEast animated:NO];
    
    [_internalMapView reloadTileSource:_internalMapView.tileSource];
    
}

-(double)canonicalDistanceFromCoordinate1:(CLLocationCoordinate2D)coordinate1
                   toCoordinate2:(CLLocationCoordinate2D)coordinate2{
    CGPoint point1 = [YTCanonicalCoordinate mapToCanonicalCoordinate:coordinate1 mapView:_internalMapView];
    
    CGPoint point2 = [YTCanonicalCoordinate mapToCanonicalCoordinate:coordinate2 mapView:_internalMapView];
    double xdiff = point1.x - point2.x;
    double ydiff = point1.y - point2.y;
    
    return sqrt(xdiff*xdiff+ydiff*ydiff);
    
}


-(void)showPathFromCoord1:(CLLocationCoordinate2D)c1
                 toCoord2:(CLLocationCoordinate2D)c2
             forMajorArea:(id<YTMajorArea>)majorArea{
    
    if(_pathAnnotation != nil){
        [_internalMapView removeAnnotation:_pathAnnotation];
    }
    
    CGPoint p1 = [YTCanonicalCoordinate mapToCanonicalCoordinate:c1 mapView:_internalMapView];
    CGPoint p2 = [YTCanonicalCoordinate mapToCanonicalCoordinate:c2 mapView:_internalMapView];
    _pathAnnotation = [[YTPathAnnotation alloc] initWithMapView:_internalMapView majorArea:majorArea fromPoint1:p1 toPoint2:p2];
    
    if(_pathAnnotation != nil){
        [_internalMapView addAnnotation:_pathAnnotation];
    }
    
}

-(void)removePath{
    if(_pathAnnotation != nil){
        [_internalMapView removeAnnotation:_pathAnnotation];
    }
}

@end
