//
//  YTStopCarController.m
//  xiaGuang
//
//  Created by YunTop on 14/10/30.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTParkingViewController.h"
typedef NS_ENUM(NSInteger, YTParkingState) {
    YTParkingStateNormal = 0,
    YTParkingStateNotMark,
    YTParkingStateMarked
};
@implementation YTParkingViewController{
    id<YTMinorArea> _minorArea;
    YTMapView2 *_mapView;
    YTNavigationBar *_navigationBar;
    YTZoomStepper *_zoomStepper;
    UIView *_shadeView;
    UIView *_beforeMarkView;
    UILabel *_firstLabel;
    UILabel *_firstSubLable;
    UILabel *_secondLable;
    UILabel *_secondSubLabel;
    UIButton *_cancelMarkedButton;
    UIButton *_starNavigationButton;
    UIButton *_parkingView;
    UILabel *_promptLable;
    YTBluetoothManager *_bluetoothManager;
    YTCurrentParkingButton *_currentParkingButton;
    YTMoveCurrentLocationButton *_moveCurrentLocationButton;
    BOOL _bluetoothOn;
    BOOL _marked;
    BOOL _isReceivedMessage;
    CLLocationCoordinate2D _carCoordinate;
    YTParkingMarkPoi *_poiMarked;
    YTParkingPoi *_currenPoi;
    YTUserDefaults *_userDefaults;
    YTParkingState _state;
    YTBeaconManager *_beaconManager;
}

-(instancetype)initWithMinorArea:(id<YTMinorArea>)minorArea{
    self = [super init];
    if (self) {
        _isReceivedMessage = NO;
        _minorArea = minorArea;
        _bluetoothManager = [YTBluetoothManager shareBluetoothManager];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(blueStateChange:) name:YTBluetoothStateHasChangedNotification object:nil];
        
        _beaconManager = [YTBeaconManager sharedBeaconManager];
        _beaconManager.delegate = self;
        [_beaconManager startRangingBeacons];
        
    }
    return self;
}

