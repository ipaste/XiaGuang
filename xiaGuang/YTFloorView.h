//
//  YTFloorView.h
//  High逛
//
//  Created by Ke ZhuoPeng on 14-8-14.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTFloor.h"
@class YTFloorView;
@protocol YTFloorViewDelegate <NSObject>
-(void)floorView:(YTFloorView *)floorView clickButtonAtFloor:(id <YTFloor>)floor;
@end

@interface YTFloorView : UITableView
@property(strong,nonatomic) id <YTFloor> curFloor;
@property(weak,nonatomic)id<YTFloorViewDelegate> floorDelegate;
-(id)initWithFrame:(CGRect)frame andItem:(NSArray *)item;
@end
