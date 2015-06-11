//
//  YTDeadReckoning.m
//  MoonRunner
//
//  Created by Youwen Yi on 2/2/15.
//  Copyright (c) 2015 Youwen Yi. All rights reserved.
//

#import "YTDeadReckoning.h"
#import <stdlib.h>

#import "YTCanonicalCoordinate.h"


#define kRadToDeg   57.2957795

#define stepLen 1.80 //unit: meters

#define alphaTracker 0.23 //smoothing factor, cutoff frequency 3Hz

#define stepDetectThreshold 0.08 //step detection threshold

#define particleNum 20 //number of particles in particle filter

#define distanceThreshold 25 //unit: meters, distance threshold for new start point of DR

#define resampleRatio 0.8 //resample ratio for particle filter

#define directionDiffThreshold M_PI/4 //direction difference threshold

#define outlierCounterThreshold 3 // count the outliers of abnormal estimation


@implementation YTDeadReckoning{
   
    int _lastStep;
    
    int _currentStep;
    
    double _lastGravity;
    
    double _lastDirection;//for direction smoothing
    
    CGPoint _lastPosition;// to determine whether need to reset the start point of deadreckoning
    
    NSInteger _outlierCounter;
    
    double _distanceThresholdSquare;
    
    // for particle filter
    CGPoint _startPointBuffer;
    
    double _stepLens[particleNum];
    
    CGPoint _positions[particleNum];
    
    double _particleWeight[particleNum];
    
    CGPoint _refPoint; //reference point for filtering
    
    __weak RMMapView *_mapView;
    
    __weak id<YTMajorArea> _majorArea;
    
    NSDate *_startDate;
    
}

- (id)initWithMapView:(RMMapView *)mapView
            majorArea:(id<YTMajorArea>)majorArea {
    self = [super init];
    if (self) {
        _mapView = mapView;
        _majorArea = majorArea;
    }
    return self;
}

-(void)startSensorReading{
    
    //initialization
    _lastStep = 1;
    _lastDirection = 0.0;
    _lastGravity = 0.0;
    
    _outlierCounter = 0;
    
    _startPoint = CGPointZero;
    _startPointBuffer = CGPointZero;
    
    _pathDirection = 0.0;
    
    for (int i=0; i<particleNum; i++) {
        
        _stepLens[i] = [YTCanonicalCoordinate worldToCanonicalDistance:(stepLen + (arc4random()%100)/100.0-0.5)/_mapMeterPerPixel
                                                               mapView:_mapView
                                                             majorArea:_majorArea];
        _particleWeight[i] = 1.0/particleNum;
        
    }
    
    //update the distance threshold
    _distanceThresholdSquare = [YTCanonicalCoordinate worldToCanonicalDistance:distanceThreshold
                                                                       mapView:_mapView
                                                                     majorArea:_majorArea];
    
    _distanceThresholdSquare = _distanceThresholdSquare*_distanceThresholdSquare;
    
    //heading
    _locationManger = [[CLLocationManager alloc]init];
    _locationManger.delegate = self;
    
    if ([CLLocationManager headingAvailable]) {
        _locationManger.headingFilter = 10; //unit:degree;
        [_locationManger startUpdatingHeading];
        
    }
    
    //device motion
    _motionManager = [[CMMotionManager alloc]init];
    
    //mag data
//    _motionManager.magnetometerUpdateInterval = 0.2;
//    [_motionManager startMagnetometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMMagnetometerData *magData, NSError *error) {
//        if (error) {
//            NSLog(@"Magnetometer Error: %@", error);
//            
//        } else {
//            [self outputMagData:magData];
//        }
//    }];
    
    //motion data
    _motionManager.deviceMotionUpdateInterval = 0.2;
    [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error){
        if (error ) {
            NSLog(@"Motion Error: %@", error);
            
        }else{            
            [self outputMotionData:motion];
            
        }
        
    }];
    
}


-(void)stopSensorReading{
    
    [_motionManager stopDeviceMotionUpdates];
//    [_motionManager stopMagnetometerUpdates];
    [_locationManger stopUpdatingHeading];
    
}


-(void)locationManager:(CLLocationManager *)manager
      didUpdateHeading:(CLHeading *)newHeading{
    
    if (newHeading.headingAccuracy < 0) {
        return;
    }
    
    CLLocationDirection theHeading = ((newHeading.trueHeading > 0) ?
                                      newHeading.trueHeading:newHeading.magneticHeading);
    
    
    //for indoor map
    _currentDirection = (theHeading - 90 - _mapNorthOffset)/kRadToDeg;
    
    _currentDirection = fmod(_currentDirection + 2*M_PI, 2*M_PI);
    
    //for outdoor map
    //    _currentDirection = (theHeading-90)/kRadToDeg;
    
    //avoid the direction jump from 0 to 2pi or 2pi to 0
    if (_lastDirection != 0 && fabs(_currentDirection - _lastDirection) < M_PI ) {
        _currentDirection = [self smoothing:_currentDirection lastData:_lastDirection];
    }
    
    _lastDirection = _currentDirection;
}

