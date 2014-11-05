//
//  YTBluetoothManager.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-20.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
typedef void(^YTBluetoothCallBack)(BOOL isOpen);

@interface YTBluetoothManager : NSObject<CBCentralManagerDelegate,CLLocationManagerDelegate>
@property (strong,nonatomic)CLLocationManager *locationManager;
+(instancetype)shareBluetoothManager;
-(void)refreshBluetoothState;
-(void)refreshBluetoothStateForCallBack:(YTBluetoothCallBack)callback;

extern NSString *const YTBluetoothStateHasChangedNotification;
@end
