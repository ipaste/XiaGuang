//
//  YTDataManager.m
//  虾逛
//
//  Created by Silence on 15/4/16.
//  Copyright (c) 2015年 Silence. All rights reserved.
//

#import "YTDataManager.h"

#define DEVICE_IDENTIFIER [[[UIDevice currentDevice] identifierForVendor] UUIDString]
#define DOCUMENT_PATH NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject
#define USER_PATH [DOCUMENT_PATH stringByAppendingPathComponent:@".user"]
#define MAP_PATH [DOCUMENT_PATH stringByAppendingPathComponent:@".map"]
#define DB_PATH [USER_PATH stringByAppendingPathComponent:@"highGuangDB"]
#define USERDB_PATH [USER_PATH stringByAppendingPathComponent:@"_user"]
#define DATAUPDATA_PATH [DOCUMENT_PATH stringByAppendingPathComponent:@".update"]
#define MAX_FILESIZE 500

NSString *const KWifiNetworkKey= @"WIFI";
NSString *const KWwanNetworkKey = @"2G/3G/4G";
NSString *const KNoNetworkKey = @"No Network";
NSString *const kUploadKey = @"DataUpload";

@interface YTDataManager(){
    Reachability *_reachability;
    NetworkStatus _currentNetworkStatus;
    FMDatabase *_tmpDatabase;
    FMDatabase *_tmpUserDatabase;
    NSFileManager *_fileManager;
    NSString *_date;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)url;
@end

@implementation YTDataManager

- (FMDatabase *)database {
    return _tmpDatabase;
}

- (FMDatabase *)userDatebase {
    return _tmpUserDatabase;
}

- (NSString *)documentMapPath {
    return MAP_PATH;
}

+ (instancetype)defaultDataManager{
    static YTDataManager *dataManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[YTDataManager alloc]init];
    });
    return dataManager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        _date = [formatter stringFromDate:date];
        
        // Network Status
        _reachability = [Reachability reachabilityWithHostname:@"www.leancloud.cn"];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
        [_reachability startNotifier];
        
        BOOL isConfig = false;
        
        _fileManager = [NSFileManager defaultManager];
        if (![_fileManager fileExistsAtPath:USER_PATH]) {
            [_fileManager createDirectoryAtPath:USER_PATH withIntermediateDirectories:true attributes:nil error:nil];
            NSString *bundleDB = [[NSBundle mainBundle]pathForAuxiliaryExecutable:@"highGuangDB"];
            [_fileManager copyItemAtPath:bundleDB toPath:DB_PATH error:nil];
            isConfig = true;
        }
        
        if (![_fileManager fileExistsAtPath:MAP_PATH]) {
            [_fileManager createDirectoryAtPath:MAP_PATH withIntermediateDirectories:true attributes:nil error:nil];
        }
        
        if (![_fileManager fileExistsAtPath:DATAUPDATA_PATH]) {
            [_fileManager createDirectoryAtPath:DATAUPDATA_PATH withIntermediateDirectories:true attributes:nil error:nil];
        }
        
        _tmpDatabase = [FMDatabase databaseWithPath:DB_PATH];
        _tmpUserDatabase = [FMDatabase databaseWithPath:USERDB_PATH];
        
        [_tmpDatabase open];
        [_tmpUserDatabase open];
        
        if (isConfig) {
            NSOperation *config = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(firstConfig) object:nil];
            [config start];
        }
        
        double fileSize = [[_fileManager attributesOfItemAtPath:USERDB_PATH error:nil] fileSize] / 1024;
        
        if (_reachability.currentReachabilityStatus == ReachableViaWiFi || fileSize < MAX_FILESIZE) {
           [self checkWhetherTheDataNeedsToBeUpload];
        }
        
        [self checkWhetherTheDataNeedsToBeUpdated];
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:MAP_PATH]];
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DATAUPDATA_PATH]];
    }
    return self;
}

- (void)closeAllDatebase{
    [_tmpDatabase close];
    [_tmpUserDatabase close];
}

- (void)checkWhetherTheDataNeedsToBeUpdated{
    FMResultSet *result = [_tmpDatabase executeQueryWithFormat:@"SELECT * FROM Config"];
    [result next];
    int version = [result intForColumn:@"version"];
    AVQuery *updateQuery = [AVQuery queryWithClassName:@"DataUpdate"];
    [updateQuery orderByAscending:@"version"];
    [updateQuery whereKey:@"version" greaterThan:[NSNumber numberWithInt:version]];
    [updateQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (AVObject *data in objects) {
                AVFile *file = data[@"file"];
                NSNumber *version = data[@"version"];
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    NSString *datePath = [NSString stringWithFormat:@"%@/update_%@.plist",DATAUPDATA_PATH,version];
                    [data writeToFile:datePath atomically:true];
                }];
            }
        }
    }];
}

