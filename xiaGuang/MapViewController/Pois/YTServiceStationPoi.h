//
//  YTServiceStationPoi.h
//  xiaGuang
//
//  Created by Yuan Tao on 11/7/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTPoi.h"
#import "YTServiceStation.h"
#import "YTServiceStationAnnotation.h"
@interface YTServiceStationPoi : YTPoi

-(id)initWithServiceStation:(id<YTServiceStation>)serviceStation;

@end