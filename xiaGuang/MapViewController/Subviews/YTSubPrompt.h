//
//  YTSubPrompt.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-8-26.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMajorArea.h"
@class YTSubPrompt;
@protocol YTSubPromptDelegate <NSObject>
-(void)clickJumpToTarget;
@end

@interface YTSubPrompt : UIView
@property (assign,nonatomic) BOOL isShow;
@property (weak,nonatomic) NSString *floorName;
@property (weak,nonatomic) id<YTSubPromptDelegate> delegate;
-(void)subPromptShowAnimation;
-(void)subPromptHideAnimation;
@end
