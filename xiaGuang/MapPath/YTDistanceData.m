//
//  DistanceData.m
//  Positioning
//
//  Created by Meng Hu on 10/21/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import "YTDistanceData.h"

@interface YTDistanceData()

@property (nonatomic) double x;
@property (nonatomic) double y;
@property (nonatomic) double distance;

@end

@implementation YTDistanceData

- (id)initWithLocationX:(double)x
                      y:(double)y
               distance:(double)distance {
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
        _distance = distance;
    }
    return self;
}

@end
