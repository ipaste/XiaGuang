//
//  YTPoiButton.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-16.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YTPoiButton;
@protocol YTPoiDelegate <NSObject>

-(void)poiButtonClicked;

@end

@interface YTPoiButton : UIButton
@property (weak ,nonatomic) id <YTPoiDelegate> delegate;
@end
