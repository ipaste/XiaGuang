//
//  YTDecayingCounter.m
//  Bee
//
//  Created by Meng Hu on 10/28/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import "YTDecayingCounter.h"

@interface YTDecayingCounter() {
    double _value;
    double _time;
    double _tau;
}

- (void)update;

@end

@implementation YTDecayingCounter

- (id)initWithHalflife:(double) halfLife {
    return [self initWithHalflife:halfLife initialVal:0];
}

- (id)initWithHalflife:(double)halfLife
            initialVal:(double)value {
    self = [super init];
    if (self) {
        _tau = halfLife / log(2.0);
        [self setVal:value];
    }
    return self;      
}

- (double)getVal {
    [self update];
    return _value;
}

- (double)increment {
    [self update];
    _value++;
    return _value;
}

- (void)setVal:(double)value {
    _value = value;
    _time = [[NSDate date] timeIntervalSince1970];
}

- (void)update {
    double now = [[NSDate date] timeIntervalSince1970];
    double diff = now - _time;
    if (diff > 0) {
        _value *= exp(-diff / _tau);
    }
    _time = now;
}

@end
