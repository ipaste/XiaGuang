//
//  ViewController.m
//  xiaGuang
//
//  Created by YunTop on 14-10-24.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTHomeViewController.h"

#define BIGGER_THEN_IPHONE5 ([[UIScreen mainScreen]currentMode].size.height >= 1136.0f ? YES : NO)
#define APP_URL @"http://itunes.apple.com/cn/lookup?id=922405498"
#define BLUR_HEIGHT 174
#define STEP_LENGTH 20

@interface YTHomeViewController (){
    BOOL _blueToothOn;
    BOOL _scrollFired;
    BOOL _shouldScroll;
    BOOL _scrollDown;
    BOOL _scroll;
    
    UIViewController *_mapViewController;
    UIImageView *_backgroundImageView;
    UIToolbar *_blurView;
    UIButton *_navigationButton;
    UIButton *_carButton;
    UIButton *_choosRegionButton;
    
    UITableView *_tableView;
    YTChoosRegionView *_regionView;
    YTMallDict *_mallDict;
    YTBeaconManager *_beaconManager;
    YTBluetoothManager *_bluetoothManager;
    YTDataManager *_dataManager;
    id<YTMinorArea> _recordMinorArea;
    YTCity *_defaultCity;
    
    NSArray *_malls;
    NSArray *_recommendMalls;
    NSMutableArray *_cells;
    UIToolbar *_transitionToolbar;
    CLLocationManager *_manager;
}
@end

@implementation YTHomeViewController
-(instancetype)init{
    self = [super init];
    if (self) {
        _scrollDown = true;
        _scroll = true;
        _mallDict = [YTMallDict sharedInstance];
        _bluetoothManager = [YTBluetoothManager shareBluetoothManager];
        _beaconManager = [YTBeaconManager sharedBeaconManager];
        _manager = _bluetoothManager.locationManager;
        _dataManager = [YTDataManager defaultDataManager];
        _dataManager.delegate = self;
        [_dataManager refreshNetWorkState];
        _defaultCity = [YTCity defaultCity];
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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(detectedBluetoothStateHasChanged:) name:YTBluetoothStateHasChangedNotification object:nil];
    
    [_mallDict getAllLocalMallWithCallBack:^(NSArray *malls) {
        _malls = malls.copy;
    }];
    
    
    _manager.delegate = self;
    [_manager startUpdatingLocation];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    _tableView.delegate = self;
    _tableView.rowHeight = 130;
    _tableView.scrollsToTop = false;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsVerticalScrollIndicator = false;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(BLUR_HEIGHT, 0, 0, 0);
    [self.view addSubview:_tableView];
    
    if(!_scrollFired){
        [self test];
        _scrollFired = YES;
        _shouldScroll = YES;
    }
    
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
    
    
    _regionView = [[YTChoosRegionView alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 0) city:_defaultCity];
    _regionView.delegate = self;
    [_regionView hide];
    [self.view addSubview:_regionView];

    self.navigationItem.titleView = [self customTitleView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButtonItemCustomView]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self rightBarButtonItemCustomView]];
    self.view.layer.contents = (id)[UIImage imageNamed:@"bg"].CGImage;
    
    _transitionToolbar = [[UIToolbar alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _transitionToolbar.tintColor = [UIColor blackColor];
    _transitionToolbar.barStyle = UIBarStyleBlack;
    _transitionToolbar.translucent = YES;
    _transitionToolbar.alpha = 0;
    [self.view addSubview:_transitionToolbar];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [_manager stopUpdatingLocation];
    _manager.delegate = nil;
    NSNumber *latitude;
    NSNumber *longitude;
    for (CLLocation *location in locations) {
        longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
        latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        if(longitude != nil && latitude != nil){
            break;
        }
    }
    if (latitude != nil && longitude != nil){
        AFHTTPSessionManager *httpManager = [AFHTTPSessionManager manager];
        [httpManager GET:@"http://xiaguang.avosapps.com/new_near_mall" parameters:@{@"latitude":latitude,@"longitude":longitude,@"localMallIds":_mallDict.localMallIds} success:^(NSURLSessionDataTask *task, id responseObject) {
            if (responseObject != nil){
                if ([responseObject[@"status"] isEqualToString:@"OK"]) {
                    NSString *mallName = responseObject[@"name"];
                    NSString *mallId = responseObject[@"nearMallId"];
                    NSString *mallLocalDBId = responseObject[@"localId"];
                    float distance = ((NSString *)responseObject[@"distance"]).floatValue;
                    [_dataManager saveLocationInfo:CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]) name:mallName];
                    
                    [[NSUserDefaults standardUserDefaults]setValue:mallLocalDBId forKey:@"currentMall"];
                    
                    if (distance < 1000) {
                        YTMessageBox *messageBox = [[YTMessageBox alloc]initWithTitle:@"虾逛提示" Message:[NSString stringWithFormat:@"您正处于%@,需要自动导航吗？",mallName]];
                        messageBox.messageColor = [UIColor colorWithString:@"e95e37"];
                        [messageBox show];
                        [messageBox callBack:^(NSInteger tag) {
                            if (tag == 1){
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                    id<YTFloor> floor = [_mallDict firstFloorFromMallLocalId:mallLocalDBId];
                                    YTMapViewController2 *mapVC = [[YTMapViewController2 alloc]initWithFloor:floor];
                                    YTMallInfoViewController *mallInfoVC = [[YTMallInfoViewController alloc]initWithMallIdentify:mallId];
                                    [self.navigationController pushViewController:mallInfoVC animated:false];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [mallInfoVC presentViewController:mapVC animated:false completion:nil];
                                    });
                                });
                            }
                        }];
                    }
                }
            }else{
                [_dataManager saveLocationInfo:CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]) name:nil];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [_dataManager saveLocationInfo:CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]) name:nil];
        }];
    }
    
}
- (void)test {
    if (_scroll){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:1
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 [self scroll];
                             } completion:^(BOOL finished) {
                                 CGFloat offsetY = _tableView.contentOffset.y;
                                 if (offsetY >= _tableView.contentSize.height - _tableView.frame.size.height - 20) {
                                     _scrollDown = false;
                                 }else if (offsetY <= -BLUR_HEIGHT + 10){
                                     _scrollDown = true;
                                 }
                                 if(_shouldScroll){
                                     [self test];
                                 }
                             }];
            
        });
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _shouldScroll = NO;
    [_tableView.layer removeAllAnimations];
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate && !_shouldScroll){
        if(_shouldScroll){
            [self test];
        }
        _shouldScroll = YES;
        [self test];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    if(!_shouldScroll){
        _shouldScroll = YES;
        [self test];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _shouldScroll = NO;
    [_tableView.layer removeAllAnimations];
    _scrollFired = NO;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.clipsToBounds = true;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithString:@"e65e37"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjects:@[[UIColor colorWithString:@"e65e37"],[UIFont systemFontOfSize:20]] forKeys:@[NSForegroundColorAttributeName,NSFontAttributeName]]];
    _beaconManager.delegate = self;
    [_beaconManager startRangingBeacons];
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _beaconManager.delegate = nil;
    [_beaconManager stopRanging];
    
    if(!_scrollFired){
        [self test];
        _scrollFired = YES;
        _shouldScroll = YES;
    }
    [UIView animateWithDuration:0.1 animations:^{
        _transitionToolbar.alpha = 0;
    }];
}

