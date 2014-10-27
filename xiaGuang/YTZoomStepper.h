//
//  YTZoomSteeper.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-8-13.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YTZoomStepper;
@protocol YTZoomStepperDelegate <NSObject>
-(void)increasing;
-(void)diminishing;
@end

@interface YTZoomStepper : UIControl
@property(weak,nonatomic)id <YTZoomStepperDelegate> delegate;
@end


