//
//  YTNavigationInstruction.h
//  HighGuang
//
//  Created by Yuan Tao on 8/26/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTNavigationInstruction : NSObject

typedef NS_ENUM(NSInteger, YTNavigationInstructionType) {
    YTNavigationInstructionDifferentFloor,
    YTNavigationInstructionSameFloor,
    YTNavigationInstructionApproachingElevator,
    YTNavigationInstructionApproachingDestination
};

@property (nonatomic,assign) YTNavigationInstructionType type;
@property (nonatomic,assign) NSString *mainInstruction;
@property (nonatomic,assign) NSString *leftInstruction;
@property (nonatomic,assign) NSString *rightInstruction;

@end
