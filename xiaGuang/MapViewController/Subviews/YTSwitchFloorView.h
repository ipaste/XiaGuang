//
//  YTSwitchFloorView.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-10.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMajorArea.h"
@class  YTSwitchFloorView;
@protocol YTSwitchFloorDelegate <NSObject>
-(void)switchFloor:(id<YTFloor>)floor;
@end

@interface YTSwitchFloorView : UIView
@property (weak, nonatomic) id<YTSwitchFloorDelegate> delegate;
@property (nonatomic)BOOL toggle;

-(id)initWithPosition:(CGPoint)position AndCurrentMajorArea:(id <YTMajorArea>)majorArea;
-(void)promptFloorChange:(id<YTFloor>)floor;
-(void)toggleFloor;
-(void)redrawWithMajorArea:(id<YTMajorArea>)majorArea;

@end
