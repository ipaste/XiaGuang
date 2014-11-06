//
//  YTKalmanFilteredPositionBot.m
//  Bee
//
//  Created by Meng Hu on 10/24/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import "YTKalmanFilteredPositionBot.h"

#import "YTMatrixToolBox.h"

#import <Accelerate/Accelerate.h>

#import "YTMotionDetector.h"

@interface YTKalmanFilteredPositionBot()
<YTMotionDetectorDelegate> {
    
    double _updateInterval;
    
    // Variable
    double *_X;
    double *_P;
    double *_H;
    double *_H_trans;
    
    // Constant
    double *_A;
    double *_A_trans;
    double *_Q;
    double *_R;
    double *_I66;
    
    NSObject *_lock;
    
    BOOL _started;
    
    int _consecutiveTimeUpdate;
    
    int _ignoreTimeUpdate;
    
    YTMotionDetector *_motionD;
}

- (void)timeBasedUpdate;
- (void)sampleBasedUpdate:(CGPoint)point;

- (void)initializeConstants;
- (void)resetValues;

@end

@implementation YTKalmanFilteredPositionBot

- (id)initWithTimeUpdateInterval:(double)interval
                         mapView:(RMMapView *)mapView {
    self = [super init];
    if (self) {
        
        _updateInterval = interval;
       
        _X = (double *)malloc(6 * 1 * sizeof(double));
        _P = (double *)malloc(6 * 6 * sizeof(double));
        _H = (double *)malloc(2 * 6 * sizeof(double));
        _H_trans = (double *)malloc(6 * 2 * sizeof(double));
        _A = (double *)malloc(6 * 6 * sizeof(double));
        _A_trans = (double *)malloc(6 * 6 * sizeof(double));
        _Q = (double *)malloc(6 * 6 * sizeof(double));
        _R = (double *)malloc(2 * 2 * sizeof(double));
        _I66 = (double *)malloc(6 * 6 * sizeof(double));
        
        [self initializeConstants];
        [self resetValues];
      
        _started = NO;
        _consecutiveTimeUpdate = 0;
        
        _lock = [[NSObject alloc] init];
        
        _ignoreTimeUpdate = YES;
       
        _motionD =  [[YTMotionDetector alloc] init];
        _motionD.delegate = self;
    }
    return self;
}

