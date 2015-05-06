//
//  DistanceData.h
//  Positioning
//
//  Created by Meng Hu on 10/21/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTDistanceData : NSObject

@property (nonatomic, readonly) double x;
@property (nonatomic, readonly) double y;
@property (nonatomic, readonly) double distance;

- (id)initWithLocationX:(double)x
                      y:(double)y
              distance:(double)distance;

@end
