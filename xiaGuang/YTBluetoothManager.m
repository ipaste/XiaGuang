//
//  YTBluetoothManager.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-20.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTBluetoothManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
NSString *const YTBluetoothStateHasChangedNotification = @"TBluetoothStateHasChanged";
@interface YTBluetoothManager ()<CBCentralManagerDelegate>{
    CBCentralManager *_centralManager;
    NSTimer *_timer;
    BOOL _isEnterBackground;
    BOOL _isOpen;
    BOOL _isFirst;
    BOOL _curBlueState;
}
@end
@implementation YTBluetoothManager
+(instancetype)shareBluetoothManager{
    static YTBluetoothManager *bluetoothManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bluetoothManager = [[YTBluetoothManager alloc]init];
    });
    return bluetoothManager;
}

-(void)refreshBluetoothState{
    BOOL curState = _centralManager.state == CBCentralManagerStatePoweredOff ? NO : YES;
   [[NSNotificationCenter defaultCenter]postNotificationName:YTBluetoothStateHasChangedNotification object:nil userInfo:@{@"isOpen":curState ? @YES:@NO}];
}
-(void)refreshBluetoothStateForCallBack:(YTBluetoothCallBack)callback{
    BOOL curState = _centralManager.state == CBCentralManagerStatePoweredOff ? NO : YES;
    callback(curState);
}
-(instancetype)init{
    self = [super init];
    if (self) {
        _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        _isFirst = false;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
    }
    return self;
}
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (!_isEnterBackground) {
        BOOL curState = central.state == CBCentralManagerStatePoweredOff ? NO : YES;
        _curBlueState = curState;
        if (_isOpen != curState || _isFirst == false) {
            _isFirst = true;
            central.delegate = nil;
            _isOpen = curState;
            if (_timer == nil) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(setCenterDelegate:) userInfo:nil repeats:NO];
            }
            
        }
    }
}


-(void)enterBackground:(NSNotification *)notification{
    _isEnterBackground = YES;
}

-(void)enterForeground:(NSNotification *)notification{
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(enterForegroundAfterZeroPointTwoSeconds:) userInfo:nil repeats:NO];
}

-(void)setCenterDelegate:(NSTimer *)timer{
    [timer invalidate];
    _timer = nil;
    BOOL curState = _centralManager.state == CBCentralManagerStatePoweredOff ? NO : YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:YTBluetoothStateHasChangedNotification object:nil userInfo:@{@"isOpen":curState ? @YES:@NO}];
    _centralManager.delegate = self;
}

-(void)enterForegroundAfterZeroPointTwoSeconds:(NSTimer *)timer{
    BOOL curState = _centralManager.state == CBCentralManagerStatePoweredOff ? NO : YES;
    if (_curBlueState != curState) {
        [[NSNotificationCenter defaultCenter]postNotificationName:YTBluetoothStateHasChangedNotification object:nil userInfo:@{@"isOpen":curState ? @YES:@NO}];
        _isEnterBackground = NO;
        [timer invalidate];
    }
}



@end
