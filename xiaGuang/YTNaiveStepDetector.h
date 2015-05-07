//
//  YTPedometer.h
//  Bee
//
//  Created by Meng Hu on 10/28/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YTNaiveStepDetectorDelegate <NSObject>

- (void)detectStep;

@end

@interface YTNaiveStepDetector : NSObject

@property (nonatomic, weak) id<YTNaiveStepDetectorDelegate> delegate;

- (void)start;
- (void)stop;

@end