-(void)outputMotionData:(CMDeviceMotion *)motion{
    
    _motionData = motion;
    
    //check whether input start point
    if (!CGPointEqualToPoint(_startPoint, CGPointZero) ) {
        
        if(CGPointEqualToPoint(_lastPosition, CGPointZero)){
        
            _lastPosition = _startPoint;
        }
        
        _refPoint = _startPoint;
        
        //check whether need to update the location with new start point
        if( pow((_startPoint.x-_lastPosition.x), 2)+pow((_startPoint.y-_lastPosition.y), 2)> _distanceThresholdSquare){
            
            //abnormal continue
            _outlierCounter++;
            
            if(_outlierCounter >= outlierCounterThreshold){
                
                _lastPosition = _startPoint;//mark the new start position
                
                _startPointBuffer = CGPointZero;
                
                //change the start point of all particles to the new point
                
                for (int i=0; i<particleNum; i++) {
                    _positions[i] = _startPoint;
                }

            }else{//to avoid abnormal start point interference
                
                _refPoint = _lastPosition;
            }
            
        }else{
            
            //abnormal is gone
            _outlierCounter = 0;

        }
  
        //step count
        [self stepCount:motion.userAcceleration gravityInfo:motion.gravity directionInfo:_currentDirection];
    }
    
}


//-(void)outputMagData:(CMMagnetometerData *)magData{
//    
//    //NSLog(@"direciton: %f", magData.magneticField.x);
//    //_currentDirection = (magData.magneticField.y+90)/kRadToDeg;
//    
//    _magData = magData;
//}

-(int)stepCount:(CMAcceleration)userAccData
    gravityInfo:(CMAcceleration)gravityData
  directionInfo:(double)directionData{
    
    __block double direction = directionData;
    
    
    //double _gravity = sqrt(pow(userAccData.x, 2) + pow(userAccData.y, 2) + pow(userAccData.z, 2));
    
    //use the accelaration only in the gravity direction
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        double _gravity = (gravityData.x*userAccData.x + gravityData.y*userAccData.y + gravityData.z*userAccData.z);
        
        //   if (_lastGravity != 0) {
        //       _gravity = [self smoothing:_gravity lastData:_lastGravity];
        //    }
        
        _lastGravity = _gravity;
        
        if (_gravity >= stepDetectThreshold) {
            _currentStep = 1;
            
        } else {
            _currentStep = 0;
            
        }
        
        //change to the same range [0, 2*pi]
        _pathDirection = fmod(_pathDirection+2*M_PI, 2*M_PI);
        double _pathDirectionReverse = fmod(_pathDirection+M_PI, M_PI);
        
        BOOL directionFlag = false;
        
        //check whether the device direction is the same as path direction
        if( fabs(directionData - _pathDirection) < directionDiffThreshold ){
            
            direction = _pathDirection;
            
            directionFlag = true;
            
        }else if( fabs(directionData - _pathDirectionReverse ) < directionDiffThreshold){
            
            direction = _pathDirectionReverse;
            
            directionFlag = true;
        }
        
        
        if ((_currentStep - _lastStep) == 1 && directionFlag) {
            
            _stepCount++;
            
            NSLog(@"New step");
            
            //estimate the next step
            if ( CGPointEqualToPoint(_startPoint, _startPointBuffer)) {//no gps/BLE update
                
                [self locationParticleFilter:NO directionData:directionData];
                
            }else{//with gps/BLE update
                
                _startPointBuffer = _startPoint;
                
                [self locationParticleFilter:YES directionData:directionData];
                
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //optional, check first
                if ([self.delegate respondsToSelector:@selector(positionUpdating:)]) {
                    
                    //remark the new position
                    _lastPosition = _newPosition;
                    
                    [self.delegate positionUpdating:_newPosition];
                    
                    NSLog(@"new position:%f, %f", _newPosition.x, _newPosition.y);
                }
            });
            
        }else{
            
            //optional, check first
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(positionUpdating:)]) {
                    [self.delegate positionUpdating:_lastPosition];
                   // NSLog(@"last position:%f, %f", _lastPosition.x, _lastPosition.y);
                }
            });
            
        
        }
        
        _lastStep = _currentStep;
        
    });
    
    
    return _stepCount;
}


-(double)smoothing:(double)rawData
          lastData:(double)lastData{
    
    double smoothedData = alphaTracker*rawData + (1-alphaTracker)*lastData;
    
    return smoothedData;
    
}

