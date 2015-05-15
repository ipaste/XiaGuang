//
//  YTNavigationModePlan.m
//  HighGuang
//
//  Created by Yuan Tao on 8/22/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTNavigationModePlan.h"

@implementation YTNavigationModePlan

-(id)initWithTargetPoiSource:(id<YTPoiSource>)poiSource{
    self = [super init];
    if(self != nil){
        self.targetPoiSource = poiSource;
    }
    return self;
}

-(void)updateWithCurrentUserMinorArea:(id<YTMinorArea>)userMinor
                       distanceToTarget:(double)distance
                andDisplayedMajorArea:(id<YTMajorArea>)curDisplayMajorArea{
    
    self.distanceToTarget = distance;
    self.userMinorArea = userMinor;
    self.displayMajorArea = curDisplayMajorArea;
    
}

-(YTNavigationInstruction *)getInstruction{
    YTNavigationInstruction *instrunction;
    if([[[_userMinorArea majorArea] identifier] isEqualToString:[[self.targetPoiSource majorArea] identifier]]){
        
        instrunction = [[YTNavigationInstruction alloc] init];
        instrunction.type = YTNavigationInstructionSameFloor;
        instrunction.mainInstruction = @"请行至目标";
        instrunction.rightInstruction = @"您与终点在同一楼层";
        
        if(self.distanceToTarget < 15)
        {
            instrunction = [[YTNavigationInstruction alloc] init];
            instrunction.type = YTNavigationInstructionApproachingDestination;
            instrunction.mainInstruction = @"你已经到达终点";
            instrunction.rightInstruction = @"您与终点在同一楼层";
        }
        
    }
    else{
        instrunction = [[YTNavigationInstruction alloc] init];
        instrunction.type = YTNavigationInstructionDifferentFloor;
        instrunction.mainInstruction = @"请乘坐电梯";
        instrunction.leftInstruction = [NSString stringWithFormat:@"你在%@",[[[_userMinorArea majorArea] floor] floorName]];
        instrunction.rightInstruction = [NSString stringWithFormat:@"终点在%@",[[[_targetPoiSource majorArea] floor] floorName]];
       
        
    }
    
    
    
    return instrunction;
}

@end
