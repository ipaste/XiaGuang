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
    
    YTMajorAreaVoter *_voter;
    id<YTMinorArea> _userMinorArea;
    id<YTMajorArea> _currenDisplayMajorArea;
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
    BOOL _initializationComplete;
    
    CLLocationCoordinate2D _carCoordinate;
    
    id<YTParkingMarked> _tmpMarker;
    YTParkingState _state;
    YTBeaconManager *_beaconManager;
    YTNavigationView *_navigationView;
    YTNavigationModePlan *_navigationModePlan;
    YTBeaconBasedLocator *_locator;
    
    NSMutableArray *_beacons;
    
    UIImage *_parkingImageUnable;
    UIImage *_parkingImageUn;
    UIImage *_parkingImagePr;
    
    
    CLLocationCoordinate2D _userCoordintate;
    NSTimer *_timer;
    BOOL _shownUser;
    id<YTMajorArea> _locatorMajorArea;
}

-(instancetype)initWithMinorArea:(id<YTMinorArea>)minorArea{
    self = [super init];
    if (self) {
        if ([[minorArea majorArea]isParking]) {
            _userMinorArea = minorArea;
        }
        _initializationComplete = NO;
        _bluetoothManager = [YTBluetoothManager shareBluetoothManager];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(bluetoothStateChange:) name:YTBluetoothStateHasChangedNotification object:nil];

        _shownUser = NO;
        
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    _voter = [YTMajorAreaVoter sharedInstance];
    _beaconManager = [YTBeaconManager sharedBeaconManager];
    _beaconManager.delegate = self;
    [_beaconManager startRangingBeacons];
    [super viewDidAppear:animated];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [AVAnalytics beginLogPageView:@"parkingViewController"];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [AVAnalytics endLogPageView:@"parkingViewController"];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    backgroundView.image = [UIImage imageNamed:@"nav_bg_pic.jpg"];
    [self.view addSubview:backgroundView];
    _userCoordintate = CLLocationCoordinate2DMake(-888, -888);
    
    [self createNavigationBar];
    [self createMapView];
    [self createMarkView];
    [self createZoomStepper];
    [self createFunctionButton];
    [self createNavigationView];
    [self createShadeView];
    [self createParkingButton];
    [self.view addSubview:_navigationBar];
    
    _tmpMarker = [YTLocalParkingMarked standardParking];
    YTParkingState state;
    if (![_tmpMarker whetherMark]) {
        state = YTParkingStateNotMark;
    }else{
        _carCoordinate = [_tmpMarker coordinate];
        state = YTParkingStateMarked;
    }
    
    if (_userMinorArea == nil || _bluetoothOn == NO || ![[_userMinorArea majorArea] isParking]) {
        _userMinorArea = nil;
         state = YTParkingStateNormal;
        if ([_tmpMarker whetherMark]) {
            state = YTParkingStateMarked;
        }
    }else{
        [self userMoveToMinorArea:_userMinorArea];
    }
    [self setParkingState:state animation:NO];
    
    _beacons = [NSMutableArray array];
    _initializationComplete = YES;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_timer invalidate];
    _timer = nil;
}

