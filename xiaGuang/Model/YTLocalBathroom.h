//
//  YTLocalBathroom.h
//  HighGuang
//
//  Created by Yuan Tao on 10/22/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTBathroom.h"
#import "YTLocalMajorArea.h"
#import "YTDataManager.h"
#import "YTBathroomPoi.h"

@interface YTLocalBathroom : NSObject<YTBathroom>

-(id)initWithDBResultSet:(FMResultSet *)findResultSet;

@end
