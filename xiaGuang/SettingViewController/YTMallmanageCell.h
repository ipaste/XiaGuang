//
//  YTMallmanageCell.h
//  虾逛
//
//  Created by Yuntop on 15/4/23.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMallDict.h"

typedef NS_ENUM(NSInteger, YTMallManageState) {
    YTMallManageStateUpdata = 0,
    YTMallManageStateDownload,
    YTMallManageStateDownloaded
};

@class YTMallmanageCell;
@protocol YTMallManageDelegate <NSObject>
- (void)mallManageCell:(YTMallmanageCell *)cell downloadMallData:(YTCloudMall *)mall;
@end

@interface YTMallmanageCell : UITableViewCell
@property (strong ,nonatomic) YTCloudMall *mall;
@property (weak ,nonatomic) id <YTMallManageDelegate> delegate;
@property (nonatomic) YTMallManageState state;

/**
 *  设置Cell进度条的数值
 *
 *  @param value 数值 范围在0 ~ 1之间
 */
- (void)setProgress:(NSInteger)value;
- (void)stopDownload;
@end
