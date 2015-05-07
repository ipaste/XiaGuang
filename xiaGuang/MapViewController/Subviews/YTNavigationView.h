//
//  YTNavigationView.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-4.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTNavigationModePlan.h"
@class YTNavigationView;
@protocol YTNavigationDelegate <NSObject>
-(void)stopNavigationMode;
-(void)jumToUserFloor;
@end
@interface YTNavigationView : UIView
@property (assign,nonatomic) BOOL isNavigating;
@property (assign,nonatomic) BOOL isCancelling;
@property (assign,nonatomic) BOOL isShowSwitchButton;
@property (weak,nonatomic) id<YTNavigationDelegate> delegate;
@property (weak,nonatomic) YTNavigationModePlan *plan;

-(void)startNavigationAndSetDestination:(id<YTPoiSource>)poiSource;
-(void)updateInstruction;
-(void)stopNavigationMode;

@end
