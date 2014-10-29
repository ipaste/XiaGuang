//
//  YTDetailsView.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-8-15.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMerchantLocation.h"
@class YTDetailsView;
@protocol YTDetailsDelegate <NSObject>
-(void)startNavigatingToMerchantLocation:(id<YTMerchantLocation>)merchantLocation;
@end

@interface YTDetailsView : UIView
@property(weak,nonatomic)id <YTDetailsDelegate> delegate;
-(void)setMerchantInfo:(id<YTMerchantLocation>)merchantLocation;
-(void)setCommonPoi:(id<YTPoiSource>)poi;
@end
