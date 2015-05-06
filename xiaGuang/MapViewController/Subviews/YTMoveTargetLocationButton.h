//
//  YTMoveTargetLocationButton.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-16.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YTMoveTargetLocationButton;
@protocol YTMoveTargetLocationDelegate
-(void)moveToTargetLocationButtonClicked;
@end

@interface YTMoveTargetLocationButton : UIButton
@property (weak,nonatomic) id< YTMoveTargetLocationDelegate> delegate;
@end