-(void)createNavigationBar{
    _navigationBar = [[YTNavigationBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
    _navigationBar.backTitle = @"首页";
    _navigationBar.titleName = @"停车标记";
    _navigationBar.delegate = self;
    [_navigationBar changeSearchButton];
}

-(void)backButtonClicked{
    if (_navigationView.isNavigating) {
        YTMessageBox *box = [[YTMessageBox alloc]initWithTitle:@"导航进行中" Message:@"您已处于目的地附近，导航结束"] ;
        [box show];
        [box callBack:^(NSInteger tag) {
            if (tag == 1) {
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}
#pragma mark mapView
-(void)createMapView{
    _mapView = [[YTMapView2 alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_navigationBar.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.frame) - CGRectGetHeight(_navigationBar.frame))];
    _mapView.delegate = self;
    //[_mapView displayMapNamed:@"haianchengparking1"];
    if(_userMinorArea != nil){
        [self displayMapWithMajorArea:[_userMinorArea majorArea]];
    }
    else{
        [self displayMapWithMajorArea:[self getDefaultMajorArea]];
    }
    
    [self refreshLocatorIfNeeded];
    [_mapView setZoom:1.0 animated:YES];
    [self.view addSubview:_mapView];
   // [_mapView removeAnnotations];
}

-(id<YTMajorArea>)getDefaultMajorArea{
    FMDatabase *db = [YTDataManager defaultDataManager].database;
    [db open];
    FMResultSet *result = [db executeQuery:@"select * from MajorArea where isParking = 1"];
    [result next];
    YTLocalMajorArea *majorArea = [[YTLocalMajorArea alloc] initWithDBResultSet:result];
    
    return majorArea;
}


-(void)mapView:(YTMapView2 *)mapView tapOnPoi:(YTPoi *)poi{
    
}

-(void)mapView:(YTMapView2 *)mapView singleTapOnMap:(CLLocationCoordinate2D)coordinate{
    
}

-(void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction{
    
}

#pragma mark zoomStepper
-(void)createZoomStepper{
    _zoomStepper = [[YTZoomStepper alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_mapView.frame) - 55, CGRectGetMaxY(_mapView.frame) - 80 - 110, 41, 95)];
    
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
    _beforeMarkView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_mapView.frame) - 80, CGRectGetWidth(_mapView.frame), 80)];
    _beforeMarkView.backgroundColor = [UIColor colorWithString:@"000000" alpha:0.6];
    [self.view addSubview:_beforeMarkView];
    
    _firstLabel =[[UILabel alloc]initWithFrame:CGRectMake(18, 21, 70, 14)];
    [_beforeMarkView addSubview:_firstLabel];
    
    _firstSubLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_firstLabel.frame), CGRectGetMinY(_firstLabel.frame) , 100, 14)];
    [_beforeMarkView addSubview:_firstSubLable];
    
    _secondLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firstLabel.frame), CGRectGetMaxY(_firstLabel.frame) + 13, CGRectGetWidth(_firstLabel.frame), CGRectGetHeight(_firstLabel.frame))];
    [_beforeMarkView addSubview:_secondLable];
    
    _secondSubLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_secondLable.frame), CGRectGetMinY(_secondLable.frame), CGRectGetWidth(_secondLable.frame), CGRectGetHeight(_secondLable.frame))];
    [_beforeMarkView addSubview:_secondSubLabel];
    
    _firstLabel.textColor = [UIColor colorWithString:@"cccccc"];
    _firstLabel.font = [UIFont systemFontOfSize:14];
    
    _firstSubLable.textColor = [UIColor colorWithString:@"f3b64b"];
    _firstSubLable.font = [UIFont systemFontOfSize:15];
    
    _secondLable.textColor = _firstLabel.textColor;
    _secondLable.font  = _firstLabel.font;
    
    _secondSubLabel.textColor = [UIColor colorWithString:@"f3b64b"];
    _secondSubLabel.font = _firstLabel.font;
    
    _cancelMarkedButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_mapView.frame) - 68, 15, 50, 50)];
    [_cancelMarkedButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelMarkedButton setBackgroundImage:[UIImage imageNamed:@"btn_gray"] forState:UIControlStateNormal];
    [_cancelMarkedButton addTarget:self action:@selector(clickcancelMarkedButton:) forControlEvents:UIControlEventTouchUpInside];
    [_beforeMarkView addSubview:_cancelMarkedButton];
    
    _starNavigationButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_cancelMarkedButton.frame) - CGRectGetWidth(_cancelMarkedButton.frame) - 18,15,CGRectGetWidth(_cancelMarkedButton.frame), CGRectGetHeight(_cancelMarkedButton.frame))];
    
    [_starNavigationButton setTitle:@"导航" forState:UIControlStateNormal];
    [_starNavigationButton setBackgroundImage:[UIImage imageNamed:@"btn_orange"] forState:UIControlStateNormal];
    [_starNavigationButton addTarget:self action:@selector(clickStarNavigationButton:) forControlEvents:UIControlEventTouchUpInside];
    [_beforeMarkView addSubview:_starNavigationButton];
    
    [self changeLabel:_state];
    
}
-(void)createShadeView{
    _shadeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_navigationBar.frame), CGRectGetHeight(self.view.frame))];
    _shadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    [self.view addSubview:_shadeView];
}