- (void)start {
    [_motionD start];
    
    [NSTimer scheduledTimerWithTimeInterval:_updateInterval
                                     target:self
                                   selector:@selector(timeBasedUpdate)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)timeBasedUpdate {
    
    if (_ignoreTimeUpdate) {
        return;
    }
    
    @synchronized(_lock) {
        if (_started) {
            // Calculate X
            double *new_X = (double *)malloc(6 * 1 * sizeof(double));
            vDSP_mmulD(_A, 1, _X, 1, new_X, 1, 6, 1, 6);
            
            for (int i = 0; i < 6; i++) {
                
                if (i == 4 || i ==5) {
                    _X[i] = MIN(new_X[i], 9.8);
                }
            }
            
            free(new_X);
            
            // Calculate P
            double *AP = (double *)malloc(6 * 6 * sizeof(double));
            vDSP_mmulD(_A, 1, _P, 1, AP, 1, 6, 6, 6);
            
            double *APA_trans = (double *)malloc(6 * 6 * sizeof(double));
            vDSP_mmulD(AP, 1, _A_trans, 1, APA_trans, 1, 6, 6, 6);
            
            for (int i = 0; i < 36; i++) {
                _P[i] = APA_trans[i] + _Q[i];
            }
            
            free(AP);
            free(APA_trans);
            
            _consecutiveTimeUpdate++;
            
            if (_consecutiveTimeUpdate > (int)(3 / _updateInterval)) {
                _started = NO;
                _consecutiveTimeUpdate = 0;
                [self resetValues];
            }
        }
    }
}

- (CGPoint)reportSample:(CGPoint)sample {
    [self sampleBasedUpdate:sample];
    return CGPointMake(_X[0], _X[1]);
}

- (void)sampleBasedUpdate:(CGPoint)point {
    
    @synchronized(_lock) {
        if (_started) {
            
            // Calculate K
            double *HP = (double *)malloc(2 * 6 * sizeof(double));
            vDSP_mmulD(_H, 1, _P, 1, HP, 1, 2, 6, 6);
            
            double *HPH_trans = (double *)malloc(2 * 2 * sizeof(double));
            vDSP_mmulD(HP, 1, _H_trans, 1, HPH_trans, 1, 2, 2, 6);
            
            double *HPH_t_R = (double *)malloc(2 * 2 * sizeof(double));
            for (int i = 0; i < 4; i++) {
                HPH_t_R[i] = HPH_trans[i] + _R[i];
            }
            
            long error = [YTMatrixToolBox matrixInvertWithDimension:2 matrix:HPH_t_R];
            if (error != 0) {
                free(HP);
                free(HPH_trans);
                free(HPH_t_R);
                return;
            }
            
            double *HPH_R_inv = HPH_t_R;
            
            double *PH_trans = (double *)malloc(6 * 2 * sizeof(double));
            vDSP_mmulD(_P, 1, _H_trans, 1, PH_trans, 1, 6, 2, 6);
            
            double *K = (double *)malloc(6 * 2 * sizeof(double));
            vDSP_mmulD(PH_trans, 1, HPH_R_inv, 1, K, 1, 6, 2, 2);
            
            free(HP);
            free(HPH_trans);
            free(HPH_t_R);
            free(PH_trans);
            
            // Calculate X
            double *HX = (double *)malloc(2 * 1 * sizeof(double));
            vDSP_mmulD(_H, 1, _X, 1, HX, 1, 2, 1, 6);
            
            double *Y_HX = (double *)malloc(2 * 1 * sizeof(double));
            Y_HX[0] = point.x - HX[0];
            Y_HX[1] = point.y - HX[1];
            
            double *K_Y_HX = (double *)malloc(6 * 1 * sizeof(double));
            vDSP_mmulD(K, 1, Y_HX, 1, K_Y_HX, 1, 6, 1, 2);
            
            double dist = sqrt(pow(K_Y_HX[0], 2) + pow(K_Y_HX[1], 2));
            
            if (dist >= 1.5) {
                free(HX);
                free(Y_HX);
                free(K_Y_HX);
                return;
            }
            
            for (int i = 0; i < 6; i++) {
                _X[i] = _X[i] + K_Y_HX[i];
            }
            
            free(HX);
            free(Y_HX);
            free(K_Y_HX);
            
            // Calculate P
            double *KH = (double *)malloc(6 * 6 * sizeof(double));
            vDSP_mmulD(K, 1, _H, 1, KH, 1, 6, 6, 2);
            
            double *I_KH = (double *)malloc(6 * 6 * sizeof(double));
            for (int i = 0; i <36; i++) {
                I_KH[i] = _I66[i] - KH[i];
            }
            
            double *new_P = (double *)malloc(6 * 6 * sizeof(double));
            vDSP_mmulD(I_KH, 1, _P, 1, new_P, 1, 6, 6, 6);
            
            for (int i = 0; i < 36; i++) {
                _P[i] = new_P[i];
            }
            
            free(KH);
            free(I_KH);
            free(new_P);
            free(K);
        } else {
            _X[0] = point.x;
            _X[1] = point.y;
            
            _started = YES;
        }
    }
    
    _consecutiveTimeUpdate = 0;
}

- (void)initializeConstants {
    
    // H
    bzero(_H, 2 * 6 * sizeof(double));
    _H[0] = _H[7] = 1;
    
    // H transpose
    vDSP_mtransD(_H, 1, _H_trans, 1, 6, 2);
    
    // A
    for (int i = 0; i < 36; i++) {
        int x = i / 6;
        int y = i % 6;
        
        if (x == y) {
            _A[i] = 1;
        } else if (x+2 == y) {
            _A[i] = _updateInterval;
        } else if (x+4 == y) {
            _A[i] = (_updateInterval * _updateInterval) / 2;
        } else {
            _A[i] = 0;
        }
    }
    
    // A transpose
    vDSP_mtransD(_A, 1, _A_trans, 1, 6, 6);
    
    // Q
    for (int i = 0; i < 36; i++) {
        int x = i / 6;
        int y = i % 6;
        
        if (x == y) {
            _Q[i] = 0.1;
        } else {
            _Q[i] = 0;
        }
    }
    
    // R
    for (int i = 0; i < 4; i++) {
        int x = i / 2;
        int y = i % 2;
        
        if (x == y) {
            _R[i] = 0.01;
        } else {
            _R[i] = 0;
        }
    }
    
    // I66
    for (int i = 0; i < 36; i++) {
        int x = i/6;
        int y = i%6;
        
        if (x == y) {
            _I66[i] = 1;
        } else {
            _I66[i] = 0;
        }
    }   
}

- (void)resetValues {
    
    // X
    _X[0] = _X[1] = 0;
    _X[2] = _X[3] = 0.5;
    _X[4] = _X[5] = 0;
    
    // P
    for (int i = 0; i< 36; i++) {
        if (i % 7 == 0) {
            _P[i] = 1;
        } else {
            _P[i] = 0;
        }
    }
}

- (void)dataCollected:(int)count {
    // do nothing
}

- (void)counterRead:(double)count {
    
}

- (void)atRestWithYTMotionDetector:(YTMotionDetector *)detector {
    _ignoreTimeUpdate = YES;
}

- (void)inMotionWithYTMotionDetector:(YTMotionDetector *)detector {
    _ignoreTimeUpdate = NO;
}


@end