-(void)scroll{
    CGPoint p = _tableView.contentOffset;
    if (_scrollDown) {
        p.y = p.y + STEP_LENGTH;
    }else{
        p.y = p.y - STEP_LENGTH;
    }
    _tableView.contentOffset = p;
}
-(UIView *)customTitleView{
    _choosRegionButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 20)];
    [_choosRegionButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_choosRegionButton setTitleColor:[UIColor colorWithString:@"e95e37"] forState:UIControlStateNormal];
    [_choosRegionButton setTitle:@"   深圳全城" forState:UIControlStateNormal];
    
    [_choosRegionButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    [_choosRegionButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateHighlighted];
    [_choosRegionButton setImage:[UIImage imageNamed:@"arrow_up"] forState:UIControlStateSelected];
    
    [_choosRegionButton addTarget:self action:@selector(choosRegionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_choosRegionButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
    [_choosRegionButton setImageEdgeInsets:UIEdgeInsetsMake(0, 80, 0, 0)];
    return _choosRegionButton;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_recommendMalls.count > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return _malls.count;
    }
    return _recommendMalls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YTMallCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[YTMallCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section == 0){
        id<YTMall> mall = _malls[indexPath.row];
        if([mall isMemberOfClass:[YTCloudMall class]]){
            cell.mall = mall;
        }
    }else{
        cell.mall = _recommendMalls[indexPath.row];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YTMallCell *cell = (YTMallCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.isFetch) {
        YTMallInfoViewController *mallInfoVC = [[YTMallInfoViewController alloc]initWithMallIdentify:[cell.mall identifier]];
        [_dataManager saveMallInfo:cell.mall];
        [self.navigationController pushViewController:mallInfoVC animated:true];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 30)];
    if (section == 1) {
        UIImage *backImage = [UIImage imageNamed:@"title_bg"];
        view.backgroundColor = [UIColor colorWithPatternImage:backImage];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 30)];
        titleLabel.text = @"虾逛一下";
        titleLabel.textColor = [UIColor colorWithString:@"cccccc"];
        titleLabel.font = [UIFont systemFontOfSize:15];
        [view addSubview:titleLabel];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 30;
}