-(void)clickcancelMarkedButton:(UIButton *)sender{
    YTMessageBox *messageBox = [[YTMessageBox alloc]initWithTitle:@"已经标记" Message:@"取消停车标记将清除您的爱车位置，确定取消吗？"];
    [messageBox show];
    [messageBox callBack:^(NSInteger tag) {
        if (tag == 1) {
            [self setParkingState:YTParkingStateNotMark animation:YES];
        }
    }];
}

-(void)clickStarNavigationButton:(UIButton *)sender{
    if (_userMinorArea == nil || ![[_userMinorArea majorArea] isParking]) {
        [[[YTMessageBox alloc]initWithTitle:@"" Message:@"请处于停车场中并开启蓝牙功能，以支持室内定位" cancelButtonTitle:@"确定"] show];
        return;
    }
    
    _navigationView.hidden = NO;
    [_navigationView startNavigationAndSetDestination:_tmpMarker];
    _navigationModePlan = [[YTNavigationModePlan alloc]initWithTargetPoiSource:_tmpMarker];
    _navigationView.plan = _navigationModePlan;
    [self updateNavManagerIfNeeded];
    
    [UIView animateWithDuration:.2 animations:^{
        CGRect frame = _navigationView.frame;
        frame.origin.x = 0;
        _navigationView.frame = frame;
        
        _beforeMarkView.alpha = 0;
    } completion:^(BOOL finished) {
//        [_navigationView.layer pop_removeAllAnimations];
//        POPSpringAnimation *animation = [POPSpringAnimation animation];
//        animation.property = [POPAnimatableProperty propertyWithName:kPOPLayerPositionX];
//        animation.velocity = @1000;
//        animation.springBounciness = 20;
//        [_navigationView.layer pop_addAnimation:animation forKey:@"shake"];
    }];
    
}
#pragma mark parkingButton
-(void)createParkingButton{
    _parkingImageUnable = [UIImage imageNamed:@"parking_img_markUnable"];
    _parkingImagePr = [UIImage imageNamed:@"parking_img_mark_On"];
    _parkingImageUn = [UIImage imageNamed:@"parking_img_mark"];
    
    _parkingView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _parkingImageUn.size.width, _parkingImageUn.size.height)];
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
    _promptLable.text = @"检测到您未开蓝牙或不在商城内,实时定位请到达商城后打开蓝牙";
    [self.view addSubview:_promptLable];
}

-(void)markedButtonClicked:(UIButton *)sender{
    if (_userMinorArea == nil){
        
        return;
    }
    if(_userCoordintate.latitude != -888){
        _carCoordinate = _userCoordintate;
    }
    else{
        _carCoordinate = [_userMinorArea coordinate];
    }
    [self setParkingState:YTParkingStateMarked animation:YES];
}

#pragma mark bluetoothState
-(void)bluetoothStateChange:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    _bluetoothOn = [userInfo[@"isOpen"] boolValue];
    _userMinorArea = nil;
    if(_initializationComplete && _state != YTParkingStateMarked){
        if (!_bluetoothOn || ![[_userMinorArea majorArea] isParking] || ![_tmpMarker whetherMark]) {
            [self setParkingState:YTParkingStateNormal animation:NO];
        }else{
            if ([_tmpMarker whetherMark]) {
                [self setParkingState:YTParkingStateMarked animation:NO];
            }else{
                [self setParkingState:YTParkingStateNotMark animation:NO];
            }
        }
    }
}
#pragma mark navigationView
-(void)createNavigationView{
    _navigationView = [[YTNavigationView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 80 , CGRectGetWidth(self.view.frame), 80)];
    _navigationView.isShowSwitchButton = NO;
    _navigationView.delegate = self;
    _navigationView.hidden = YES;
    [self.view addSubview:_navigationView];
  //  [_navigationView.layer pop_animationForKey:@"shake"];
}

