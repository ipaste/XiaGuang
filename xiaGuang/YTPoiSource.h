//
//  YTPoiSource.h
//  HighGuang
//
//  Created by Yuan Tao on 10/17/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTPoi.h"

@protocol YTPoiSource <NSObject>
-(YTPoi *)producePoi;
@end
