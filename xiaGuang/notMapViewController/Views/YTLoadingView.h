//
//  YTLoadingView.h
//  虾逛
//
//  Created by YunTop on 14/12/2.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTLoadingView : UIView
-(instancetype)initWithPosistion:(CGPoint)position;
-(void)start;
-(void)stop;
@end