-(void)stopNavigationMode{
    _navigationView.alpha = 0.0f;
    [UIView animateWithDuration:.5 animations:^{
        _beforeMarkView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        CGRect frame = _navigationView.frame;
        frame.origin.x = CGRectGetWidth(self.view.frame);
        _navigationView.frame = frame;
        _navigationView.alpha = 1.0f;
        _navigationView.hidden = YES;
    }];
}

-(void)jumToUserFloor{
    _navigationView.isShowSwitchButton = NO;
    [self displayMapWithMajorArea:[_userMinorArea majorArea]];
    [self refreshLocatorIfNeeded];
}

#pragma mark currentParking
-(void)createFunctionButton{
    _moveCurrentLocationButton = [[YTMoveCurrentLocationButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_mapView.frame) + 10,CGRectGetMaxY(_mapView.frame) - 80 - 55, 40, 40)];
    _moveCurrentLocationButton.delegate = self;
    [self.view addSubview:_moveCurrentLocationButton];
    
    _currentParkingButton = [[YTCurrentParkingButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_moveCurrentLocationButton.frame) + 10,CGRectGetMaxY(_mapView.frame) - 80 - 55, 40, 40)];
    _currentParkingButton.delegate = self;
    [self.view addSubview:_currentParkingButton];
}

-(void)moveToUserLocationButtonClicked{
    if (_userMinorArea == nil || ![[_userMinorArea majorArea] isParking]) {
        [[[YTMessageBox alloc]initWithTitle:@"" Message:@"请处于停车场中并开启蓝牙功能，以支持室内定位" cancelButtonTitle:@"确定"] show];
        return;
    }
    
    if (![[_currenDisplayMajorArea identifier]isEqualToString:[[_userMinorArea majorArea] identifier]]) {
        [self displayMapWithMajorArea:[_userMinorArea majorArea]];
    }
    [self refreshLocatorIfNeeded];
    if (_userCoordintate.latitude == -888) {
        _userCoordintate = [_userMinorArea coordinate];
    }
    [_mapView setCenterCoordinate:_userCoordintate animated:YES];
}

-(void)moveCurrentParkingPositionClicked{
    CLLocationCoordinate2D target;
    if (_state == YTParkingStateMarked) {
        target = [_tmpMarker coordinate];
        if (![[[_tmpMarker majorArea] identifier] isEqualToString:[_currenDisplayMajorArea identifier]]) {
            [self displayMapWithMajorArea:[_tmpMarker majorArea]];
            
        }
        [_mapView setCenterCoordinate:target animated:YES];
    }else{
        [self moveToUserLocationButtonClicked];
    }
    
}

