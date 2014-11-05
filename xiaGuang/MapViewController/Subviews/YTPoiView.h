//
//  YTPoiView.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-10.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTCategory.h"
#import "YTCommonlyUsed.h"
#import "JWBlurView.h"

@class YTPoiView;
@protocol YTPoiViewDelegate <NSObject>

-(void)highlightTargetGroupOfPoi:(id)poiObject;

@end

@interface YTPoiView : UIView

@property (nonatomic,weak) id<YTPoiViewDelegate> delegate;
-(id)initWithShow:(BOOL)show;
-(void)deleteSelectedPoi;
-(void)show;
-(void)hide;
@end
