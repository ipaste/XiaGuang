//
//  YTPedometer.m
//  Bee
//
//  Created by Meng Hu on 10/28/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import "YTNaiveStepDetector.h"

#import <CoreMotion/CoreMotion.h>

@interface YTNaiveStepDetector() {
    double _px;
    double _py;
    double _pz;
    
    BOOL _isSleeping;
    
    CMMotionManager *_motionManager;
}

- (BOOL)isStep:(CMAccelerometerData*)data;
- (void)wakeUp;

@end

@implementation YTNaiveStepDetector

- (instancetype)init
{
    self = [super init];
    if (self) {
        _px = _py = _pz = 0;
        _isSleeping = NO;
        
        _motionManager = [[CMMotionManager alloc] init];
    }
    return self;
}

- (BOOL)isStep:(CMAccelerometerData*)data {
    
    BOOL result = NO;
    
    double xx = data.acceleration.x;
    double yy = data.acceleration.y;
    double zz = data.acceleration.z;
    
    double dot = (_px * xx) + (_py * yy) + (_pz * zz);
    double a = ABS(sqrt(_px * _px + _py * _py + _pz * _pz));
    double b = ABS(sqrt(xx * xx + yy * yy + zz * zz));
    
    dot /= (a * b);
    
    if ( dot <= 0.999 && dot >= 0.8 ) {
        if (!_isSleeping) {
            _isSleeping = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(wakeUp) withObject:nil afterDelay:0.3];
            });
            
            result = YES;
        }
    }
    
    _px = xx; _py = yy; _pz = zz;
    
    return result;
}

- (void)start {
    [_motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
                                         withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                             if (error == nil) {
                                                 if ([self isStep:accelerometerData]) {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [_delegate detectStep];
                                                     });
                                                 }
                                             }
                                         }];
}

- (void)stop {
    [_motionManager stopAccelerometerUpdates];
}


- (void)wakeUp {
    _isSleeping = NO;
}

@end