-(void)setParkingState:(YTParkingState)state animation:(BOOL)animation{
    switch (state) {
        case YTParkingStateNormal:
            [_timer invalidate];
            _timer = nil;
            if (![_tmpMarker whetherMark]) {
                [self notMarkStateWithAnimation:animation];
            }else{
                [self markedStateWithAnimation:animation];
            }
            [self normalStateWithAnimation:animation];
            
            break;
        case YTParkingStateMarked:
            if (![_tmpMarker whetherMark]) {
                [_tmpMarker saveParkingInfoWithCoordinate:_carCoordinate inMinorArea:_userMinorArea];
            }
            if (![[_currenDisplayMajorArea identifier] isEqualToString:[[_tmpMarker majorArea] identifier]]) {
                [self displayMapWithMajorArea:[_tmpMarker majorArea]];
            }else{
                [self parkingMarkedShowInMap:YES];
            }
            _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateParkingChargeLabel:) userInfo:nil repeats:YES];
            [self markedStateWithAnimation:animation];
            break;
        case YTParkingStateNotMark:
            [_timer invalidate];
            _timer = nil;
            [self parkingCurrentPoiShowInMap:YES animation:animation];
            if (![[_currenDisplayMajorArea identifier]isEqualToString:[[_userMinorArea majorArea] identifier]]) {
                [self displayMapWithMajorArea:[_userMinorArea majorArea]];
            }
             [self parkingCurrentPoiShowInMap:YES animation:animation];
            if ([_tmpMarker whetherMark]) {
                [self parkingMarkedShowInMap:NO];
                [_tmpMarker clearParkingInfo];
            }
            [self notMarkStateWithAnimation:animation];
            if (_userMinorArea == nil || ![[_userMinorArea majorArea] isParking]) {
                [self normalStateWithAnimation:animation];
            }
            break;
    }
    
    _state = state;
    
}
-(void)normalStateWithAnimation:(BOOL)animation{
    if (animation) {
        [UIView animateWithDuration:0.5 animations:^{
            _shadeView.alpha = 1;
            _promptLable.alpha = 1;
            _parkingView.alpha = 1;
            [_parkingView setBackgroundImage:_parkingImageUnable forState:UIControlStateNormal];
            [_parkingView setBackgroundImage:_parkingImageUnable forState:UIControlStateHighlighted];
        } completion:^(BOOL finished) {
            [self parkingCurrentPoiShowInMap:NO animation:NO];
        }];
    }else{
        _shadeView.alpha = 1;
        _promptLable.alpha = 1;
        _parkingView.alpha = 1;
        [_parkingView setBackgroundImage:_parkingImageUnable forState:UIControlStateNormal];
        [_parkingView setBackgroundImage:_parkingImageUnable forState:UIControlStateHighlighted];
        [self parkingCurrentPoiShowInMap:NO animation:NO];
    }
}
-(void)markedStateWithAnimation:(BOOL)animation{
    
    [self changeLabel:YTParkingStateMarked];
    if (animation) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = _currentParkingButton.frame;
            frame.origin.x = CGRectGetMaxX(_moveCurrentLocationButton.frame) + 10;
            _currentParkingButton.frame = frame;
            
            _moveCurrentLocationButton.alpha = 1;
            _parkingView.alpha = 0;
            _shadeView.alpha = 0;
            _promptLable.alpha = 0;
            _starNavigationButton.alpha = 1;
            _cancelMarkedButton.alpha = 1;
        }];
    }else{
        CGRect frame = _currentParkingButton.frame;
        frame.origin.x = CGRectGetMaxX(_moveCurrentLocationButton.frame) + 10;
        _currentParkingButton.frame = frame;
        
        _parkingView.alpha = 0;
        _shadeView.alpha = 0;
        _promptLable.alpha = 0;
        _starNavigationButton.alpha = 1;
        _cancelMarkedButton.alpha = 1;
        
    }
    
}
-(void)notMarkStateWithAnimation:(BOOL)animation{
    [self changeLabel:YTParkingStateNotMark];
    [_parkingView setBackgroundImage:_parkingImageUn forState:UIControlStateNormal];
    [_parkingView setBackgroundImage:_parkingImagePr forState:UIControlStateHighlighted];
    
    if (animation) {
        [UIView animateWithDuration:0.5 animations:^{
            _shadeView.alpha = 0;
            _promptLable.alpha = 0;
            _parkingView.alpha = 1;
            _starNavigationButton.alpha = 0;
            _cancelMarkedButton.alpha = 0;
            _moveCurrentLocationButton.alpha = 0;
            
            CGRect frame = _currentParkingButton.frame;
            frame.origin.x = CGRectGetMinX(_moveCurrentLocationButton.frame);
            _currentParkingButton.frame = frame;
            
        }];
    }else{
        _shadeView.alpha = 0;
        _promptLable.alpha = 0;
        _parkingView.alpha = 1;
        _starNavigationButton.alpha = 0;
        _cancelMarkedButton.alpha = 0;
        _moveCurrentLocationButton.alpha = 0;
        
        CGRect frame = _currentParkingButton.frame;
        frame.origin.x = CGRectGetMinX(_moveCurrentLocationButton.frame);
        _currentParkingButton.frame = frame;
    }
    
}

-(void)parkingMarkedShowInMap:(BOOL)show{
    YTPoi *tmpPoi = [_tmpMarker producePoi];
    if (show){
        [_mapView addPoi:tmpPoi];
        [_mapView highlightPoi:tmpPoi animated:YES];
    }else{
        if(tmpPoi == nil) return;
        if ([_tmpMarker whetherMark]) {
            [_mapView removeAnnotationForPoi:tmpPoi];
        }
    }
}

