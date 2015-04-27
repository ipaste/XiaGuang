//
//  YTMultipleMerchantView.h
//  虾逛
//
//  Created by YunTop on 14/12/2.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTDataManager.h"
#import "YTLocalMerchantInstance.h"
@class YTMultipleMerchantView;
@protocol YTMultipleMerchantDelegate <NSObject>

-(void)selectToMerchantInstance:(id<YTMerchantLocation>)merchantInstance;

@end

@interface YTMultipleMerchantView : UIView<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) BOOL isShow;

-(instancetype)initWithUniIds:(NSArray *)uniIds delegate:(id<YTMultipleMerchantDelegate>)delegate;
-(void)showInView:(UIView *)superView;
-(void)hide;
@end