-(void)networkStatusChanged:(YTNetworkSatus)status{
    switch (status) {
        case YTNetworkSatusWifi:
        case YTNetworkSatusWWAN:
        {
            [_mallDict getAllCloudMallWithCallBack:^(NSArray *malls) {
                if (malls.count > 0){
                    _malls = malls.copy;
                    [_tableView reloadData];
                }
            }];
        }
            break;
        case YTNetworkSatusNotNomal:
            
            break;
    }
}

-(void)rangedObjects:(NSArray *)objects{
    if(objects.count > 0){
        ESTBeacon *beacon = nil;
        double minDistance = MAXFLOAT;
        for (NSDictionary *beaconInfo in objects) {
            double beaconDistance = [beaconInfo[@"distance"] doubleValue];
            if (beaconDistance < minDistance) {
                beacon = beaconInfo[@"Beacon"];
                minDistance = beaconDistance;
            }
        }
        _recordMinorArea = [self getMinorArea:beacon];
    }
    else{
        _recordMinorArea = nil;
    }
}

-(void)noBeaconsFound{
    NSLog(@"no beacons found");
}

-(id<YTMinorArea>)getMinorArea:(ESTBeacon *)beacon{
    FMDatabase *db = [YTDataManager defaultDataManager].database;
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
    [AVAnalytics event:@"设置"];
    YTSettingViewController *settingVC = [[YTSettingViewController alloc]init];
    [self.navigationController pushViewController:settingVC animated:true];
}

-(void)jumpToMap:(UIButton *)sender{
    UIViewController *controller = nil;
    if (sender.tag == 1){
        if (_mapViewController == nil) {
            controller = [[YTMapViewController2 alloc]initWithMinorArea:_recordMinorArea];
        }else{
            controller = _mapViewController;
            ((YTMapViewController2 *)controller).showMajorArea = [_recordMinorArea majorArea];
        }
        [AVAnalytics event:@"导航"];
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }else{
        controller = [[YTParkingViewController alloc]initWithMinorArea:_recordMinorArea];
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [AVAnalytics event:@"停车"];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        _transitionToolbar.alpha = 1;
    }completion:^(BOOL finished) {
        [self presentViewController:controller animated:false completion:nil];
    }];
}

-(void)detectedBluetoothStateHasChanged:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    BOOL isOpen = [userInfo[@"isOpen"] boolValue];
    _blueToothOn = isOpen;
    if (!isOpen) {
        _recordMinorArea = nil;
    }else{
        _beaconManager.delegate = self;
        [_beaconManager startRangingBeacons];
    }
}

-(void)choosRegionButtonClicked:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        //选择
        [_regionView show];
    }else{
        //取消选择
        [_regionView hide];
    }
}
- (void)hideChoosRegionView{
    _choosRegionButton.selected = false;
}

- (void)selectRegion:(YTRegion *)region{
    NSString *title = nil;

    if (region == nil) {
        title = [NSString stringWithFormat:@"   %@全城",_defaultCity.name];
        _scroll = true;
    }else{
        title = [NSString stringWithFormat:@"%@%@",_defaultCity.name,region.name];
        _scroll = false;
       
    }
    
    if ([title isEqualToString:_choosRegionButton.titleLabel.text]) {
        return;
    }
    [_choosRegionButton setTitle:title forState:UIControlStateNormal];
    
    _malls = [_mallDict cloudMallsFromRegion:region].copy;
    
    if (_malls.count < 3) {
         _recommendMalls =  [_mallDict threeRandomMallDoesNotContainRegion:region].copy;
    }else{
        _recommendMalls = nil;
    }
    
    [_tableView reloadData];
    [_tableView setContentOffset:CGPointMake(0, -BLUR_HEIGHT)];
    
    if (_scroll) {
        CGFloat offsetY = _tableView.contentOffset.y;
        if (offsetY >= _tableView.contentSize.height - _tableView.frame.size.height - 20) {
            _scrollDown = false;
        }else if (offsetY <= -BLUR_HEIGHT){
            _scrollDown = true;
        }
        [self test];
    }
    
}

-(BOOL)prefersStatusBarHidden{
    return false;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:YTBluetoothStateHasChangedNotification object:nil];
}

@end
