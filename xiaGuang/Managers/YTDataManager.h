//
//  YTDataManager.h
//  虾逛
//
//  Created by Silence on 15/4/16.
//  Copyright (c) 2015年 Silence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>
#import "Reachability.h"
#import "FMDB.h"
#import "ESTBeacon.h"
#import "YTHandleCsv.h"
#import "zipzap.h"

typedef NS_ENUM(NSInteger, YTNetworkSatus) {
    YTNetworkSatusNotNomal = 0,
    YTNetworkSatusWifi,
    YTNetworkSatusWWAN
};

@class YTDataManager;

@protocol YTDataManagerDelegate <NSObject>

@optional
/**
 *  协议方法：监听网络状态发生改变
 *
 *  @param status 网络状态的枚举
 */
- (void)networkStatusChanged:(YTNetworkSatus)status;
@end

@interface YTDataManager : NSObject

@property (weak ,nonatomic)id<YTDataManagerDelegate> delegate;
@property (readonly ,nonatomic) FMDatabase *database;
@property (readonly ,nonatomic) NSString *mapPath;
@property (readonly ,nonatomic) NSString *documentMapPath;
@property (readonly ,nonatomic) NSString *date;
/**
 *  数据管理单例创建方法
 *
 *  @return 返回默认的数据管理对象
 */
+ (instancetype)defaultDataManager;

/**
 *  更新必要的数据
 */
- (void)updateCloudData;

/**
 *  处理已经下载的数据
 *
 *  @param data 下载在内存中的数据
 *  @param name 数据名称
 */
- (void)downloadedData:(NSData *)data dataName:(NSString *)name;

/**
 *  往收集用户信息库里面记录一个商家信息
 *
 *  @param merchant 商铺对象
 */
- (void)saveMerchantInfo:(id)merchant;

/**
 *  往收集用户信息库里面记录一个商城信息
 *
 *  @param mall 商城对象
 */
- (void)saveMallInfo:(id) mall;

/**
 *  往收集用户信息库里面记录一个位置信息
 *
 *  @param coord 经纬度坐标
 *  @param name  商城名字
 */
- (void)saveLocationInfo:(CLLocationCoordinate2D )coord
                    name:(NSString *)name;

/**
 *  往收集用户信息库里面记录一个Beacon的信息
 *
 *  @param beacon 扫描到的Beacon对象
 */
- (void)saveBeaconInfo:(ESTBeacon *)beacon;

/**
 *  刷新网络状态
 */
- (void)refreshNetWorkState;

/**
 *  获取当前网络状态
 *
 *  @return 返回一个网络状态的枚举
 */
- (YTNetworkSatus)currentNetworkStatus;

/**
 *  关闭所有链接的数据库
 */
- (void)closeAllDatebase;
@end
