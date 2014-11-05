//
//  YTParkingPoi.h
//  xiaGuang
//
//  Created by YunTop on 14/10/31.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTPoi.h"
#import "YTParkingCurrentAnnotation.h"
@interface YTParkingCurrentPoi : YTPoi
-(instancetype)initWithParkingCoordinat:(CLLocationCoordinate2D)coord;
@end
