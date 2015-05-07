//
//  YTBlockView.h
//  虾逛
//
//  Created by YunTop on 14/12/31.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTBlock.h"
@class YTBlockView;
@protocol YTBlockViewDelegate <NSObject>
-(void)blockView:(YTBlockView *)blockView clickButtonAtBlock:(id <YTBlock>)block;
@end

@interface YTBlockView : UITableView
@property(strong,nonatomic) id <YTBlock> curBlock;
@property(weak,nonatomic)id<YTBlockViewDelegate> blockDelegate;
-(id)initWithFrame:(CGRect)frame andItem:(NSArray *)item;
@end
