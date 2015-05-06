//
//  PositionBot.h
//  Positioning
//
//  Created by Meng Hu on 10/21/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "YTDistanceData.h"

@interface YTPositionBot : NSObject

- (NSValue *)locateMeWithDistances:(NSArray *)distances
                          accuracy:(double)accuracy;

@end
