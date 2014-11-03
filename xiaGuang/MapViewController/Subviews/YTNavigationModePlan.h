//
//  YTNavigationModePlan.h
//  HighGuang
//
//  Created by Yuan Tao on 8/22/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTMerchantLocation.h"
#import "YTMajorArea.h"
#import "YTMinorArea.h"
#import "YTNavigationInstruction.h"

@interface YTNavigationModePlan : NSObject

@property (nonatomic,weak) id<YTPoiSource> targetPoiSource;
@property (nonatomic,weak) id<YTMajorArea> displayMajorArea;
@property (nonatomic,weak) id<YTMinorArea> userMinorArea;

-(id)initWithTargetPoiSource:(id<YTPoiSource>)poiSource;
-(void)updateWithCurrentUserMinorArea:(id<YTMinorArea>)userMinor
                andDisplayedMajorArea:(id<YTMajorArea>)displayMajorArea;
-(YTNavigationInstruction *)getInstruction;

@end
