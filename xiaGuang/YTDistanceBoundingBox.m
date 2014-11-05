//
//  YTDistanceBoundingBox.m
//  Bee
//
//  Created by Meng Hu on 11/3/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import "YTDistanceBoundingBox.h"

#import "YTCanonicalCoordinate.h"

@interface YTDistanceBoundingBox() {
    CGPoint _currentPoint;
    long _lastUpdateTime;
    double _speed;
    int _outOfRangeCount;
    
    RMMapView *_mapView;
    id<YTMajorArea> _majorArea;
}

@end

@implementation YTDistanceBoundingBox

- (id)initWithMapView:(RMMapView *)mapView
            majorArea:(id<YTMajorArea>)majorArea {
    self = [super init];
    if (self) {
        _currentPoint.x = 0;
        _currentPoint.y = 0;
        _lastUpdateTime = 0;
        _speed = 7;
        _outOfRangeCount = 0;
        _mapView = mapView;
        _majorArea = majorArea;
    }
    return self;   
}

- (CGPoint)updateAndGetCurrentPoint:(CGPoint)newPoint {
    if (_lastUpdateTime == 0) {
        _currentPoint.x = newPoint.x;
        _currentPoint.y = newPoint.y;
        
        _lastUpdateTime = [NSDate timeIntervalSinceReferenceDate];
    } else {
        
        long now = [NSDate timeIntervalSinceReferenceDate];
        
        if (_outOfRangeCount >= 3) {
            _currentPoint.x = newPoint.x;
            _currentPoint.y = newPoint.y;
            _lastUpdateTime = now;
            _outOfRangeCount = 0;
        } else {
            double dist = sqrt(pow(newPoint.x - _currentPoint.x, 2) + pow(newPoint.y - _currentPoint.y, 2));
            double adjustedDist = [YTCanonicalCoordinate canonicalToWorldDistance:dist
                                                                          mapView:_mapView
                                                                        majorArea:_majorArea];
            
            double range = (now - _lastUpdateTime) * _speed;
            
            if (adjustedDist >= range) {
                _outOfRangeCount++;
            } else {
                _currentPoint.x = newPoint.x;
                _currentPoint.y = newPoint.y;
                _lastUpdateTime = now;
                _outOfRangeCount = 0;
            }
        }
    }
    
    return _currentPoint;
}

@end