-(void)viewDidLoad{
    UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    backgroundView.image = [UIImage imageNamed:@"nav_bg_pic.jpg"];
    [self.view addSubview:backgroundView];
    
    [self createNavigationBar];
    [self createMapView];
    [self createMarkView];
    [self createZoomStepper];
    [self createFunctionButton];
    [self createShadeView];
    [self createParkingButton];
    
    _userDefaults = [YTUserDefaults standardUserDefaults];
    CLLocationCoordinate2D coord = [_userDefaults coord];
    YTParkingState state;
    if (coord.latitude == MAXFLOAT && coord.longitude == MAXFLOAT) {
        _marked = NO;
        state = YTParkingStateNotMark;
    }else{
        _marked = YES;
        _carCoordinate = coord;
        state = YTParkingStateMarked;
    }
    
    if (_minorArea == nil || _bluetoothOn == NO) {
        _minorArea = nil;
        state = YTParkingStateNormal;
    }else{
        [self userMoveToMinorArea:_minorArea];
    }
    [self setParkingState:state animation:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _isReceivedMessage = YES;
}

-(void)createNavigationBar{
    _navigationBar = [[YTNavigationBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
    _navigationBar.backTitle = @"首页";
    _navigationBar.titleName = @"停车标记";
    _navigationBar.delegate = self;
    [_navigationBar changeSearchButton];
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    [window addSubview:_navigationBar];
}
-(void)backButtonClicked{
    [_navigationBar removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark mapView
-(void)createMapView{
    _mapView = [[YTMapView2 alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_navigationBar.frame), CGRectGetWidth(self.view.bounds) - 20, CGRectGetHeight(self.view.frame) - CGRectGetHeight(_navigationBar.frame) - 70)];
    _mapView.delegate = self;
    [_mapView setZoom:1.0 animated:YES];
    [self.view addSubview:_mapView];
}

-(void)mapView:(YTMapView2 *)mapView tapOnPoi:(YTPoi *)poi{
    
}

-(void)mapView:(YTMapView2 *)mapView singleTapOnMap:(CLLocationCoordinate2D)coordinate{
    
}

-(void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction{
    
}

#pragma mark zoomStepper
-(void)createZoomStepper{
    _zoomStepper = [[YTZoomStepper alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_mapView.frame) - 55, CGRectGetMaxY(_mapView.frame) - 80, 45, 70)];
    
    _zoomStepper.delegate = self;
    
    [self.view addSubview:_zoomStepper];
}

-(void)increasing{
    [_mapView zoomIn];
}

-(void)diminishing{
    [_mapView zoomOut];
}

-(void)createMarkView{
    _beforeMarkView = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_mapView.frame) + 10, CGRectGetWidth(_mapView.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(_mapView.frame) - 20)];
    [self.view addSubview:_beforeMarkView];
    
    _firstLabel =[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 70, 14)];
    [_beforeMarkView addSubview:_firstLabel];
    
    _firstSubLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_firstLabel.frame), CGRectGetMinY(_firstLabel.frame), 100, 14)];
    [_beforeMarkView addSubview:_firstSubLable];
    
    _secondLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firstLabel.frame), CGRectGetMaxY(_firstLabel.frame) + 5, CGRectGetWidth(_firstLabel.frame), CGRectGetHeight(_firstLabel.frame))];
    [_beforeMarkView addSubview:_secondLable];
    
    _secondSubLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_secondLable.frame), CGRectGetMinY(_secondLable.frame), CGRectGetWidth(_secondLable.frame), CGRectGetHeight(_secondLable.frame))];
    [_beforeMarkView addSubview:_secondSubLabel];
    
    _firstLabel.textColor = [UIColor colorWithString:@"969696"];
    _firstLabel.font = [UIFont systemFontOfSize:14];
    
    _firstSubLable.textColor = [UIColor whiteColor];
    _firstSubLable.font = _firstLabel.font;
    
    _secondLable.textColor = _firstLabel.textColor;
    _secondLable.font  = _firstLabel.font;
    
    _secondSubLabel.textColor = [UIColor colorWithString:@"e95e37"];
    _secondSubLabel.font = _firstLabel.font;
    
    _firstLabel.text = @"计费标准:";
    
    _firstSubLable.text = @"6元/时";
    
    _secondLable.text = @"剩余车位:";
    
    _secondSubLabel.text = @"25个";
    
    _cancelMarkedButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(_beforeMarkView.frame) - 75, 0, 75, 57)];
    _cancelMarkedButton.layer.cornerRadius = CGRectGetHeight(_cancelMarkedButton.frame) / 2;
    [_cancelMarkedButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelMarkedButton setBackgroundColor:[UIColor colorWithString:@"464646"]];
    _cancelMarkedButton.layer.borderWidth = 5;
    [_cancelMarkedButton addTarget:self action:@selector(clickcancelMarkedButton:) forControlEvents:UIControlEventTouchUpInside];
    [_beforeMarkView addSubview:_cancelMarkedButton];
    
    _starNavigationButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_cancelMarkedButton.frame) - CGRectGetWidth(_cancelMarkedButton.frame) - 5,0,CGRectGetWidth(_cancelMarkedButton.frame), CGRectGetHeight(_cancelMarkedButton.frame))];
    
    [_starNavigationButton setTitle:@"导航" forState:UIControlStateNormal];
    [_starNavigationButton setBackgroundColor:[UIColor colorWithString:@"0084ff"]];
    _starNavigationButton.layer.borderWidth = _cancelMarkedButton.layer.borderWidth;
    _starNavigationButton.layer.cornerRadius = CGRectGetHeight(_starNavigationButton.frame) / 2;
    [_starNavigationButton addTarget:self action:@selector(clickStarNavigationButton:) forControlEvents:UIControlEventTouchUpInside];
    [_beforeMarkView addSubview:_starNavigationButton];
    
    
}
-(void)createShadeView{
    _shadeView = [[UIView alloc]initWithFrame:CGRectMake(0,0, CGRectGetWidth(_navigationBar.frame), CGRectGetHeight(self.view.frame))];
    _shadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    [self.view addSubview:_shadeView];
}

-(void)clickcancelMarkedButton:(UIButton *)sender{
    YTMessageBox *messageBox = [[YTMessageBox alloc]initWithTitle:@"已经标记" Message:@"是否取消"];
    [messageBox show];
    [messageBox callBack:^(NSInteger tag) {
        if (tag == 1) {
            [_userDefaults removeCoord];
            _marked = NO;
            [self setParkingState:YTParkingStateNotMark animation:YES];
        }
    }];
}

