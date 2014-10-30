//
//  YTDetailsView.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-8-15.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMerchantLocation.h"
#import "YTLocalMerchantInstance.h"
@class YTDetailsView;
@protocol YTDetailsDelegate <NSObject>
-(void)navigatingToPoiSourceClicked:(id<YTPoiSource>)source;
@end

@interface YTDetailsView : UIView
@property(weak,nonatomic)id <YTDetailsDelegate> delegate;
-(void)setCommonPoi:(id<YTPoiSource>)poi;
@end
