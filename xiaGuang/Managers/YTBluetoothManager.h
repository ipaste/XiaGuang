//
//  YTBluetoothManager.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-20.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void(^YTBluetoothCallBack)(BOOL isOpen);

@interface YTBluetoothManager : NSObject

+(instancetype)shareBluetoothManager;
-(void)refreshBluetoothState;
-(void)refreshBluetoothStateForCallBack:(YTBluetoothCallBack)callback;

extern NSString *const YTBluetoothStateHasChangedNotification;
@end