-(void)clickStarNavigationButton:(UIButton *)sender{
    
}
#pragma mark parkingButton
-(void)createParkingButton{
    UIImage *parkingImage = [UIImage imageNamed:@"parking_img_mark_unable"];
    _parkingView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, parkingImage.size.width, parkingImage.size.height)];
    [_parkingView setEnabled:NO];
    [_parkingView setBackgroundImage:parkingImage forState:UIControlStateDisabled];
    [_parkingView setBackgroundImage:[UIImage imageNamed:@"parking_img_mark_un"] forState:UIControlStateNormal];
    [_parkingView setBackgroundImage:[UIImage imageNamed:@"parking_img_mark_pr"] forState:UIControlStateHighlighted];
    [_parkingView setTitle:@"标记车位" forState:UIControlStateNormal];
    [_parkingView.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_parkingView addTarget:self action:@selector(markedButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_parkingView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_parkingView setTitleEdgeInsets:UIEdgeInsetsMake(34, 0, 0, 0)];
    _parkingView.center = CGPointMake(self.view.center.x, self.view.center.y - 32);
    [self.view addSubview:_parkingView];
    
    _promptLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_parkingView.frame) * 1.9 , 32)];
    _promptLable.center = CGPointMake(self.view.center.x, CGRectGetMaxY(_parkingView.frame) + 15 + CGRectGetHeight(_promptLable.frame) / 2);
    _promptLable.lineBreakMode = NSLineBreakByWordWrapping;
    _promptLable.numberOfLines = 2;
    _promptLable.textColor = [UIColor colorWithString:@"c8c8c8"];
    _promptLable.font = [UIFont systemFontOfSize:13];
    _promptLable.text = @"检测到您为开蓝牙或不在商城内实时定位请到达商城后打开蓝牙";
    [self.view addSubview:_promptLable];
}
-(void)markedButtonClicked:(UIButton *)sender{
    _carCoordinate = [_minorArea coordinate];
    _marked = YES;
    [self setParkingState:YTParkingStateMarked animation:YES];
}

#pragma mark bluetoothState
-(void)blueStateChange:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    _bluetoothOn = [userInfo[@"isOpen"] boolValue];
    if(_isReceivedMessage){
        if (!_bluetoothOn && _minorArea != nil) {
            [self setParkingState:YTParkingStateNormal animation:YES];
        }else{
            if (_marked) {
                [self setParkingState:YTParkingStateMarked animation:YES];
            }else{
                [self setParkingState:YTParkingStateNotMark animation:YES];
            }
        }
    }
}

#pragma mark currentParking
-(void)createFunctionButton{
    _moveCurrentLocationButton = [[YTMoveCurrentLocationButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_mapView.frame) + 10,CGRectGetMaxY(_mapView.frame) - 50, 40, 40)];
    _moveCurrentLocationButton.delegate = self;
    [self.view addSubview:_moveCurrentLocationButton];
    
    _currentParkingButton = [[YTCurrentParkingButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_moveCurrentLocationButton.frame) + 10,CGRectGetMaxY(_mapView.frame) - 50, 40, 40)];
    _currentParkingButton.delegate = self;
    [self.view addSubview:_currentParkingButton];
}

-(void)moveToUserLocationButtonClicked{
    [_mapView setCenterCoordinate:[_minorArea coordinate] animated:YES];
}

-(void)moveCurrentParkingPositionClicked{
    CLLocationCoordinate2D target;
    if (_state == YTParkingStateMarked) {
        target = _carCoordinate;
    }else{
        target = [_minorArea coordinate];
    }
    [_mapView setCenterCoordinate:target animated:YES];
}

-(void)setParkingState:(YTParkingState)state animation:(BOOL)animation{
    CGFloat time = animation == YES ? 0.5:0;
    switch (state) {
        case YTParkingStateNormal:
            [self normalStateWithTime:time];
            break;
        case YTParkingStateMarked:
            [self markedStateWithTime:time];
            break;
        case YTParkingStateNotMark:
            [self notMarkStateWithTime:time];
            break;
    }
    
    _state = state;
    
}
-(void)normalStateWithTime:(CGFloat)time{
    if (!_isReceivedMessage) {
        if (!_marked) {
            [_parkingView setEnabled:YES];
            _moveCurrentLocationButton.hidden = YES;
            _cancelMarkedButton.alpha = 0;
            _starNavigationButton.alpha = 0;
            
            CGRect frame = _currentParkingButton.frame;
            frame.origin.x = CGRectGetMinX(_moveCurrentLocationButton.frame);
            _currentParkingButton.frame = frame;
        }
    }
    _shadeView.hidden = NO;
    _promptLable.hidden = NO;
    _parkingView.hidden = NO;
    [UIView animateWithDuration:time animations:^{
        _shadeView.alpha = 1;
        _promptLable.alpha = 1;
        _parkingView.alpha = 1;
    } completion:^(BOOL finished) {
        [_parkingView setEnabled:NO];
        [self parkingCurrentPoiShowInMap:NO];
    }];
}
-(void)markedStateWithTime:(CGFloat)time{
    _moveCurrentLocationButton.hidden = NO;
    
    if (_state != YTParkingStateNormal) _moveCurrentLocationButton.alpha = 0;
    [UIView animateWithDuration:time animations:^{
        CGRect frame = _currentParkingButton.frame;
        frame.origin.x = CGRectGetMaxX(_moveCurrentLocationButton.frame) + 10;
        _currentParkingButton.frame = frame;
        
        _moveCurrentLocationButton.alpha = 1;
        
        _parkingView.alpha = 0;
        _shadeView.alpha = 0;
        _promptLable.alpha = 0;
        _starNavigationButton.alpha = 1;
        _cancelMarkedButton.alpha = 1;
    } completion:^(BOOL finished) {
        [_userDefaults setCoord:_carCoordinate];
        [self parkingMarkedShowInMap:YES];
        [self parkingCurrentPoiShowInMap:YES];
        _shadeView.hidden = YES;
        _promptLable.hidden = YES;
    }];
}
-(void)notMarkStateWithTime:(CGFloat)time{
    [UIView animateWithDuration:time animations:^{
        _shadeView.alpha = 0;
        _promptLable.alpha = 0;
        _parkingView.alpha = 1;
        _starNavigationButton.alpha = 0;
        _cancelMarkedButton.alpha = 0;
        
        CGRect frame = _currentParkingButton.frame;
        frame.origin.x = CGRectGetMinX(_moveCurrentLocationButton.frame);
        _currentParkingButton.frame = frame;
        
    } completion:^(BOOL finished) {
        _shadeView.hidden = YES;
        _promptLable.hidden = YES;
        [_parkingView setEnabled:YES];
        _moveCurrentLocationButton.hidden = YES;
        [_userDefaults removeCoord];
        [self parkingMarkedShowInMap:NO];
        [self parkingCurrentPoiShowInMap:YES];
    }];
}

