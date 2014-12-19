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
    UIView *_backgroundBlurView;
    FXBlurView *_blurView;
    UIButton *_navigationButton;
    UIButton *_carButton;
    UITableView *_tableView;
    BOOL _blueToothOn;
    BOOL _latest;
    
    YTBeaconManager *_beaconManager;
    id<YTMinorArea> _recordMinorArea;
    
    NSMutableArray *_malls;
}
@end

@implementation YTHomeViewController
-(instancetype)init{
    self = [super init];
    if (self) {
        _malls = [NSMutableArray array];
        AVQuery *query = [AVQuery queryWithClassName:@"Mall"];
        [query whereKeyExists:@"localDBId"];
        [query whereKey:@"localDBId" notEqualTo:@""];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (AVObject *object in objects) {
                YTCloudMall *mall = [[YTCloudMall alloc]initWithAVObject:object];
                [_malls addObject:mall];
            }
            [_tableView reloadData];
            
        }];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg"]];
    [self.view addSubview:_backgroundImageView];
    _bluetoothManager = [YTBluetoothManager shareBluetoothManager];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(detectedBluetoothStateHasChanged:) name:YTBluetoothStateHasChangedNotification object:nil];
    
    _beaconManager = [YTBeaconManager sharedBeaconManager];
    [_beaconManager startRangingBeacons];
    _beaconManager.delegate = self;
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    _tableView.delegate = self;
    _tableView.rowHeight = 130;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsVerticalScrollIndicator = false;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _backgroundBlurView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), BLUR_HEIGHT)];
    _backgroundBlurView.backgroundColor = [UIColor colorWithString:@"000000" alpha:0.8];
    [self.view addSubview:_backgroundBlurView];
    _blurView = [[FXBlurView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), BLUR_HEIGHT)];
    _blurView.tintColor = [UIColor blackColor];
    _blurView.blurRadius = 25;
    _blurView.iterations = 1;
    [_blurView setDynamic:true];
    [self.view addSubview:_blurView];
    
    _navigationButton = [[UIButton alloc]initWithFrame:CGRectMake(8, 72, 148, 88)];
    _navigationButton.backgroundColor = [UIColor colorWithString:@"3a3e42" alpha:0.6];
    [_navigationButton setImage:[UIImage imageNamed:@"icon_gpsOn"] forState:UIControlStateHighlighted];
    [_navigationButton setImage:[UIImage imageNamed:@"icon_gps"] forState:UIControlStateNormal];
    [_navigationButton setTitle:@"导航" forState:UIControlStateNormal];
    [_navigationButton setTitleColor:[UIColor colorWithString:@"b2b2b2" alpha:1.0] forState:UIControlStateHighlighted];
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
    _carButton.layer.cornerRadius = 10;
    [_blurView addSubview:_carButton];
    
    self.navigationItem.title = @"深圳";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButtonItemCustomView]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self rightBarButtonItemCustomView]];
    self.view.backgroundColor = [UIColor whiteColor];
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
    
}

-(UIView *)leftBarButtonItemCustomView{
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
    [leftButton addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setImage:[UIImage imageNamed:@"icon_search"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"icon_searchOn"] forState:UIControlStateHighlighted];
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 0)];
    return leftButton;
}

-(UIView *)rightBarButtonItemCustomView{
    UIImage *image = [UIImage imageNamed:@"icon_set"];
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, image.size.width, image.size.height)];
    [rightButton setImage:image forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(jumpToSearch:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImage:[UIImage imageNamed:@"icon_setOn"] forState:UIControlStateHighlighted];
    return rightButton;
}
-(void)test{

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _malls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YTMallCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[YTMallCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.mall = _malls[indexPath.row];
    return cell;
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

-(void)clickedPanelAtIndex:(NSInteger)index{
    UIViewController *controller = nil;
    switch (index) {
        case 0:
        {
            controller = [[YTMallViewController alloc]init];
            [AVAnalytics event:@"商城"];
        }
            break;
        case 1:
        {
            
            controller = [[YTParkingViewController alloc]initWithMinorArea:_recordMinorArea];
            controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [AVAnalytics event:@"停车"];
            if (controller == nil) return;
            [self presentViewController:controller animated:YES completion:^{
                
            }];
        }
            return;
        case 2:
        {
            controller = [[YTSettingViewController alloc]init];

            [(YTSettingViewController *)controller setIsLatest:_latest];

            [AVAnalytics event:@"设置"];

        }
            break;
        case 3:
        {
            if (_mapViewController == nil) {
                _mapViewController = [[YTMapViewController2 alloc]initWithMinorArea:_recordMinorArea];
            }
            [AVAnalytics event:@"导航"];
            _mapViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:_mapViewController animated:YES completion:nil];
        }
            
            return;
    }
    if(controller == nil) return;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)jumpToSearch:(UIButton *)sender{
    YTSearchViewController *searchVC = [[YTSearchViewController alloc]init];
    [self.navigationController pushViewController:searchVC animated:YES];
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
