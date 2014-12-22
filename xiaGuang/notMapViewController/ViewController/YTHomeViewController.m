//
//  ViewController.m
//  xiaGuang
//
//  Created by YunTop on 14-10-24.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTHomeViewController.h"
#define BIGGER_THEN_IPHONE5 ([[UIScreen mainScreen]currentMode].size.height >= 1136.0f ? YES : NO)
#define BLUR_HEIGHT 174
@interface YTHomeViewController (){
    UIViewController *_mapViewController;
    UIImageView *_backgroundImageView;
    YTBluetoothManager *_bluetoothManager;
    UIToolbar *_blurView;
    UIButton *_navigationButton;
    UIButton *_carButton;
    BBTableView *_tableView;
    BOOL _blueToothOn;
    BOOL _latest;
    YTBeaconManager *_beaconManager;
    id<YTMinorArea> _recordMinorArea;
    NSMutableArray *_malls;
    NetworkStatus _status;
}
@end

@implementation YTHomeViewController
-(instancetype)init{
    self = [super init];
    if (self) {
        _malls = [NSMutableArray array];
        Reachability * reachability = [Reachability reachabilityWithHostname:@"cn.avoscloud.com"];
        [reachability startNotifier];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImage *backgroundImage = [UIImage imageNamed:@"img_default.jpg"];
    _backgroundImageView = [[UIImageView alloc]initWithFrame: CGRectMake(0, BLUR_HEIGHT, CGRectGetWidth(self.view.frame), backgroundImage.size.height)];
    _backgroundImageView.image = backgroundImage;
    [self.view addSubview:_backgroundImageView];
    
    _bluetoothManager = [YTBluetoothManager shareBluetoothManager];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(detectedBluetoothStateHasChanged:) name:YTBluetoothStateHasChangedNotification object:nil];
    
    _beaconManager = [YTBeaconManager sharedBeaconManager];
    [_beaconManager startRangingBeacons];
    _beaconManager.delegate = self;
    
    _tableView = [[BBTableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    _tableView.delegate = self;
    _tableView.rowHeight = 130;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsVerticalScrollIndicator = false;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView setEnableInfiniteScrolling:YES];
    
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _blurView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), BLUR_HEIGHT)];
    _blurView.tintColor = [UIColor blackColor];
    _blurView.barStyle = UIBarStyleBlack;
    _blurView.translucent = YES;
    [self.view addSubview:_blurView];
    
    _navigationButton = [[UIButton alloc]initWithFrame:CGRectMake(8, 72, 148, 88)];
    _navigationButton.backgroundColor = [UIColor colorWithString:@"3a3e42" alpha:0.6];
    [_navigationButton setImage:[UIImage imageNamed:@"icon_gpsOn"] forState:UIControlStateHighlighted];
    [_navigationButton setImage:[UIImage imageNamed:@"icon_gps"] forState:UIControlStateNormal];
    [_navigationButton setTitle:@"导航" forState:UIControlStateNormal];
    [_navigationButton setTitleColor:[UIColor colorWithString:@"b2b2b2" alpha:1.0] forState:UIControlStateHighlighted];
    [_navigationButton addTarget:self action:@selector(jumpToMap:) forControlEvents:UIControlEventTouchUpInside];
    _navigationButton.tag = 1;
    [_navigationButton setTitleEdgeInsets:UIEdgeInsetsMake(50, -35, 0, 0)];
    [_navigationButton setImageEdgeInsets:UIEdgeInsetsMake(-20, 35, 0, 0)];
    _navigationButton.layer.cornerRadius = 10;
    [_blurView addSubview:_navigationButton];
    
    
    _carButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_navigationButton.frame) + 8, CGRectGetMinY(_navigationButton.frame), CGRectGetWidth(_navigationButton.frame), CGRectGetHeight(_navigationButton.frame))];
    _carButton.backgroundColor = [UIColor colorWithString:@"3a3e42" alpha:0.6];
    [_carButton setImage:[UIImage imageNamed:@"icon_carOn"] forState:UIControlStateHighlighted];
    [_carButton setImage:[UIImage imageNamed:@"icon_car"] forState:UIControlStateNormal];
    [_carButton setTitle:@"寻车" forState:UIControlStateNormal];
    [_carButton setTitleColor:[UIColor colorWithString:@"b2b2b2" alpha:1.0] forState:UIControlStateHighlighted];
    [_carButton setTitleEdgeInsets:UIEdgeInsetsMake(50, -35, 0, 0)];
    [_carButton setImageEdgeInsets:UIEdgeInsetsMake(-20, 35, 0, 0)];
    _carButton.tag = 2;
    [_carButton addTarget:self action:@selector(jumpToMap:) forControlEvents:UIControlEventTouchUpInside];
    _carButton.layer.cornerRadius = 10;
    [_blurView addSubview:_carButton];
    
    self.navigationItem.title = @"深圳";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButtonItemCustomView]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self rightBarButtonItemCustomView]];
    
    self.view.layer.contents = (id)[UIImage imageNamed:@"bg"].CGImage;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [[NSURL alloc]initWithString:@"http://itunes.apple.com/cn/lookup?id=922405498"];
        NSData *jsonData = [NSData dataWithContentsOfURL:url];
        if(jsonData != nil){
            NSString *cloudVersion = [[[[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil] valueForKey:@"results"] valueForKey:@"version"] firstObject];
            NSString *localVersion = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleShortVersionString"];
            if (cloudVersion != localVersion){
                _latest = false;
            }
        }
    });
    
    FMDatabase *database = [YTStaticResourceManager sharedManager].db;
    FMResultSet *result = [database executeQuery:@"select * from Mall"];
    while ([result next]) {
        YTLocalMall *mall = [[YTLocalMall alloc]initWithDBResultSet:result];
        [_malls addObject:mall];
    }
    [_tableView reloadData];
}

