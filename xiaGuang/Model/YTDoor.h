//
//  YTDoor.h
//  虾逛
//
//  Created by Yuan Tao on 12/15/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTPoiSource.h"

@protocol YTDoor <NSObject>

@property (nonatomic,weak) NSString *identifier;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;

@end