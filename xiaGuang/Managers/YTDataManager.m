//
//  YTDataManager.m
//  虾逛
//
//  Created by Silence on 15/4/16.
//  Copyright (c) 2015年 Silence. All rights reserved.
//

#import "YTDataManager.h"
#import "YTMallDict.h"
#import "YTCloudMerchant.h"
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

/**
 *  更换数据库密码，使用正确的密码打开数据，然后再用ResetKey去修改
 */
NSString *const kDatabasePassword = @"WQNMLGDSBCNM";

@interface YTDataManager(){
    Reachability *_reachability;
    NetworkStatus _currentNetworkStatus;
    FMDatabase *_tmpDatabase;
    FMDatabase *_userDatabase;
    NSFileManager *_fileManager;
    NSString *_date;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)url;
@end

@implementation YTDataManager

- (FMDatabase *)database {
    return _tmpDatabase;
}

- (NSString *)documentMapPath {
    return MAP_PATH;
}

- (NSString *)date{
    return _date;
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
        _userDatabase = [FMDatabase databaseWithPath:USERDB_PATH];
        [_tmpDatabase open];
        [_userDatabase open];
        
        // 设置数据库密码
        // [_tmpDatabase setKey:kDatabasePassword];
        [_userDatabase setKey:kDatabasePassword];

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
    [_userDatabase close];
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
    if (_userDatabase) {
        NSString *statusString = nil;
        NSNumber *count = nil;
        switch (status) {
            case ReachableViaWiFi:
            {
                //WIFI
                statusString = KWifiNetworkKey;
                FMResultSet *result = [_userDatabase executeQueryWithFormat:@"SELECT * FROM NetworkInfo WHERE status = %@",statusString];
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
                FMResultSet *result = [_userDatabase executeQueryWithFormat:@"SELECT * FROM NetworkInfo WHERE status = %@",statusString];
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
                FMResultSet *result = [_userDatabase executeQueryWithFormat:@"SELECT * FROM NetworkInfo WHERE status = %@",statusString];
                if ([result next]) {
                    count = [NSNumber numberWithInt:[result intForColumn:@"count"] + 1];
                }
                networkStatus = YTNetworkSatusNotNomal;
            }
                break;
        }
        [_userDatabase executeUpdateWithFormat:@"UPDATE NetworkInfo SET count = %@ WHERE status = %@",count,statusString];
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
    NSString *sql = @"CREATE TABLE MallInfo('identify' INTEGER NOT NULL PRIMARY KEY,'name' TEXT,'count' INTERGER)";
    [_userDatabase executeUpdate:sql];
    
    sql = @"CREATE TABLE MerchantInfo('identify' INTEGER NOT NULL PRIMARY KEY,'name' TEXT,'count' INTERGER,'comment' TEXT)";
    [_userDatabase executeUpdate:sql];
    
    sql = @"CREATE TABLE BeaconInfo('identify' TEXT NOT NULL PRIMARY KEY,'power' TEXT,'date' TEXT)";
    [_userDatabase executeUpdate:sql];
    
    sql = @"CREATE TABLE LocationInfo('identify' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'latitude' REAL,'longitude' REAL,'isNearMall' INTEGER,'date' TEXT,'mallName' TEXT,UNIQUE (\"identify\" ASC))";
    [_userDatabase executeUpdate:sql];
    
    sql = @"CREATE TABLE NetworkInfo('status' TEXT PRIMARY KEY,'count' INTERGER,'comment' TEXT)";
    [_userDatabase executeUpdate:sql];
    
    NSArray *netWorkStatus = @[KWifiNetworkKey,KWwanNetworkKey,KNoNetworkKey];
    NSArray *comment = @[@"使用WIFI的次数",@"使用普通网络的次数",@"不使用网络的次数"];
    
    sql = @"INSERT INTO NetworkInfo(status,count,comment) VALUES (?,?,?)";
    for (int index = 0; index < 3; index++){
        [_userDatabase executeUpdate:sql withArgumentsInArray:@[netWorkStatus[index],@0,comment[index]]];
    }
}

#pragma mark Insert UserDatabase Data
- (void)saveMallInfo:(id)mall {
    NSString *identify = nil;
    id <YTMall> tmpMall = mall;
    if ([mall isMemberOfClass:[YTCloudMall class]]) {
        identify = [mall localDB];
    }else if([mall isMemberOfClass:[YTLocalMall class]]){
        identify = [mall identifier];
    }else{
        return;
    }
    FMResultSet *result = [_userDatabase executeQuery:@"SELECT identify,count FROM MallInfo WHERE identify = ?",identify];
    if (![result next]){
        [_userDatabase executeUpdate:@"INSERT INTO MallInfo('identify','name','count') VALUES(?,?,?)",identify,[tmpMall mallName],@0];
    }else{
        NSInteger count = [result intForColumn:@"count"];
        [_userDatabase executeUpdate:@"UPDATE MallInfo SET count = ? WHERE identify = ?",[NSNumber numberWithInteger:count + 1],identify];
    }
}

- (void)saveMerchantInfo:(id)merchant {
    NSString *identify = nil;
    NSString *name = nil;
    NSString *comment = nil;
    if ([merchant isKindOfClass:[YTCloudMerchant class]]) {
        identify = [(YTCloudMerchant *)merchant uniId];
        name = [(YTCloudMerchant *)merchant merchantName];
        comment = [[(YTCloudMerchant *)merchant mall] mallName];
    }else if([merchant isKindOfClass:[YTLocalMerchantInstance class]]){
        identify = [(YTLocalMerchantInstance *)merchant uniId];
        name = [(YTLocalMerchantInstance *)merchant merchantLocationName];
        comment = [[(YTLocalMerchantInstance *)merchant mall] mallName];
    }else{
        return;
    }
    
    FMResultSet *result = [_userDatabase executeQuery:@"SELECT identify,count FROM MerchantInfo identify = ?",identify];
    if ([result next]) {
        NSInteger count = [result intForColumn:@"count"];
        [_userDatabase executeUpdate:@"UPDATE MerchantInfo SET count = ? WHERE identify = ?",[NSNumber numberWithInteger:count],identify];
    }else{
        [_userDatabase executeUpdate:@"INSERT INTO MerchantInfo('identify','name','count','comment') VALUES(?,?,?,?)",identify,name,@0,comment];
    }
}

- (void)saveLocationInfo:(CLLocationCoordinate2D)coord name:(NSString *)name {
    NSNumber *isNearMall = @0;
    if (name) {
        isNearMall = @1;
    }else{
        name = @"";
    }
    NSNumber *latitude = [NSNumber numberWithDouble:coord.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:coord.longitude];
    [_userDatabase executeUpdate:@"INSERT INTO LocationInfo('latitude','longitude','isNearMall','mallName','date') VALUES(?,?,?,?,?)",latitude,longitude,isNearMall,name,_date];
}

-(void)saveBeaconInfo:(ESTBeacon *)beacon {
    NSString *identify = [NSString stringWithFormat:@"%@-%@",[beacon.major stringValue],[beacon.minor stringValue]];
    FMResultSet *result = [_userDatabase executeQuery:@"SELECT identify FROM BeaconInfo WHERE identify = ?",identify];
    if ([result next]) {
        [_userDatabase executeUpdate:@"UPDATE BeaconInfo SET date = ? , power = ?",_date,[beacon.batteryLevel stringValue]];
    }else{
        [_userDatabase executeUpdate:@"INSERT INTO BeaconInfo('identify','date','power') VALUES (?,?,?)",identify,_date,[beacon.batteryLevel stringValue]];
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
