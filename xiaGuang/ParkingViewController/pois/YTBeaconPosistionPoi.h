//
//  YTBeaconPosistionPoi.h
//  xiaGuang
//
//  Created by YunTop on 14/11/6.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTPoi.h"
#import "YTBeaconAnnotation.h"
@interface YTBeaconPosistionPoi : YTPoi
-(instancetype)initWithParkingMarkCoordinat:(CLLocationCoordinate2D)coord minor:(id<YTMinorArea>)minorArea;
@end