- (void)checkWhetherTheDataNeedsToBeUpload{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults valueForKey:kUploadKey]) {
        [userDefaults setValue:_date forKey:kUploadKey];
        [userDefaults synchronize];
    }else{
        NSString *oldDate = [userDefaults valueForKey:kUploadKey];
        if (![oldDate isEqualToString:_date]) {
            AVFile *userFile = [AVFile fileWithName:[NSString stringWithFormat:@"%@",_date] contentsAtPath:USERDB_PATH];
            AVObject *object = [AVObject objectWithClassName:@"UserInfo"];
            object[@"file"] = userFile;
            object[@"ifa"] = DEVICE_IDENTIFIER;
            [object saveInBackground];
            [userDefaults setValue:_date forKey:kUploadKey];
            [userDefaults synchronize];
        }
    }
}

- (void)networkStatusChanged:(NSNotification *)notification{
    NetworkStatus status = _reachability.currentReachabilityStatus;
    YTNetworkSatus networkStatus = YTNetworkSatusNotNomal;
    if (_tmpUserDatabase) {
        NSString *statusString = nil;
        NSNumber *count = nil;
        switch (status) {
            case ReachableViaWiFi:
            {
                //WIFI
                statusString = KWifiNetworkKey;
                FMResultSet *result = [_tmpUserDatabase executeQueryWithFormat:@"SELECT * FROM NetworkInfo WHERE status = %@",statusString];
                if ([result next]) {
                    count = [NSNumber numberWithInt:[result intForColumn:@"count"] + 1];
                }
                networkStatus = YTNetworkSatusWifi;
            }
                break;
            case ReachableViaWWAN:
            {
                //WWAN
                statusString = KWwanNetworkKey;
                FMResultSet *result = [_tmpUserDatabase executeQueryWithFormat:@"SELECT * FROM NetworkInfo WHERE status = %@",statusString];
                if ([result next]) {
                    count = [NSNumber numberWithInt:[result intForColumn:@"count"] + 1];
                }
                networkStatus = YTNetworkSatusWWAN;
            }
                break;
            case NotReachable:
            {
                //NO NETWORK
                statusString = KNoNetworkKey;
                FMResultSet *result = [_tmpUserDatabase executeQueryWithFormat:@"SELECT * FROM NetworkInfo WHERE status = %@",statusString];
                if ([result next]) {
                    count = [NSNumber numberWithInt:[result intForColumn:@"count"] + 1];
                }
                networkStatus = YTNetworkSatusNotNomal;
            }
                break;
        }
        [_tmpUserDatabase executeUpdateWithFormat:@"UPDATE NetworkInfo SET count = %@ WHERE status = %@",count,statusString];
        if ([_delegate respondsToSelector:@selector(networkStatusChanged:)]) {
            [_delegate networkStatusChanged:networkStatus];
        }
    }
}
- (YTNetworkSatus)currentNetworkStatus{
    YTNetworkSatus networkStatus = YTNetworkSatusNotNomal;
    NetworkStatus status = _reachability.currentReachabilityStatus;
    switch (status) {
        case ReachableViaWWAN:
            networkStatus = YTNetworkSatusWWAN;
            break;
        case ReachableViaWiFi:
            networkStatus = YTNetworkSatusWifi;
            break;
        case NotReachable:
            networkStatus = YTNetworkSatusNotNomal;
    }
    return networkStatus;
}

- (void)firstConfig {
    NSString *sql = @"CREATE TABLE MallInfo('identify' INTEGER NOT NULL PRIMARY KEY,'name' TEXT,'count' INTERGER,'comment' TEXT)";
    [_tmpUserDatabase executeUpdate:sql];
    
    sql = @"CREATE TABLE MerchantInfo('identify' INTEGER NOT NULL PRIMARY KEY,'name' TEXT,'count' INTERGER,'comment' TEXT)";
    [_tmpUserDatabase executeUpdate:sql];
    
    sql = @"CREATE TABLE BeaconInfo('identify' TEXT NOT NULL PRIMARY KEY,'power' TEXT,'date' TEXT)";
    [_tmpUserDatabase executeUpdate:sql];
    
    sql = @"CREATE TABLE LocationInfo('identify' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'latitude' REAL,'longitude' REAL,'isNearMall' INTEGER,'date' TEXT,UNIQUE (\"identify\" ASC))";
    [_tmpUserDatabase executeUpdate:sql];
    
    sql = @"CREATE TABLE NetworkInfo('status' TEXT PRIMARY KEY,'count' INTERGER,'comment' TEXT)";
    [_tmpUserDatabase executeUpdate:sql];
    
    NSArray *netWorkStatus = @[KWifiNetworkKey,KWwanNetworkKey,KNoNetworkKey];
    NSArray *comment = @[@"使用WIFI的次数",@"使用普通网络的次数",@"不使用网络的次数"];
    
    sql = @"INSERT INTO NetworkInfo(status,count,comment) VALUES (?,?,?)";
    for (int index = 0; index < 3; index++){
        [_tmpUserDatabase executeUpdate:sql withArgumentsInArray:@[netWorkStatus[index],@0,comment[index]]];
    }
}

//跳过云备份
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)url{
    if (url != nil){
        assert([[NSFileManager defaultManager] fileExistsAtPath:[url path]]);
        NSError *error = nil;
        BOOL success = [url setResourceValue:[NSNumber numberWithBool:true] forKey:NSURLIsExcludedFromBackupKey error:&error];
        if (!success) {
            NSLog(@"错误信息:%@",error);
        }
        return success;
    }
    return false;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