-(void)parkingCurrentPoiShowInMap:(BOOL)show animation:(BOOL)animation{
    if (show && [[_userMinorArea majorArea] isParking]) {
        
        [self showUserAtCoordinate:_userCoordintate];
        
    }else{
        [_mapView removeUserLocation];
        _shownUser = NO;

    }
}


-(void)showUserAtCoordinate:(CLLocationCoordinate2D)coordinate{
    if(_shownUser){
        if(coordinate.latitude == -888){
            [_mapView setUserCoordinate:[_userMinorArea coordinate]];
        }
        else
        {
            [_mapView setUserCoordinate:_userCoordintate];
        }
    }
    else{
        if(coordinate.latitude == -888){
            [_mapView showUserLocationAtCoordinate:[_userMinorArea coordinate]];
        }
        else
        {
            [_mapView showUserLocationAtCoordinate:_userCoordintate];
        }
        _shownUser = YES;
    }
}

#pragma mark BeaconManager
-(void)moveToBeacon:(ESTBeacon *)beacon{
    
    id<YTMinorArea> tmpMinorArea =  [self getMinorArea:beacon];
    if (![[tmpMinorArea majorArea] isParking] || tmpMinorArea == nil){
        if ([[[[[[_userMinorArea majorArea]floor]block]mall]identifier] isEqualToString:[[[[[tmpMinorArea majorArea] floor] block] mall] identifier]]) {
            [[[YTMessageBox alloc]initWithTitle:@"虾逛提示" Message:[NSString stringWithFormat:@"您已经走出了停车场"] cancelButtonTitle:@"知道了"]show];
        }
        if (_shownUser == YES) {
            [_mapView removeUserLocation];
            _shownUser = NO;
        }
        _userMinorArea = nil;
        return;
    }
    
    if (![[tmpMinorArea identifier]isEqualToString:[_userMinorArea identifier]] || _userMinorArea == nil) {
        _userMinorArea = tmpMinorArea;
        if (_state == YTParkingStateNormal) {
            if ([_tmpMarker whetherMark]) {
                [self setParkingState:YTParkingStateMarked animation:YES];
            }else{
                [self setParkingState:YTParkingStateNotMark animation:YES];
            }
        }
//        if (_initializationComplete){
//            [self userMoveToMinorArea:tmpMinorArea];
//        }
    }
    
}

-(void)rangedObjects:(NSArray *)objects{
    
    if(objects.count <= 0){
        return;
    }
    
    NSMutableArray *beacons = [NSMutableArray array];
    for (NSDictionary *beaconDict in objects) {
        [beacons addObject:beaconDict[@"Beacon"]];
    }
    
    NSString *votedMajorAreaId = [_voter shouldSwitchToMajorAreaId:objects];
    
    ESTBeacon *bestGuessBeacon = [self topBeaconWithInMajorAreaId:votedMajorAreaId inBeacons:beacons];
    if(bestGuessBeacon == nil){
        return;
    }
    
    [self moveToBeacon:bestGuessBeacon];
}

-(ESTBeacon *)topBeaconWithInMajorAreaId:(NSString *)majorAreaId
                                      inBeacons:(NSArray *)beacons
{
    
    for(ESTBeacon *tmp in beacons){
        id<YTMinorArea> minor = [self getMinorArea:tmp];
        if([[[minor majorArea] identifier] isEqualToString:majorAreaId]){
            return tmp;
        }
    }
    return nil;
    
}

-(void)noBeaconsFound{
    
}

