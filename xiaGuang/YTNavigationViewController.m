//
//  YTNavigationViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-11.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTNavigationViewController.h"

@interface YTNavigationViewController (){
    UIButton *_mapPositioning;
    UIButton *_stopCar;
    UIScrollView *_scrollView;
    UILabel *_mapSubLabel;
    UILabel *_stopCarSubLable;
    UILabel *_bluetoothLabel;
    UIViewController *_mapViewController;
    UIImageView *_bluetoothImageView;
    YTBluetoothManager *_bluetoothManager;
    BOOL _blueToothOn;
    
    BOOL _found;
    id<YTMinorArea> _minor;
    YTBeaconManager * _beaconManager;
}
@end

@implementation YTNavigationViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    _beaconManager = [YTBeaconManager sharedBeaconManager];
    _beaconManager.delegate = self;
    [_beaconManager startRangingBeacons];
    
    _blueToothOn = NO;
    _found = NO;
    
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"导航";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"all_bg_navbar-1"] forBarMetrics:UIBarMetricsDefault];
    _scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    _scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_map2"]];
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame) - 110);
    
    //MapPosition
    _mapPositioning = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_scrollView.frame), 85)];
    _mapPositioning.backgroundColor = [UIColor whiteColor];
    [_mapPositioning setBackgroundImage:[UIImage imageNamed:@"shop_bg_2_pr"] forState:UIControlStateHighlighted];
    [_mapPositioning setBackgroundImage:[UIImage imageNamed:@"shop_bg_2_pr"] forState:UIControlStateSelected];
    [_mapPositioning addTarget:self action:@selector(jumpToMap:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *mapImageView = [[UIImageView alloc]initWithFrame:CGRectMake(25, 40, 40, 40)];
    mapImageView.image = [UIImage imageNamed:@"home2_ico_nav"];
    mapImageView.center = CGPointMake(mapImageView.center.x, CGRectGetHeight(_mapPositioning.frame) / 2);
    [_mapPositioning addSubview:mapImageView];
    
    UILabel *mapLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(mapImageView.frame) + 15, 27, 17 * 4, 17)];
    mapLabel.font = [UIFont systemFontOfSize:17];
    mapLabel.textColor = [UIColor colorWithString:@"606060"];
    mapLabel.text = @"地图导航";
    [_mapPositioning addSubview:mapLabel];
    
    _mapSubLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(mapLabel.frame), CGRectGetMaxY(mapLabel.frame) + 5, 200, 12)];
    _mapSubLabel.text = @"实时定位导航目标位置";
    _mapSubLabel.textColor = [UIColor colorWithString:@"909090"];
    _mapSubLabel.font = [UIFont systemFontOfSize:12];
    [_mapPositioning addSubview:_mapSubLabel];
    
    UIImage *arrowImage = [UIImage imageNamed:@"home_img_arrow"];
    
    UIImageView *mapArrow =[[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(_mapPositioning.frame) - 25 - arrowImage.size.width, 0, arrowImage.size.width, arrowImage.size.height)];
    mapArrow.center = CGPointMake(mapArrow.center.x, CGRectGetHeight(_mapPositioning.frame) / 2);
    mapArrow.image = arrowImage;
    
    UIView *mapline = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(_mapPositioning.frame), CGRectGetWidth(_mapPositioning.frame), 3)];
    mapline.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"set_img_shadow"]];
    
    [_mapPositioning addSubview:mapArrow];
    [_mapPositioning addSubview:mapline];
    
    //stopCar
    _stopCar = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_mapPositioning.frame) + 0.5, CGRectGetWidth(_scrollView.frame) , CGRectGetHeight(_mapPositioning.frame))];
    _stopCar.backgroundColor = [UIColor whiteColor];
    [_stopCar setBackgroundImage:[UIImage imageNamed:@"shop_bg_2_pr"] forState:UIControlStateHighlighted];
    [_stopCar setBackgroundImage:[UIImage imageNamed:@"shop_bg_2_pr"] forState:UIControlStateSelected];
    [_stopCar addTarget:self action:@selector(jumpToStopCar:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *carImageView = [[UIImageView alloc]initWithFrame:CGRectMake(25, 40, 40, 40)];
    carImageView.image = [UIImage imageNamed:@"home2_ico_car"];
    [_stopCar addSubview:carImageView];
    carImageView.center = CGPointMake(carImageView.center.x, CGRectGetHeight(_stopCar.frame) / 2);
    UILabel *carLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(carImageView.frame) + 15, CGRectGetMinY(carImageView.frame), 100, 20)];
    carLabel.text = @"停车标记";
    carLabel.font = [UIFont systemFontOfSize:17];
    carLabel.textColor = [UIColor colorWithString:@"606060"];
    [_stopCar addSubview:carLabel];
    
    _stopCarSubLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(carLabel.frame), CGRectGetMaxY(carLabel.frame) + 5, 120, 12)];
    _stopCarSubLable.text = @"实时定位导航目标位置";
    _stopCarSubLable.textColor = [UIColor colorWithString:@"909090"];
    _stopCarSubLable.font = [UIFont systemFontOfSize:12];
    [_stopCar addSubview:_stopCarSubLable];
    
    UIImageView *carArrow =[[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(_stopCar.frame) - 25 - arrowImage.size.width, 0, arrowImage.size.width, arrowImage.size.height)];
    carArrow.center = CGPointMake(carArrow.center.x, CGRectGetHeight(_stopCar.frame) / 2);
    carArrow.image = arrowImage;
    
    UIView *carline = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(_stopCar.frame), CGRectGetWidth(_stopCar.frame), 0.5)];
    carline.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"set_img_shadow"]];
    [_stopCar addSubview:carArrow];
    [_stopCar addSubview:carline];
    [_scrollView addSubview:_mapPositioning];
    [_scrollView addSubview:_stopCar];
    
    _bluetoothImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 90, 90)];
    _bluetoothImageView.center = CGPointMake(CGRectGetWidth(_scrollView.bounds) / 2,CGRectGetMaxY(_stopCar.frame) +((CGRectGetHeight(_scrollView.bounds) -  CGRectGetMaxY(_stopCar.frame)) / 2) - CGRectGetWidth(_bluetoothImageView.frame) / 2 - 21);
    
    [_scrollView addSubview:_bluetoothImageView];
    
    _bluetoothLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_bluetoothImageView.frame) + 10, CGRectGetWidth(_scrollView.frame), 12)];
    _bluetoothLabel.textAlignment = 1;
    _bluetoothLabel.font = [UIFont systemFontOfSize:12];
    [_scrollView addSubview:_bluetoothLabel];

    [self.view addSubview:_scrollView];
    _bluetoothManager = [YTBluetoothManager shareBluetoothManager];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(detectedBluetoothStateHasChanged:) name:YTBluetoothStateHasChangedNotification object:nil];
}