-(UIView *)leftBarButtonItemCustomView{
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
    [leftButton addTarget:self action:@selector(jumpToSetting:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setImage:[UIImage imageNamed:@"icon_set"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"icon_setOn"] forState:UIControlStateHighlighted];
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 0)];
    return leftButton;
}

-(UIView *)rightBarButtonItemCustomView{
    UIImage *image = [UIImage imageNamed:@"icon_search"];
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, image.size.width, image.size.height)];
    [rightButton setImage:image forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(jumpToSearch:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImage:[UIImage imageNamed:@"icon_searchOn"] forState:UIControlStateHighlighted];
    return rightButton;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _malls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"Cell";
    YTMallCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[YTMallCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.mall = _malls[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YTMallCell *cell = (YTMallCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.isFetch) {
        YTMallInfoViewController *mallInfoVC = [[YTMallInfoViewController alloc]init];
        mallInfoVC.mall = _malls[indexPath.row % _malls.count];
        [self.navigationController pushViewController:mallInfoVC animated:true];
    }
}

-(void)reachabilityChanged:(NSNotification *)notification{
    Reachability *tmpReachability = notification.object;
    
    if (_status == NotReachable &&  tmpReachability.currentReachabilityStatus != NotReachable) {
        [self changeLocalMallVariableCloudMall:^{
            [_tableView reloadData];
        }];
    }else if(tmpReachability.currentReachabilityStatus != NotReachable){
        [self changeLocalMallVariableCloudMall:^{
            [_tableView reloadData];
        }];
    }
    _status =  tmpReachability.currentReachabilityStatus;
}
-(void)changeLocalMallVariableCloudMall:(void(^)())callBack{
    AVQuery *query = [AVQuery queryWithClassName:@"Mall"];
    [query whereKeyExists:@"localDBId"];
    [query whereKey:@"localDBId" notEqualTo:@""];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *array = [NSMutableArray array];
        for (AVObject *mall in objects) {
            YTCloudMall *cloudMall = [[YTCloudMall alloc]initWithAVObject:mall];
            [array addObject:cloudMall];
        }
        [_malls removeAllObjects];
        _malls = nil;
        _malls = array;
        if (callBack != nil) {
            callBack();
        }
    }];
}
-(void)rangedBeacons:(NSArray *)beacons{
    if(beacons.count > 0){
        _recordMinorArea = [self getMinorArea:beacons[0]];
    }
    else{
        _recordMinorArea = nil;
    }
}

-(void)noBeaconsFound{
    NSLog(@"no beacons found");
}

-(id<YTMinorArea>)getMinorArea:(ESTBeacon *)beacon{
    
    FMDatabase *db = [YTStaticResourceManager sharedManager].db;
    [db open];
    FMResultSet *result = [db executeQuery:@"select * from Beacon where major = ? and minor = ?",[beacon.major stringValue],[beacon.minor stringValue]];
    [result next];
    YTLocalBeacon *localBeacon = [[YTLocalBeacon alloc] initWithDBResultSet:result];
    
    YTLocalMinorArea * minorArea = [localBeacon minorArea];
    return minorArea;
}


-(void)jumpToSearch:(UIButton *)sender{
    YTSearchViewController *searchVC = [[YTSearchViewController alloc]init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

-(void)jumpToSetting:(UIButton *)sender{
    YTSettingViewController *settingVC = [[YTSettingViewController alloc]init];
    [settingVC setIsLatest:_latest];
    [AVAnalytics event:@"设置"];
    [self.navigationController pushViewController:settingVC animated:YES];
}

-(void)jumpToMap:(UIButton *)sender{
    UIViewController *controller = nil;
    if (sender.tag == 1){
        if (_mapViewController == nil) {
            controller = [[YTMapViewController2 alloc]initWithMinorArea:_recordMinorArea];
        }else{
            controller = _mapViewController;
        }
        [AVAnalytics event:@"导航"];
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }else{
        controller = [[YTParkingViewController alloc]initWithMinorArea:_recordMinorArea];
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [AVAnalytics event:@"停车"];
    }
    [self presentViewController:controller animated:true completion:nil];
}

-(void)detectedBluetoothStateHasChanged:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    BOOL isOpen = [userInfo[@"isOpen"] boolValue];
    _blueToothOn = isOpen;
    if (!isOpen) {
        _recordMinorArea = nil;
    }
    else{
        
    } 
}
-(BOOL)prefersStatusBarHidden{
    return NO;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:YTBluetoothStateHasChangedNotification object:nil];
}


@end