-(void)parkingMarkedShowInMap:(BOOL)show{
    if (show){
        _poiMarked = [[YTParkingMarkPoi alloc]initWithParkingMarkCoordinat:_carCoordinate];
        [_mapView addPoi:_poiMarked];
        [_mapView highlightPoi:_poiMarked animated:NO];
    }else{
        if(_poiMarked == nil) return;
        [_mapView hidePoi:_poiMarked animated:NO];
        [_mapView removeAnnotationForPoi:_poiMarked];
        _poiMarked = nil;
    }
}

-(void)parkingCurrentPoiShowInMap:(BOOL)show{
    if (show) {
        [_mapView highlightPoi:_currenPoi animated:YES];
    }else{
        [_mapView hidePoi:_currenPoi animated:YES];
    }
}

#pragma mark BeaconManager
-(void)primaryBeaconShiftedTo:(ESTBeacon *)beacon{
    if (_isReceivedMessage){
        id<YTMinorArea> tmpMinorArea =  [self getMinorArea:beacon];
        
        if (![[tmpMinorArea identifier]isEqualToString:[_minorArea identifier]] || _minorArea == nil) {
            _minorArea = tmpMinorArea;
            if (_state == YTParkingStateNormal) {
                if (_marked) {
                    [self setParkingState:YTParkingStateMarked animation:YES];
                }else{
                    [self setParkingState:YTParkingStateNotMark animation:YES];
                }
            }
            [self userMoveToMinorArea:tmpMinorArea];
        }
    }
}

-(void)noBeaconsFound{
    
}


-(void)userMoveToMinorArea:(id<YTMinorArea>)minorArea{
    if (_currenPoi == nil) {
        _currenPoi = [[YTParkingPoi alloc]initWithParkingCoordinat:[_minorArea coordinate]];
        [_mapView addPoi:_currenPoi];
        [_mapView highlightPoi:_currenPoi animated:YES];
    }else{
        [_mapView hidePoi:_currenPoi animated:YES];
        [_mapView removeAnnotationForPoi:_currenPoi];
        _currenPoi = nil;
        
        _currenPoi = [[YTParkingPoi alloc]initWithParkingCoordinat:[minorArea coordinate]];
        [_mapView addPoi:_currenPoi];
        [_mapView highlightPoi:_currenPoi animated:YES];
    }
}

-(id<YTMinorArea>)getMinorArea:(ESTBeacon *)beacon{
    
    FMDatabase *db = [YTDBManager sharedManager];
    [db open];
    FMResultSet *result = [db executeQuery:@"select * from Beacon where major = ? and minor = ?",[beacon.major stringValue],[beacon.minor stringValue]];
    [result next];
    YTLocalBeacon *localBeacon = [[YTLocalBeacon alloc] initWithDBResultSet:result];
    
    YTLocalMinorArea * minorArea = [localBeacon minorArea];
    return minorArea;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)dealloc{
    NSLog(@"parking Dealloc");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:YTBluetoothStateHasChangedNotification object:nil];
}
@end