-(void)viewWillLayoutSubviews{
    CGFloat topHeight = [self.topLayoutGuide length];
    
    CGRect frame = _scrollView.frame;
    frame.origin.y = topHeight ;
    frame.size.height = CGRectGetHeight(self.view.frame) - topHeight;
    _scrollView.frame = frame;
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_bluetoothManager refreshBluetoothState];
    _beaconManager.delegate = self;
}
-(void)detectedBluetoothStateHasChanged:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    BOOL isOpen = [userInfo[@"isOpen"] boolValue];
    if (!isOpen) {
        _blueToothOn = NO;
        _bluetoothLabel.text = @"精确定位需要开启蓝牙";
        _bluetoothLabel.textColor = [UIColor colorWithString:@"c4c1bf"];
        _bluetoothImageView.image = [UIImage imageNamed:@"home2_img_blue"];
        _mapSubLabel.text = @"开启蓝牙,实时定位导航目标位置";
        
    }else{
        _blueToothOn = YES;
        _bluetoothLabel.text = @"蓝牙已开启";
        [_bluetoothLabel setTextColor:[UIColor colorWithString:@"2f95f0"]];
        _bluetoothImageView.image = [UIImage imageNamed:@"home2_img_blue2"];
        [self promptMinorChange:_minor];
    }
}

-(void)jumpToMap:(UIButton *)sender{
    if(!_blueToothOn){
        [[[UIAlertView alloc]initWithTitle:@"骚瑞" message:@"蓝牙没有开启" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil]show];
        return;
    }
    if(!_found){
        [[[UIAlertView alloc]initWithTitle:@"骚瑞" message:@"您不在我们合作商圈之内" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil]show];
        return;
    }
    
    if(!_mapViewController){
        _mapViewController = [[YTMapViewController2 alloc]initWithMinorArea:_minor];
    }

    _mapViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:_mapViewController animated:YES completion:nil];
}

-(void)jumpToStopCar:(UIButton *)sender{
    YTStopCarViewController *stopCarVC = [[YTStopCarViewController alloc]init];
    stopCarVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:stopCarVC animated:YES completion:nil];
}


-(void)primaryBeaconShiftedTo:(ESTBeacon *)beacon{
    _found = YES;
    _minor = [self getMinorArea:beacon];
    [self promptMinorChange:_minor];
}

-(void)noBeaconsFound{
    
}


-(id<YTMinorArea>)getMinorArea:(ESTBeacon *)beacon{
    FMDatabase *db = [YTDBManager sharedManager];
    [db open];
    FMResultSet *result = [db executeQuery:@"select * from Beacon where major = ? and minor = ?",[beacon.major stringValue],[beacon.minor stringValue]];
    [result next];
    YTLocalBeacon *localBeacon = [[YTLocalBeacon alloc] initWithDBResultSet:result];
    
    YTLocalMinorArea * minor = [localBeacon minorArea];
    return minor;
}
-(void)promptMinorChange:(id<YTMinorArea>)minor{
    if (minor == nil) {
        _mapSubLabel.text = @"您不在我们合作的商圈内";
        return;
    }
    id<YTFloor> tmpFloor = [[minor majorArea] floor];
    id<YTBlock> tmpBlock = [tmpFloor block];
    id<YTMall> tmpMall = [tmpBlock mall];
    _mapSubLabel.text = [NSString stringWithFormat:@"您当前在%@-%@-%@",[tmpMall mallName],[tmpBlock blockName],[tmpFloor floorName]];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:YTBluetoothStateHasChangedNotification object:nil];
}
@end