-(void)refreshLocatorIfNeeded{
    if([[[_userMinorArea majorArea] identifier] isEqualToString:[_currenDisplayMajorArea identifier]]){
        
        [self refreshLocatorWithMapView:_mapView.map majorArea:_currenDisplayMajorArea];
    }
    else{
        _locator = nil;
        [_beaconManager removeListener:_locator];
        _shownUser = NO;
        [_mapView removeUserLocation];
        
    }
}
-(void)userMoveToMinorArea:(id<YTMinorArea>)minorArea{
    
    _navigationBar.titleName = [[[[[minorArea majorArea] floor] block] mall] mallName];
    
    if(_currenDisplayMajorArea == nil || ![[_currenDisplayMajorArea identifier] isEqualToString:[[minorArea majorArea]identifier]]){
        [self displayMapWithMajorArea:[minorArea majorArea]];
    }
    
    [self refreshLocatorIfNeeded];
    
    
    
    BOOL showCurrenPoi = NO;
    if ([[_currenDisplayMajorArea identifier]isEqualToString:[[minorArea majorArea] identifier]]) {
        showCurrenPoi = YES;
    }else{
        if (_navigationView.isNavigating) {
            _navigationView.isShowSwitchButton = YES;
        }else{
            [_moveCurrentLocationButton promptFloorChange:[[[minorArea majorArea]floor] floorName]];
        }
    }
    [self parkingCurrentPoiShowInMap:showCurrenPoi animation:YES];
    [self updateNavManagerIfNeeded];
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

-(void)updateNavManagerIfNeeded{
    
    if(_navigationView.isNavigating == YES){
        double distance = [_mapView canonicalDistanceFromCoordinate1:_userCoordintate toCoordinate2:[_navigationModePlan.targetPoiSource coordinate]];
        [_navigationModePlan updateWithCurrentUserMinorArea:_userMinorArea distanceToTarget:distance andDisplayedMajorArea:_currenDisplayMajorArea];
        
        [_navigationView updateInstruction];
    }
}

-(void)displayMapWithMajorArea:(id<YTMajorArea>)majorArea{
    
    [_mapView displayMapNamed:[majorArea mapName]];

    if([[[_userMinorArea majorArea] identifier] isEqualToString:[majorArea identifier]]){
        
        [self refreshLocatorWithMapView:_mapView.map majorArea:majorArea];
    }
    else{
        _locator = nil;
        [_beaconManager removeListener:_locator];
        _shownUser = NO;
        [_mapView removeUserLocation];
        
    }
     /*

    if (_beacons.count > 0) {
        [_mapView removePois:_beacons];
        [_beacons removeAllObjects];
    }

    for (id<YTMinorArea> tmpMinorArea in [majorArea minorAreas]) {
        YTBeaconPosistionPoi *poi = [[YTBeaconPosistionPoi alloc]initWithParkingMarkCoordinat:[tmpMinorArea coordinate] minor:tmpMinorArea];
        [_beacons addObject:poi];
        [_mapView addPoi:poi];
    }
      */
    
    
    if ([[majorArea identifier]isEqualToString:[[_userMinorArea majorArea] identifier]]) {
        [self parkingCurrentPoiShowInMap:YES animation:NO];
    }else{
        [self parkingCurrentPoiShowInMap:NO animation:NO];
    }
    
    if ([[[_tmpMarker majorArea] identifier] isEqualToString:[majorArea identifier]]) {
        [self parkingMarkedShowInMap:YES];
    }else{
        [self parkingMarkedShowInMap:NO];
    }
    
    if (_navigationView.isNavigating) {
        if ([[_currenDisplayMajorArea identifier]isEqualToString:[[_tmpMarker majorArea] identifier]]) {
            _navigationView.isShowSwitchButton = NO;
        }
    }
    _currenDisplayMajorArea = majorArea;
}

-(void)changeLabel:(YTParkingState)state{
    if (state == YTParkingStateMarked) {
        _firstLabel.text = @"停车计时:";
        
        _firstSubLable.text = [self stringWithTime:[_tmpMarker parkingDuration]];
        
        _secondLable.text = @"实时计费:";
        
        _secondSubLabel.text = [self chargeWithTime:[_tmpMarker parkingDuration]];
        
    }else{
        _firstLabel.text = @"计费标准:";
        
        _firstSubLable.text = @"6元/时";
        
        _secondLable.text = @"";
        
        _secondSubLabel.text = @"";
    }
}

-(void)updateParkingChargeLabel:(NSTimer *)timer{
    if ([_tmpMarker whetherMark]) {
        _firstSubLable.text = [self stringWithTime:[_tmpMarker parkingDuration]];
        _secondSubLabel.text = [self chargeWithTime:[_tmpMarker parkingDuration]];
    }
    
}

-(NSString *)stringWithTime:(NSTimeInterval)time{
    int hours = 0;
    int minute = 0;
    NSString *timeFormat = nil;
    
    hours = (int)time / 3600;
    minute = (int)time % 3600 / 60;
    
    if (hours == 0) {
        timeFormat = [NSString stringWithFormat:@"%d分钟",minute];
    }else{
        timeFormat = [NSString stringWithFormat:@"%d小时%d分钟",hours,minute];
    }
    
    return timeFormat;
}

-(NSString *)chargeWithTime:(NSTimeInterval)time{
    int hours = 0;
    int charge = 0;
    int minute = (int)time % 3600;
    
    NSString *mallID = [[[[[_tmpMarker
                            majorArea] floor] block] mall] identifier];
    YTLocalCharge *tmpCharge = [[YTLocalCharge alloc]initWithMallID:mallID];
    
    hours = (int)time / 3600;
    if (hours == 0) {
        hours = 1;
    }else{
        int tmpHours = (int)time % 3600 / 60 >= 0 ? 1:0;
        hours += tmpHours;
    }
    
    if (minute > tmpCharge.freeTime) {
        charge = [YTChargeStandard chargeStandardForTime:hours p:(int)tmpCharge.P  k:(int)tmpCharge.K  a:(int)tmpCharge.A  maxMoney:(int)tmpCharge.Max];
    }else{
        charge = 0;
    }
    return [NSString stringWithFormat:@"%d 元",charge];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)dealloc{
    [_mapView removeFromSuperview];
    [_starNavigationButton removeFromSuperview];
    [_navigationBar removeFromSuperview];
    _locator = nil;
    [_beaconManager removeListener:_locator];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:YTBluetoothStateHasChangedNotification object:nil];
}


