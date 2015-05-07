//
//  YTBathroomPoi.h
//  HighGuang
//
//  Created by Yuan Tao on 10/22/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTPoi.h"
#import "YTBathroom.h"
#import "YTBathroomAnnotation.h"

@interface YTBathroomPoi : YTPoi

-(id)initWithBathroom:(id<YTBathroom>)bathroom;

@end
