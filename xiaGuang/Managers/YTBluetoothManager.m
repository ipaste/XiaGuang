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
    NSRunLoop *_runLoop;
    NSTimer *_timer;
    BOOL _isEnterBackground;
    BOOL _isOpen;
    BOOL _isFirst;
    BOOL _curBlueState;
    BOOL _isReceivedMessage;
}
@end
@implementation YTBluetoothManager
+(instancetype)shareBluetoothManager{
    static YTBluetoothManager *bluetoothManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bluetoothManager = [[YTBluetoothManager alloc]init];
    });
    [bluetoothManager refreshBluetoothState];
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
        _isFirst = true;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        _isReceivedMessage = YES;
    }
    return self;
}
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    if (!_isEnterBackground && _isReceivedMessage) {
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        BOOL curState = central.state == CBCentralManagerStatePoweredOff ? NO : YES;
        _curBlueState = curState;
        if (_isOpen != curState || _isFirst == true) {
            _isReceivedMessage = NO;
            _isFirst = false;
            _isOpen = curState;
        
           _timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(postBluetoothSate) userInfo:nil repeats:NO];
            
        }
    }
}


-(void)enterBackground:(NSNotification *)notification{
    _isEnterBackground = YES;
}

-(void)enterForeground:(NSNotification *)notification{
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(enterForegroundAfterZeroPointTwoSeconds:) userInfo:nil repeats:NO];
}

-(void)postBluetoothSate{
    BOOL curState = _centralManager.state == CBCentralManagerStatePoweredOff ? NO : YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:YTBluetoothStateHasChangedNotification object:nil userInfo:@{@"isOpen":curState ? @YES:@NO}];
    _isReceivedMessage = YES;
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)enterForegroundAfterZeroPointTwoSeconds:(NSTimer *)timer{
    BOOL curState = _centralManager.state == CBCentralManagerStatePoweredOff ? NO : YES;
    _isEnterBackground = NO;
    if (_curBlueState != curState) {
        [[NSNotificationCenter defaultCenter]postNotificationName:YTBluetoothStateHasChangedNotification object:nil userInfo:@{@"isOpen":curState ? @YES:@NO}];
        [timer invalidate];
    }
}

-(void)dealloc{
    [_runLoop cancelPerformSelectorsWithTarget:self];
}
@end