#pragma mark locator
- (void)YTBeaconBasedLocator:(YTBeaconBasedLocator *)locator
           coordinateUpdated:(CLLocationCoordinate2D)coordinate{
    NSLog(@"cordinate!!! lat: %f, long:%f",coordinate.latitude,coordinate.longitude);
    
    _userCoordintate = coordinate;
    
    if([[_currenDisplayMajorArea identifier] isEqualToString:[[_userMinorArea majorArea] identifier]]){
        [self showUserAtCoordinate:_userCoordintate];
    }
    else{
        NSLog(@"shouldn't even be here");
    }
}

-(void)refreshLocatorWithMapView:(RMMapView *)aMapView
                       majorArea:(id<YTMajorArea>)aMajorArea{
    
    if(_locator == nil){
        [_beaconManager removeListener:_locator];
        _locator = [[YTBeaconBasedLocator alloc] initWithMapView:aMapView beaconManager:_beaconManager majorArea:aMajorArea mapOffset:[[[[[_userMinorArea majorArea] floor] block] mall] offset]];
        [_locator start];
        _locator.delegate = self;
        [_beaconManager addListener:_locator];
        _userCoordintate = CLLocationCoordinate2DMake(-888, -888);
        _locatorMajorArea = aMajorArea;
        return;
    }
    
    if(![[aMajorArea identifier] isEqualToString:[_locatorMajorArea identifier]]){
        [_beaconManager removeListener:_locator];
        _locator = [[YTBeaconBasedLocator alloc] initWithMapView:aMapView beaconManager:_beaconManager majorArea:aMajorArea mapOffset:[[[[[_userMinorArea majorArea] floor] block] mall] offset]];
        [_locator start];
        _locator.delegate = self;
        [_beaconManager addListener:_locator];
        _userCoordintate = CLLocationCoordinate2DMake(-888, -888);
        _locatorMajorArea = aMajorArea;
        return;
    }
    
}

-(void)mapView:(YTMapView2 *)mapView doubleTapOnMap:(CLLocationCoordinate2D)coordinate{
    
}

@end
