//
//  YTCurrentParkingButton.h
//  xiaGuang
//
//  Created by YunTop on 14/10/31.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YTCurrentParkingButton;
@protocol YTCurrentParkingDelegate <NSObject>
@optional
-(void)moveCurrentParkingPositionClicked;
@end

@interface YTCurrentParkingButton : UIButton
@property (weak,nonatomic) id<YTCurrentParkingDelegate> delegate;
@end
