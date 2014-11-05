//
//  YTSwitchBlockView.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-11.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMajorArea.h"
@class YTSwitchBlockView;
@protocol YTSwitchBlockDelegate <NSObject>
-(void)switchBlock:(id<YTBlock>)block;
@end

@interface YTSwitchBlockView : UIView
@property (weak,nonatomic) id<YTSwitchBlockDelegate> delegate;
@property (nonatomic) BOOL toggle;

-(void)redrawWithMajorArea:(id<YTMajorArea>)majorArea;
-(instancetype)initWithPosition:(CGPoint)position currentMajorArea:(id <YTMajorArea>)majorArea;
-(void)promptBlockChange:(id<YTBlock>)block;
-(void)toggleBlockView;
@end
