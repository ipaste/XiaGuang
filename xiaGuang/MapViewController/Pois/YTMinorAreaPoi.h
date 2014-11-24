//
//  YTMinorAreaPoi.h
//  虾逛
//
//  Created by Yuan Tao on 11/24/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTPoi.h"
#import "YTMinorArea.h"
#import "YTMinorAreaAnnotation.h"
@interface YTMinorAreaPoi : YTPoi

-(id)initWithMinorArea:(id<YTMinorArea>)serviceStation;

@end