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
    UIButton *_parkingView;
    UILabel *_promptLable;
    YTBluetoothManager *_bluetoothManager;
    YTCurrentParkingButton *_currentParkingButton;
    YTMoveCurrentLocationButton *_moveCurrentLocationButton;
    BOOL _bluetoothOn;
    CLLocationCoordinate2D _userCoordinate;
    CLLocationCoordinate2D _carCoordinate;
    YTParkingMarkPoi *_poiMarked;
    YTParkingPoi *_currenPoi;
    YTUserDefaults *_userDefaults;
    YTParkingState _state;
}

-(instancetype)initWithMinorArea:(id<YTMinorArea>)minorArea{
    self = [super init];
    if (self) {
        _minorArea = minorArea;
        _bluetoothManager = [YTBluetoothManager shareBluetoothManager];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(blueStateChange:) name:YTBluetoothStateHasChangedNotification object:nil];
        [_bluetoothManager refreshBluetoothState];
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
    /*
    if (_minorArea == nil || _bluetoothOn == NO) {
        [self setParkingState:YTParkingStateNormal animation:NO];
        return ;
    }else{
        _userCoordinate = [_minorArea coordinate];
        _currenPoi = [[YTParkingPoi alloc]initWithParkingCoordinat:_userCoordinate];
        [_mapView addPoi:_currenPoi];
        [_mapView highlightPoi:_currenPoi animated:NO];
    }
    */
    _userDefaults = [YTUserDefaults standardUserDefaults];
    CLLocationCoordinate2D coord = [_userDefaults coord];
    if (coord.latitude == MAXFLOAT && coord.longitude == MAXFLOAT) {
        [self setParkingState:YTParkingStateNotMark animation:NO];
    }else{
        _carCoordinate = coord;
        [self setParkingState:YTParkingStateMarked animation:NO];
    }
    _userCoordinate = [_minorArea coordinate];
    _currenPoi = [[YTParkingPoi alloc]initWithParkingCoordinat:_userCoordinate];
    [_mapView addPoi:_currenPoi];
    [_mapView highlightPoi:_currenPoi animated:NO];
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
}
-(void)createShadeView{
    _shadeView = [[UIView alloc]initWithFrame:CGRectMake(0,0, CGRectGetWidth(_navigationBar.frame), CGRectGetHeight(self.view.frame))];
    _shadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    [self.view addSubview:_shadeView];
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
    _carCoordinate = _userCoordinate;
    [self setParkingState:YTParkingStateMarked animation:YES];
}

#pragma mark bluetoothState
-(void)blueStateChange:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    _bluetoothOn = [userInfo[@"isOpen"] boolValue];
    if (_bluetoothOn && _minorArea != nil) {
        
    }else{
        
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
    [_mapView setCenterCoordinate:_userCoordinate animated:YES];
}

-(void)moveCurrentParkingPositionClicked{
    CLLocationCoordinate2D target;
    if (_state == YTParkingStateMarked) {
        target = _carCoordinate;
    }else{
        target = _userCoordinate;
    }
    [_mapView setCenterCoordinate:target animated:YES];
}

-(void)setParkingState:(YTParkingState)state animation:(BOOL)animation{
    CGFloat time = animation == YES ? 0.5:0;
    switch (state) {
        case YTParkingStateNormal:
        {
            _shadeView.hidden = NO;
            _promptLable.hidden = NO;
            _parkingView.hidden = NO;
            [UIView animateWithDuration:time animations:^{
                _shadeView.alpha = 1;
                _promptLable.alpha = 1;
                _parkingView.alpha = 1;
            } completion:^(BOOL finished) {
                [_parkingView setEnabled:NO];
            }];
        }
            break;
        case YTParkingStateMarked:
        {
            _moveCurrentLocationButton.hidden = NO;
            _moveCurrentLocationButton.alpha = 0;
            [UIView animateWithDuration:time animations:^{
                CGRect frame = _currentParkingButton.frame;
                frame.origin.x = CGRectGetMaxX(_moveCurrentLocationButton.frame) + 10;
                _currentParkingButton.frame = frame;
    
                _moveCurrentLocationButton.alpha = 1;
                
                 _parkingView.alpha = 0;
                _shadeView.alpha = 0;
                _promptLable.alpha = 0;
            } completion:^(BOOL finished) {
                [_userDefaults setCoord:_carCoordinate];
                [self parkingMarkedShowInMap:YES];
                _shadeView.hidden = YES;
                _promptLable.hidden = YES;
            }];
        }
            break;
        case YTParkingStateNotMark:
        {
            [UIView animateWithDuration:time animations:^{
                _shadeView.alpha = 0;
                _promptLable.alpha = 0;
                _parkingView.alpha = 1;
                
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
            }];
        }
            break;
    }
    
    _state = state;
    
}
-(void)parkingMarkedShowInMap:(BOOL)show{
    if (show){
        _poiMarked = [[YTParkingMarkPoi alloc]initWithParkingMarkCoordinat:_carCoordinate];
        [_mapView addPoi:_poiMarked];
        [_mapView highlightPoi:_poiMarked animated:NO];
    }else{
        [_mapView hidePoi:_poiMarked animated:NO];
        [_mapView removeAnnotationForPoi:_poiMarked];
        _poiMarked = nil;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)dealloc{
    NSLog(@"parking Dealloc");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:YTBluetoothStateHasChangedNotification object:nil];
}
@end
