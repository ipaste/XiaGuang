//
//  ViewController.m
//  xiaGuang
//
//  Created by YunTop on 14-10-24.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTHomeViewController.h"
#define BIGGER_THEN_IPHONE5 ([[UIScreen mainScreen]currentMode].size.height >= 1136.0f ? YES : NO)
#define PANEL_SIZE 250
@interface YTHomeViewController (){
    YTPanel *_panel;
    UIViewController *_mapViewController;
    YTBluetoothManager *_bluetoothManager;
    
    BOOL _blueToothOn;
    
    YTBeaconManager *_beaconManager;
    
    id<YTMinorArea> _recordMinorArea;
}
@end

@implementation YTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _panel = [[YTPanel alloc]initWithFrame:CGRectMake(0, 0, PANEL_SIZE, PANEL_SIZE) items:@[@"商城",@"停车",@"设置",@"地图"]];
    [_panel setItemsTheImage:@[[UIImage imageNamed:@"home_ico_mall_pr"],[UIImage imageNamed:@"home_ico_parking_pr"],[UIImage imageNamed:@"home_ico_set_pr"],[UIImage imageNamed:@"home_ico_map_pr"]] highlightImages:@[[UIImage imageNamed:@"home_ico_mall_un"],[UIImage imageNamed:@"home_ico_parking_un"],[UIImage imageNamed:@"home_ico_set_un"],[UIImage imageNamed:@"home_ico_map_un"]]];
    _panel.delegate = self;
    [self.view addSubview:_panel];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButtonItemCustomView]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self rightBarButtonItemCustomView]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _bluetoothManager = [YTBluetoothManager shareBluetoothManager];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(detectedBluetoothStateHasChanged:) name:YTBluetoothStateHasChangedNotification object:nil];
    
    _beaconManager = [YTBeaconManager sharedBeaconManager];
    [_beaconManager startRangingBeacons];
    if([_beaconManager currentClosest] != nil){
        _recordMinorArea = [self getMinorArea:[_beaconManager currentClosest]];
    }
    _beaconManager.delegate = self;
    
}

-(void)primaryBeaconShiftedTo:(ESTBeacon *)beacon{
    _recordMinorArea = [self getMinorArea:beacon];
}

-(void)noBeaconsFound{
    NSLog(@"no beacons found");
}

-(id<YTMinorArea>)getMinorArea:(ESTBeacon *)beacon{
    
    FMDatabase *db = [YTDBManager sharedManager].db;
    [db open];
    FMResultSet *result = [db executeQuery:@"select * from Beacon where major = ? and minor = ?",[beacon.major stringValue],[beacon.minor stringValue]];
    [result next];
    YTLocalBeacon *localBeacon = [[YTLocalBeacon alloc] initWithDBResultSet:result];
    
    YTLocalMinorArea * minorArea = [localBeacon minorArea];
    return minorArea;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_panel startAnimationWithBackgroundAndCircle];
    self.navigationItem.title = @"虾逛";
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"首页";
}


- (void)viewWillLayoutSubviews{
    CGFloat y = 0;
    if (BIGGER_THEN_IPHONE5) {
        y = CGRectGetHeight(self.view.frame) - 165 - PANEL_SIZE / 2;
    }else{
        y = CGRectGetHeight(self.view.frame) - 100 - PANEL_SIZE / 2;
    }
    _panel.center = CGPointMake(self.view.center.x, y);
}

-(UIView *)leftBarButtonItemCustomView{
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 60, 40)];
    [leftButton setTitle:@"深圳" forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor colorWithString:@"#fac890"] forState:UIControlStateHighlighted];
    [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0 , -10, 0, 0)];
    [leftButton setImage:[UIImage imageNamed:@"home1_ico_location_un"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"home1_ico_location_pr"] forState:UIControlStateHighlighted];
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    return leftButton;
}

-(UIView *)rightBarButtonItemCustomView{
    UIImage *image = [UIImage imageNamed:@"nav_ico_search_un"];
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, image.size.width, image.size.height)];
    [rightButton setImage:image forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(jumpToSearch:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImage:[UIImage imageNamed:@"nav_ico_search_pr"] forState:UIControlStateHighlighted];
    return rightButton;
}


-(void)clickedPanelAtIndex:(NSInteger)index{
    UIViewController *controller = nil;
    switch (index) {
        case 0:
        {
            controller = [[YTMallViewController alloc]init];
        }
            break;
        case 1:
        {
            controller = [[YTParkingViewController alloc]initWithMinorArea:_recordMinorArea];
            controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            if (controller == nil) return;
            [self presentViewController:controller animated:YES completion:^{
                
            }];
        }
            return;
        case 2:
        {
            controller = [[YTSettingViewController alloc]init];
            [(YTSettingViewController *)controller setIsLatest:YES];
        }
            break;
        case 3:
        {
            if (_mapViewController == nil) {
                _mapViewController = [[YTMapViewController2 alloc]initWithMinorArea:_recordMinorArea];
            }
            
            _mapViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:_mapViewController animated:YES completion:nil];
        }
            
            return;
    }
    if(controller == nil) return;
    [_panel stopAnimationWithBackgroundAndCircle];
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
    [_panel setBluetoothState:isOpen];
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
