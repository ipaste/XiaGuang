//
//  YTBeacons.h
//  HighGuang
//
//  Created by Yuan Tao on 8/5/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ESTBeacon.h>
#import "YTMinorArea.h"

@protocol YTBeacon <NSObject>

@property (nonatomic,weak) NSString *identifier;
@property (nonatomic,weak) NSNumber *major;
@property (nonatomic,weak) NSNumber *minor;
@property (nonatomic,weak) id<YTMinorArea> minorArea;


@end
