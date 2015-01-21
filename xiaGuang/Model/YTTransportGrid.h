//
//  YTTransportGrid.h
//  虾逛
//
//  Created by Yuan Tao on 1/21/15.
//  Copyright (c) 2015 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTMall.h"
#import "YTMajorArea.h"
#import "YTEscalator.h"
#import "YTElevator.h"

@interface YTTransportGrid : NSObject

-(id)initWithBlock:(id<YTBlock>)block;

-(NSArray *)availableTransportFromMajorArea1:(id<YTMajorArea>)m1
                                toMajorArea2:(id<YTMajorArea>)m2;



@end