-(void)locationParticleFilter:(BOOL)locationUpdated directionData:(double)directionData{
    
    double directionCOS = cos(directionData);
    
    double directionSIN = sin(directionData);
    
    
    if (locationUpdated) {// with gps/BLE location update

        double weightBuffer = 0;
        for (int i=0; i<particleNum; i++) {
            
            double distanceSqure = pow(_positions[i].x - _refPoint.x,2)+pow(_positions[i].y - _refPoint.y,2);
            
            if (distanceSqure > _distanceThresholdSquare) {
                _particleWeight[i] = 0;
                
            } else {
                weightBuffer += _particleWeight[i];
                
            }
        }
        
        if (weightBuffer == 0) {// all the particles should be resampled
            
            CGPoint newPoint = CGPointZero;
            
            for (int i=0; i<particleNum; i++) {
                
                //step length, random, 10 meters
                _stepLens[i] = [YTCanonicalCoordinate worldToCanonicalDistance:(stepLen + (arc4random()%100)/100.0-0.5)/_mapMeterPerPixel
                                                                       mapView:_mapView
                                                                     majorArea:_majorArea];
                
                _particleWeight[i] = 1.0/particleNum;
                
                _positions[i].x = _refPoint.x + _stepLens[i]*directionCOS;
                _positions[i].y = _refPoint.y + _stepLens[i]*directionSIN;
                
                newPoint.x += _particleWeight[i]*_positions[i].x;
                newPoint.y += _particleWeight[i]*_positions[i].y;
            }
            _newPosition = newPoint;
            
            
        } else {//possible for resampling
            
            //determine whether resample needed
            //normalization
            _particleWeight[0] = _particleWeight[0]/weightBuffer;
            
            double pfEfficiency = pow(_particleWeight[0], 2);
            
            double cumWeight[particleNum];
            cumWeight[0] = _particleWeight[0];
            
            CGPoint positionBuffer[particleNum];
            positionBuffer[0] = _positions[0];
            
            for (int i=1; i<particleNum; i++) {
                
                //update the particle weight
                _particleWeight[i] = _particleWeight[i]/weightBuffer;
                
                //calculate the efficiency
                pfEfficiency += pow(_particleWeight[i], 2);
                
                //calculate the cumulative probability
                cumWeight[i] = cumWeight[i-1] + _particleWeight[i];
                
                //copy the positions for resampling
                positionBuffer[i] = _positions[i];
            }
            
            pfEfficiency = 1.0/pfEfficiency;
            
            if (pfEfficiency < particleNum*resampleRatio) {//resample needed
                
                int indexNum = 0;
                
                CGPoint newPoint = CGPointZero;;
                
                for (int i=0; i<particleNum; i++) {
                    
                    //generate a random number in (0,1);
                    double randNum = (arc4random()%100)/100.0;
                    
                    //find j such that cumWeight[j-1] < randNum < cumWeight[j]
                    int j = 0;
                    while (j < particleNum) {
                        if (randNum < cumWeight[j]) {
                            indexNum = j;
                            
                            break;
                        }
                        
                        j++;
                    }
                    
                    _stepLens[i] = _stepLens[indexNum];
                    
                    _positions[i] = positionBuffer[indexNum];
                    
                    _particleWeight[i] = 1.0/particleNum;
                    
                    _positions[i].x += _stepLens[i]*directionCOS;
                    _positions[i].y += _stepLens[i]*directionSIN;
                    
                    newPoint.x += _particleWeight[i]*_positions[i].x;
                    newPoint.y += _particleWeight[i]*_positions[i].y;
                    
                }
                _newPosition = newPoint;
                
                
            } else {//no need for resample
                
                CGPoint newPoint = CGPointZero;
                
                for (int i=0; i<particleNum; i++) {
                    
                    _positions[i].x += _stepLens[i]*directionCOS;
                    _positions[i].y += _stepLens[i]*directionSIN;
                    
                    newPoint.x += _particleWeight[i] * _positions[i].x;
                    newPoint.y += _particleWeight[i] * _positions[i].y;
                }
                
                _newPosition = newPoint;
                
            }
            
        }
        
    } else {// no gps update, dead reckoning continue
        
        CGPoint newPoint = CGPointZero;
        
        for (int i=0; i<particleNum; i++) {
            
            _positions[i].x += _stepLens[i]*directionCOS;
            _positions[i].y += _stepLens[i]*directionSIN;
            
            newPoint.x += _particleWeight[i] * _positions[i].x;
            newPoint.y += _particleWeight[i] * _positions[i].y;
        }

        _newPosition = newPoint;
    }

}


//for code exectuation time statistics
-(NSDate*)startTimer:(NSDate*)startTime{

    startTime = [NSDate date];
    
    return startTime;
}

-(void)stopTimer:(NSDate*)startTime{

    double deltaTime = [[NSDate date] timeIntervalSinceDate:startTime];
    NSLog(@"Cost time: %f ms", deltaTime*1000);

}

@end
