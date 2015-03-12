//
//  YTMotionDetector.m
//  Bee
//
//  Created by Meng Hu on 10/28/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import "YTMotionDetector.h"

#import "YTNaiveStepDetector.h"
#import "YTDecayingCounter.h"

@interface YTMotionDetector() <YTNaiveStepDetectorDelegate> {
    YTDecayingCounter *_counter;
    YTNaiveStepDetector *_stepCounter;
    
    double _godNumber;
    double _lastPtWeight;
    
    double _threshold;
    int _inMotion;
    
    NSOperationQueue *_transitionQueue;
    NSTimer *_timer;
}

- (void)detectMotion;

@end

@implementation YTMotionDetector

- (instancetype)init
{
    self = [super init];
    if (self) {
        _counter = [[YTDecayingCounter alloc] initWithHalflife:0.5];
        _stepCounter = [[YTNaiveStepDetector alloc] init];
        _stepCounter.delegate = self;
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(detectMotion)
                                       userInfo:nil
                                        repeats:YES];
        
        _godNumber = 0;
        _lastPtWeight = 0.9;
        _threshold = 1.0;
        _inMotion = NO;
        
        _transitionToMotinoDelay = 0.0;
        _transitionToAtRestDelay = 0.0;
        
        _transitionQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)start {
    [_counter setVal:0];
    [_stepCounter start];
}

- (void)stop {
    
    [_timer invalidate];
    [_stepCounter stop];
    
}

- (void)detectStep {
    [_counter increment];
}

- (void)setDelegate:(id<YTMotionDetectorDelegate>)delegate {
    [delegate atRestWithYTMotionDetector:self];
    _delegate = delegate;
}

- (void)detectMotion {
    double val = [_counter getVal];
    
    _godNumber = _lastPtWeight * _godNumber + (1 - _lastPtWeight) * val;
    
    if (_godNumber >= _threshold) {
        if (!_inMotion) {
            _inMotion = YES;
            __weak YTMotionDetector *pt = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate inMotionWithYTMotionDetector:pt];
            });
        }
    } else {
        if (_inMotion) {
           _inMotion = NO;
            __weak YTMotionDetector *pt = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate atRestWithYTMotionDetector:pt];
            });
        }
    }
}


@end
