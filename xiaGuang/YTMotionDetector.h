//
//  YTMotionDetector.h
//  Bee
//
//  Created by Meng Hu on 10/28/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YTMotionDetector;

@protocol YTMotionDetectorDelegate <NSObject>

- (void)atRestWithYTMotionDetector:(YTMotionDetector *)detector;
- (void)inMotionWithYTMotionDetector:(YTMotionDetector *)detector;

- (void)counterRead:(double)count;

@end

@interface YTMotionDetector : NSObject

@property (nonatomic, weak) id<YTMotionDetectorDelegate> delegate;

@property (nonatomic) double transitionToAtRestDelay;

- (void)start;
- (void)stop;

@end
