//
//  ViewController.m
//  xiaGuang
//
//  Created by YunTop on 14-10-24.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTHomeViewController.h"
#import "AppDelegate.h"
#define BIGGER_THEN_IPHONE5 ([[UIScreen mainScreen]currentMode].size.height >= 1136.0f ? YES : NO)
#define BLUR_HEIGHT 174

#define STEP_LENGTH 20
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
    BOOL _scrollFired;
    BOOL _shouldScroll;
    
    NSMutableArray *_cells;
    NetworkStatus _status;
    
    YTStaticResourceManager *_resourceManager;
    UIToolbar *_transitionToolbar;
}
@end

@implementation YTHomeViewController
-(instancetype)init{
    self = [super init];
    if (self) {
        _malls = [NSMutableArray array];
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
    
    _latest = false;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [[NSURL alloc]initWithString:@"http://itunes.apple.com/cn/lookup?id=922405498"];
        NSData *jsonData = [NSData dataWithContentsOfURL:url];
        if(jsonData != nil){
            NSString *cloudVersion = [[[[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil] valueForKey:@"results"] valueForKey:@"version"] firstObject];
            NSString *localVersion = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleShortVersionString"];
            if (cloudVersion > localVersion){
                _latest = true;
            }
        }
        
       
        _resourceManager = [YTStaticResourceManager sharedManager];
        Reachability * reachability = [Reachability reachabilityWithHostname:@"cn.avoscloud.com"];
        [reachability startNotifier];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        [self firstStartSettingTheProgram];
      
    });

    FMDatabase *database = [YTStaticResourceManager sharedManager].db;
    FMResultSet *result = [database executeQuery:@"select * from Mall"];
    _cells = [NSMutableArray new];
    
    int i = 0;
    while ([result next]) {
        YTLocalMall *mall = [[YTLocalMall alloc]initWithDBResultSet:result];
        [_malls addObject:mall];
        
    }
    for(int j = 0; j<_malls.count*3; j++){
        YTMallCell *cell1 = [[YTMallCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
        [_cells addObject:cell1];
    }
    
    
    [_tableView reloadData];
    
    [self changeLocalMallVariableCloudMall:^{
        [_tableView reloadData];
    }];
    
    
    if(!_scrollFired){
        [self test];
        _scrollFired = YES;
        _shouldScroll = YES;
    }
    
    _transitionToolbar = [[UIToolbar alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _transitionToolbar.tintColor = [UIColor blackColor];
    _transitionToolbar.barStyle = UIBarStyleBlack;
    _transitionToolbar.translucent = YES;
    _transitionToolbar.alpha = 0;
    [self.view addSubview:_transitionToolbar];
}



- (void)test {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:1
                              delay:0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                                [self scrollDown];
                         } completion:^(BOOL finished) {
                             
                             CGPoint p = _tableView.contentOffset;
                             double toHeight = p.y + STEP_LENGTH;
                             if(toHeight >= ( _tableView.contentSize.height - _tableView.frame.size.height) ){
                                 p.y = p.y - _tableView.contentSize.height/3.0f;
                                 [_tableView setContentOffset:p];
                             }
                             if(_shouldScroll){
                                 [self test];
                             }
                         }];
        
    });
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _shouldScroll = NO;
    
    [_tableView.layer removeAllAnimations];
    
}



-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if(!decelerate && !_shouldScroll){
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

}
-(void)viewDidAppear:(BOOL)animated{
    
    if(!_scrollFired){
        [self test];
        _scrollFired = YES;
        _shouldScroll = YES;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        _transitionToolbar.alpha = 0;
    }];
}


/*
 
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self test];
}*/

-(void)scrollDown{
    CGPoint p = _tableView.contentOffset;
    p.y = p.y + STEP_LENGTH;
    
   // NSLog(@"about to scroll up to point: %f",p.y);
    _tableView.contentOffset = p;
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
    YTMallCell *cell = _cells[indexPath.row];
    id<YTMall> mall = _malls[indexPath.row%_malls.count];
    if([mall isMemberOfClass:[YTCloudMall class]]){
        cell.mall = mall;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YTMallCell *cell = (YTMallCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.isFetch) {
        YTMallInfoViewController *mallInfoVC = [[YTMallInfoViewController alloc]init];
        mallInfoVC.mall = _malls[indexPath.row % _malls.count];
        mallInfoVC.isPreferential = cell.isPreferential;
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
    
    if (tmpReachability.isReachableViaWiFi) {
        [_resourceManager startBackgroundDownload];
        [_resourceManager checkAndSwitchToNewStaticData];
    }
    _status =  tmpReachability.currentReachabilityStatus;
}
-(void)changeLocalMallVariableCloudMall:(void(^)())callBack{
    AVQuery *query = [AVQuery queryWithClassName:@"Mall"];
    query.cachePolicy = kAVCachePolicyCacheElseNetwork;
    query.maxCacheAge = 24 * 60 * 60;
    [query whereKeyExists:@"localDBId"];
    [query whereKey:@"localDBId" notEqualTo:@""];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error && objects != nil && objects.count != 0){
            NSMutableArray *array = [NSMutableArray array];
            for (AVObject *mall in objects) {
                YTCloudMall *cloudMall = [[YTCloudMall alloc]initWithAVObject:mall];
                [cloudMall mallName];
                [array addObject:cloudMall];
            }
            [_malls removeAllObjects];
            _malls = nil;
            _malls = array;
            if (callBack != nil) {
                callBack();
            }
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
    }
    else{
        
    } 
}

-(BOOL)prefersStatusBarHidden{
    return NO;
}

-(void)firstStartSettingTheProgram{
    static NSString * firstKey = @"Program";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([[userDefaults valueForKey:firstKey] isEqualToValue:@0]) {
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
        if ([fileManager fileExistsAtPath:[path stringByAppendingPathComponent:@"current"]]) {
            [fileManager removeItemAtPath:path error:nil];
            [_resourceManager restartCopyTheFile];
        }
        [[NSUserDefaults standardUserDefaults]setValue:@1 forKey:@"Program"];
    }
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:YTBluetoothStateHasChangedNotification object:nil];
}


@end
