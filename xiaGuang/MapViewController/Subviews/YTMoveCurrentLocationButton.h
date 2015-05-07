//
//  YTMoveCurrentLocationButton.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-15.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YTMoveCurrentLocationButton;
@protocol YTMoveCurrentLocationDelegate
-(void)moveToUserLocationButtonClicked;
@end

@interface YTMoveCurrentLocationButton : UIButton
@property (weak,nonatomic) id< YTMoveCurrentLocationDelegate> delegate;
-(void)promptFloorChange:(NSString *)floorName;
@end
