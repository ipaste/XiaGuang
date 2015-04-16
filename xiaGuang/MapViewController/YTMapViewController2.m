//
//  YTMapViewController2.m
//  HighGuang
//
//  Created by Yuan Tao on 10/16/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTMapViewController2.h"

#define BIGGER_THEN_IPHONE5 ([[UIScreen mainScreen]currentMode].size.height >= 1136.0f ? YES : NO)
#define HOISTING_HEIGHT 80
#define ROW_HEIGHT 65
typedef NS_ENUM(NSInteger, YTMapViewControllerType){
    YTMapViewControllerTypeNavigation = 0,
    YTMapViewControllerTypeFloor,
    YTMapViewControllerTypeMerchant
};

typedef NS_ENUM(NSInteger, YTMessageType){
    YTMessageTypeFromCurrentButton = 0,
    YTMessageTypeFromNavigationButton
};


@interface YTMapViewController2 (){
    YTMajorAreaVoter *_voter;
    
    id<YTMajorArea> _majorArea;
    YTBeaconManager *_beaconManager;
    YTBluetoothManager *_bluetoothManager;
    YTMultipleMerchantView *_multipleView;
    id<YTMerchantLocation> _merchantLocation;
    
    BOOL _bluetoothOn;
    BOOL _isFirstBluetoothPrompt;
    BOOL _isFirstEnter;
    BOOL _currentViewDisplay;
    BOOL _selectOnOneOfThePoi;
    BOOL _shownFloorChange;
    
    YTMapViewControllerType _type;
    
    YTNavigationBar *_navigationBar;
    
    YTSearchView *_searchView;
    YTMoveCurrentLocationButton *_moveCurrentButton;
    UIImageView *_changeFloorIndicator;
    
    YTMoveTargetLocationButton *_moveTargetButton;
    YTPoiButton *_poiButton;
    YTZoomStepper *_zoomStepper;
    YTSwitchFloorView *_switchFloorView;
    YTSwitchBlockView *_switchBlockView;
    YTDetailsView *_detailsView;
    YTSelectedPoiButton *_selectedPoiButton;
    UIToolbar *_toolbar;
    UITableView *_mallTableView;
    UILabel *_bluetoothLabel;
    UIAlertView *_alert;
    
    //states
    id<YTMajorArea> _curDisplayedMajorArea;
    id<YTMinorArea> _userMinorArea;
    BOOL _switchingFloor;
    NSArray *_activePois;
    id<YTMajorArea> _activePoiMajorArea;
    BOOL _blurMenuShown;
    id<YTMall> _targetMall;
    NSString *_activeGroupName;
    BOOL _shownCallout;
    BOOL _viewDidAppear;
    
    BOOL _firstBlueToothRefresh;
    
    YTPoi *_selectedTransport;
    //NSArray *_beaconsPoi;
    
    
    //商圈入口记录的mall
    id<YTMall> _recordMall;
    BOOL _shownUser;
    
    
    //navigation related
    YTNavigationModePlan *_navigationPlan;
    YTNavigationView *_navigationView;
    
    YTPoiView *_poiView;
    
    YTPoi *_selectedPoi;
    
    
    CLLocationCoordinate2D _userCord;
    CLLocationCoordinate2D _targetCord;
    
    NSMutableArray *_malls;
    NSMutableArray *_allElvatorAndEscalator;
    
    YTBeaconBasedLocator *_locator;
    YTMallDict *_mallDict;
    
    CLLocationCoordinate2D _userCoordintate;
    
    CLLocationCoordinate2D _lastStableCoordinate;
    
    NSString *_lastMajorAreaId;
    
    BOOL _forceRepath;
    
}
@end

@implementation YTMapViewController2{
    YTMapView2 *_mapView;
}

-(id)initWithMinorArea:(id <YTMinorArea>)minorArea{
    self  = [super init];
    if (self) {
        if (minorArea != nil) {
            _userMinorArea = minorArea;
            _majorArea = [minorArea majorArea];
        }
        _type = YTMapViewControllerTypeNavigation;
    }
    return self;
    
}

-(id)initWithMerchant:(id<YTMerchantLocation>)merchantLocation{
    self  = [super init];
    if (self) {
        if (merchantLocation != nil) {
            _merchantLocation = merchantLocation;
            _majorArea = [merchantLocation majorArea];
            _recordMall = [[[_majorArea floor] block] mall];
        }
        _type = YTMapViewControllerTypeMerchant;
    }
    return self;
}

-(id)initWithFloor:(id<YTFloor>)floor{
    self  = [super init];
    if (self) {
        if ( floor != nil) {
            _majorArea = [[floor majorAreas] objectAtIndex:0];
            _recordMall = [[[_majorArea floor] block] mall];
        }
        _type = YTMapViewControllerTypeFloor;
    }
    return self;
}


-(void)viewDidLoad{
    [super viewDidLoad];
    
    _shownUser = NO;
    _allElvatorAndEscalator = [NSMutableArray array];
    _malls = [NSMutableArray array];
    _isFirstBluetoothPrompt = YES;
    _isFirstEnter = YES;
    _curDisplayedMajorArea = _majorArea;
    _bluetoothManager = [YTBluetoothManager shareBluetoothManager];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(bluetoothStateChange:) name:YTBluetoothStateHasChangedNotification object:nil];
    
    UIImageView *background = [[UIImageView alloc]initWithFrame:self.view.bounds];
    background.image = [UIImage imageNamed:@"bg_inner.jpg"];
    [self.view addSubview:background];
    
    _voter = [YTMajorAreaVoter sharedInstance];
    _beaconManager = [YTBeaconManager sharedBeaconManager];
    _beaconManager.delegate = self;
    
    [self createNavigationBar];
    [self createMapView];
    [self createCurLocationButton];
    [self createCommonPoiButton];
    [self createZoomStepper];
    [self createBlockAndFloorSwitch];
    [self createDetailsView];
    [self createNavigationView];
    [self createPoiView];
    [self setTargetMall:[[[_majorArea floor] block]mall]];
    [self createBlurMenuWithCallBack:nil];
    [self createSearchView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showBlur];
    if(_type == YTMapViewControllerTypeNavigation){
        [AVAnalytics beginLogPageView:@"mapViewController-navigation"];
    }
    else if(_type == YTMapViewControllerTypeMerchant){
        [AVAnalytics beginLogPageView:@"mapViewController-merchant"];
    }
    else if(_type == YTMapViewControllerTypeFloor){
        [AVAnalytics beginLogPageView:@"mapViewController-mall"];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _currentViewDisplay = NO;
    [self cancelCommonPoiState];
    _viewDidAppear = NO;
    if(_type == YTMapViewControllerTypeNavigation){
        [AVAnalytics endLogPageView:@"mapViewController-navigation"];
    }
    else if(_type == YTMapViewControllerTypeMerchant){
        [AVAnalytics endLogPageView:@"mapViewController-merchant"];
    }
    else if(_type == YTMapViewControllerTypeFloor){
        [AVAnalytics endLogPageView:@"mapViewController-mall"];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if(_userMinorArea == nil){
        
        if(!_blurMenuShown){
            _toolbar.hidden = NO;
            
            if(_type == YTMapViewControllerTypeNavigation){
                
                
                if(_toolbar == nil){
                    [self createBlurMenuWithCallBack:^{
                        [UIView animateWithDuration:0.5 animations:^{
                            [self showBlur];
                        }];
                    }];
                }
                else{
                    [UIView animateWithDuration:0.5 animations:^{
                        [self showBlur];
                    }];
                }
                if([_mapView currentState] != YTMapViewDetailStateNormal){
                    [_mapView setMapViewDetailState:YTMapViewDetailStateNormal];
                    [self hideCallOut];
                }
            }
        }
    }
    else{
        [self hideBlur];
    }
    
    if(_type != YTMapViewControllerTypeNavigation){
        
        [self hideBlur];
        [self redrawBlockAndFloorSwitch];
        
    }
    
    _currentViewDisplay = YES;
    
    _firstBlueToothRefresh = YES;
    [_bluetoothManager refreshBluetoothState];
    
    if (_type == YTMapViewControllerTypeMerchant) {
        
        [_mapView setCenterCoordinate:[_merchantLocation coordinate] animated:NO];
        _selectedPoi = [_merchantLocation producePoi];
        [_mapView highlightPoi:_selectedPoi animated:YES];
        [_detailsView setCommonPoi:_merchantLocation];
        
        [self showCallOut];
    }
    
    _viewDidAppear = YES;
    [self injectPoisForMajorArea:_curDisplayedMajorArea];
}

-(void)viewDidLayoutSubviews{
    if ([_mallTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_mallTableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    
    if ([[UIDevice currentDevice].systemVersion hasPrefix:@"8"] && [_mallTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_mallTableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    
}

-(void)createBlurMenuWithCallBack:(void (^)())callback{
    _malls = [NSMutableArray array];
    YTMallDict *dict = [YTMallDict sharedInstance];
    [dict getAllLocalMallWithCallBack:^(NSArray *malls) {
        _malls = malls.copy;
        [self instantiateMenu];
        if(callback!= nil){
            callback();
        }
    }];
}

-(void)instantiateMenu{
    if(_toolbar == nil){
        NSMutableArray *mallNames = [NSMutableArray array];
        for(id<YTMall> mall in _malls){
            [mallNames addObject:[mall mallName]];
        }
        _toolbar = [[UIToolbar alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _toolbar.tintColor = [UIColor blackColor];
        _toolbar.barStyle = UIBarStyleBlack;
        _toolbar.translucent = YES;
        [self.view insertSubview:_toolbar belowSubview:_navigationBar];
        if (!_majorArea) {
            [self showBlur];
            _navigationBar.titleName = @"选择商城";
        }else{
            [self hideBlur];
        }
    }
    
    if (_type == YTMapViewControllerTypeNavigation) {
        if (_bluetoothLabel == nil) {
            _bluetoothLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(_toolbar.frame) - 55, CGRectGetWidth(_toolbar.frame), 55)];
            _bluetoothLabel.font = [UIFont systemFontOfSize:15];
            _bluetoothLabel.textColor = [UIColor colorWithString:@"999999"];
            _bluetoothLabel.text = @"您没有打开蓝牙或不在商城范围内";
            _bluetoothLabel.textAlignment = 1;
            [_toolbar addSubview:_bluetoothLabel];
        }
        
        if (_mallTableView == nil) {
            _mallTableView = [[UITableView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_navigationBar.frame), CGRectGetWidth(_navigationBar.frame) - 20, CGRectGetMinY(_bluetoothLabel.frame) - CGRectGetHeight(_navigationBar.frame)) style:UITableViewStylePlain];
            _mallTableView.backgroundColor = [UIColor clearColor];
            _mallTableView.separatorColor = [UIColor colorWithString:@"727272"];
            _mallTableView.delegate = self;
            _mallTableView.dataSource = self;
            _mallTableView.showsVerticalScrollIndicator = false;
            _mallTableView.layer.cornerRadius = 10;
            _mallTableView.rowHeight = ROW_HEIGHT;
            _mallTableView.layer.masksToBounds = true;
            [_toolbar addSubview:_mallTableView];
        }
    }
}

-(void)hideBlur{
    [_navigationBar changeSearchButtonWithHide:false];
    _toolbar.alpha = 0;
    _blurMenuShown = NO;
}

-(void)showBlur{
    [_navigationBar changeSearchButtonWithHide:true];
    _toolbar.alpha = 1;
    _blurMenuShown = YES;
}

-(void)createMapView{
    _mapView = [[YTMapView2 alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_navigationBar.frame), CGRectGetWidth(_navigationBar.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(_navigationBar.frame))];
    _mapView.delegate = self;
    id <YTMall> mall = [[[_majorArea floor] block] mall];
    mall = [_mallDict changeMallObject:mall resultType:YTMallClassCloud];
    _mapView.isShowPath = [mall isShowPath];
    [self.view insertSubview:_mapView belowSubview:_navigationBar];
    
    [self refreshLocatorWithMapView:_mapView.map majorArea:_curDisplayedMajorArea];
    _shownFloorChange = NO;
    [_mapView displayMapNamed:[_curDisplayedMajorArea mapName]];
    [_mapView setZoom:1 animated:NO];
}



-(void)injectPoisForMajorArea:(id<YTMajorArea>)majorArea{
    if([[_majorArea identifier] isEqualToString:[_curDisplayedMajorArea identifier]] && _userMinorArea != nil){
        //[_mapView showUserLocationAtCoordinate:_userCoordintate];
        _shownUser = false;
        [self showUserAtCoordinate:_userCoordintate];

    }
    NSArray *merchants = [majorArea merchantLocations];
    NSArray *elevators = [majorArea elevators];
    NSArray *bathrooms = [majorArea bathrooms];
    NSArray *escalators = [majorArea escalators];
    NSArray *serviceStations = [majorArea serviceStations];
    NSArray *exits = [majorArea exits];
    NSMutableArray *pois = [NSMutableArray array];
    
    YTPoi *highlightPoi = nil;
    
    for(id<YTMerchantLocation> tmpMerchant in merchants){
        YTPoi *tmpPoi = [tmpMerchant producePoi];
        if ([tmpPoi.poiKey isEqualToString:_selectedPoi.poiKey]) {
            highlightPoi = tmpPoi;
        }
        [pois addObject:tmpPoi];
    }
    
    for(id<YTExit> tmpExits in exits){
        YTPoi *tmpPoi = [tmpExits producePoi];
        if ([tmpPoi.poiKey isEqualToString:_selectedPoi.poiKey]) {
            highlightPoi = tmpPoi;
        }
        [pois addObject:tmpPoi];
    }
    
    for (id<YTBathroom> tmpBathroom in bathrooms) {
        YTPoi *tmpPoi = [tmpBathroom producePoi];
        if ([tmpPoi.poiKey isEqualToString:_selectedPoi.poiKey]) {
            highlightPoi = tmpPoi;
        }
        [pois addObject:tmpPoi];
    }
    
    for (id<YTElevator> tmpElevator in elevators) {
        YTPoi *tmpPoi = [tmpElevator producePoi];
        if ([tmpPoi.poiKey isEqualToString:_selectedPoi.poiKey]) {
            highlightPoi = tmpPoi;
        }
        [_allElvatorAndEscalator addObject:tmpPoi];
        [pois addObject:tmpPoi];
    }
    
    for (id<YTEscalator> tmpEscalator in escalators) {
        YTPoi *tmpPoi = [tmpEscalator producePoi];
        if ([tmpPoi.poiKey isEqualToString:_selectedPoi.poiKey]) {
            highlightPoi = tmpPoi;
        }
        [_allElvatorAndEscalator addObject:tmpPoi];
        [pois addObject:tmpPoi];
    }
    
    
    for (id<YTServiceStation> tmpServiceStation in serviceStations) {
        YTPoi *tmpPoi = [tmpServiceStation producePoi];
        if ([tmpPoi.poiKey isEqualToString:_selectedPoi.poiKey]) {
            highlightPoi = tmpPoi;
        }
        [pois addObject:tmpPoi];
    }
    
    [_mapView addPois:pois];
    
    
    if(highlightPoi != nil && !_navigationView.isNavigating){
        
        [_mapView highlightPoi:highlightPoi animated:NO];
    }

    if (_navigationView.isNavigating){
        if (![[_curDisplayedMajorArea  identifier] isEqualToString:[[[_navigationPlan targetPoiSource] majorArea] identifier]] && [[[_userMinorArea majorArea] identifier] isEqualToString:[_curDisplayedMajorArea identifier]]) {
            
            NSArray *transportsToHighlight = [self filteredTransportFrom: _curDisplayedMajorArea toArea:_navigationPlan.targetPoiSource.majorArea];
            //[_mapView highlightPois:transportsToHighlight animated:YES];
            if (_userCoordintate.latitude == -888){
                _userCoordintate = [_userMinorArea coordinate];
            }
            YTPoi *closestTransport = [self closestTransportToCoordinate:_userCoordintate
                                                                 inArray:transportsToHighlight];
            [_mapView superHighlightPoi:closestTransport animated:false];
            _targetCord = ((id<YTPoiSource>) closestTransport.sourceModel).coordinate;
            
        }else{
            _targetCord = _navigationPlan.targetPoiSource.coordinate;
            [self setTargetCordToDoorCoordIfPossible:_navigationPlan.targetPoiSource];
            
            [_mapView hidePois:_allElvatorAndEscalator animated:NO];
        }
        
        if (highlightPoi != nil) {
            [_mapView superHighlightPoi:highlightPoi animated:NO];
            
            if([self userOnCurdisplayedArea]){
                [self showPathFromUserToPoi:highlightPoi];
            }
        }
    }
    
    if(_activePois != nil && _activePois.count > 0 && [[_activePoiMajorArea identifier] isEqualToString:[_curDisplayedMajorArea identifier]]){
        [_mapView highlightPois:_activePois animated:NO];
        [_mapView superHighlightPoi:_selectedPoi animated:YES];
    }
    
}

-(void)setTargetCordToDoorCoordIfPossible:(id<YTPoiSource>)merchantInstance{
    
    if([merchantInstance isKindOfClass:[YTLocalMerchantInstance class]]){
        NSArray *doors = ((YTLocalMerchantInstance *)merchantInstance).doors;
        if(doors != nil && doors.count > 0){
            _targetCord = ((id<YTDoor>)doors[0]).coordinate;
        }
    }
}


-(NSArray *)filteredTransportFrom:(id<YTMajorArea>)fromArea
                           toArea:(id<YTMajorArea>)toArea{
    
//    BOOL upward = [[fromArea floor] queue] < [[toArea floor] queue];
//    NSMutableArray *result = [NSMutableArray new];
//    
//    for(YTPoi *tmpTransport in _allElvatorAndEscalator){
//        
//        id<YTPoiSource> tmpelevator = tmpTransport.sourceModel;
//        if(upward){
//           // if(((id<YTTransport>)tmpelevator).type == YTTransportUpward || ((id<YTTransport>)tmpelevator).type == YTTransportBothWays){
//                
//                [result addObject:tmpTransport];
//          //  }
//        }
//        else{
//           // if(((id<YTTransport>)tmpelevator).type == YTTransportDownward || ((id<YTTransport>)tmpelevator).type == YTTransportBothWays){
//                
//                [result addObject:tmpTransport];
//           // }
//        }
//        
//    }
    
    return _allElvatorAndEscalator;
    
}

-(YTPoi *)closestTransportToCoordinate:(CLLocationCoordinate2D)toCoord
                               inArray:(NSArray *)array{
    
    CGPoint toPoint = [YTCanonicalCoordinate mapToCanonicalCoordinate:toCoord mapView:_mapView.map];
    YTPoi *result;
    double minDist = MAXFLOAT;
    
    
    for(YTPoi *tmpPoi in array){
        
        id<YTPoiSource> tmpelevator = tmpPoi.sourceModel;
        CGPoint tmpPoint = [YTCanonicalCoordinate mapToCanonicalCoordinate:tmpelevator.coordinate mapView:_mapView.map];
        
        double xdiff = toPoint.x-tmpPoint.x;
        double ydiff = toPoint.y-tmpPoint.y;
        double curdistance = xdiff*xdiff + ydiff*ydiff;
        
        if(curdistance < minDist){
            result = tmpPoi;
            minDist = curdistance;
        }
        
        
    }
    
    return result;
}



-(void)createNavigationBar{
    _navigationBar = [[YTNavigationBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
    _navigationBar.delegate = self;
    NSString *title = nil;
    switch (_type) {
        case YTMapViewControllerTypeFloor:
            title = @"返回";
            break;
        case YTMapViewControllerTypeMerchant:
            title = @"返回";
            break;
        case YTMapViewControllerTypeNavigation:
            title = @"首页";
            break;
    }
    _navigationBar.backTitle = title;
    _navigationBar.titleName = [[[[_majorArea floor]block]mall] mallName];
    if (_navigationBar.titleName == nil) {
        _navigationBar.titleName = @"地图导航";
    }
    [self.view addSubview:_navigationBar];
}
-(void)createSearchView{
    if (_searchView != nil) {
        [_searchView removeFromSuperview];
        _searchView.delegate = nil;
        _searchView = nil;
    }
    _searchView = [[YTSearchView alloc]initWithMall:_targetMall placeholder:@"商城/品牌" indent:NO];
    _searchView.delegate = self;
    [_searchView addInView:self.view show:NO];
    [_searchView setBackgroundImage:nil];
}
-(void)createCurLocationButton{
    _moveCurrentButton = [[YTMoveCurrentLocationButton alloc]initWithFrame:CGRectMake(18,CGRectGetMaxY(_mapView.frame) - 61, 41, 41)];
    _moveCurrentButton.delegate = self;
    [self.view insertSubview:_moveCurrentButton belowSubview:_navigationBar];
    
    _changeFloorIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_moveCurrentButton.frame) ,CGRectGetMinY(_moveCurrentButton.frame) - 80 , CGRectGetWidth(_moveCurrentButton.frame), CGRectGetHeight(_moveCurrentButton.frame))];
    _changeFloorIndicator.image = [UIImage imageWithImageName:@"nav_ico_ finger" andTintColor:[UIColor colorWithString:@"e95e37"]];
    _changeFloorIndicator.hidden = YES;
    [self.view insertSubview:_changeFloorIndicator belowSubview:_navigationBar];
    
    _moveTargetButton = [[YTMoveTargetLocationButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_moveCurrentButton.frame) + 18,CGRectGetMinY(_moveCurrentButton.frame), 41, 41)];
    _moveTargetButton.hidden = YES;
    _moveTargetButton.delegate = self;
    [self.view insertSubview:_moveTargetButton belowSubview:_navigationBar];
}

-(void)createCommonPoiButton{
    _poiButton = [[YTPoiButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_moveCurrentButton.frame) + 18, CGRectGetMaxY(_mapView.frame) - 61, 41, 41)];
    _poiButton.delegate = self;
    [self.view insertSubview:_poiButton belowSubview:_navigationBar];
    
    _selectedPoiButton = [[YTSelectedPoiButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_poiButton.frame) + 10, CGRectGetMinY(_poiButton.frame), CGRectGetWidth(_poiButton.frame), CGRectGetHeight(_poiButton.frame))];
    _selectedPoiButton.delegate = self;
    [self.view insertSubview:_selectedPoiButton belowSubview:_navigationBar];
}
-(void)createZoomStepper{
    _zoomStepper = [[YTZoomStepper alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_mapView.frame) - 55, CGRectGetMaxY(_mapView.frame) - 115, 41, 95)];
    _zoomStepper.delegate = self;
    [self.view insertSubview:_zoomStepper belowSubview:_navigationBar];
}

-(void)createDetailsView{
    _detailsView = [[YTDetailsView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_mapView.frame), CGRectGetHeight(self.view.frame), CGRectGetWidth(_mapView.frame), 80)];
    _detailsView.hidden = YES;
    
    _detailsView.delegate = self;
    [self.view insertSubview:_detailsView belowSubview:_navigationBar];
}

-(void)createBlockAndFloorSwitch{
    [_switchFloorView removeFromSuperview];
    _switchFloorView = [[YTSwitchFloorView alloc]initWithPosition:CGPointMake(CGRectGetMaxX(_mapView.frame) - 59, CGRectGetMinY(_mapView.frame) + 10) AndCurrentMajorArea:_majorArea];
    _switchFloorView.delegate = self;
    [self.view insertSubview:_switchFloorView belowSubview:_navigationBar];
    
    [_switchBlockView removeFromSuperview];
    _switchBlockView = [[YTSwitchBlockView alloc]initWithPosition:CGPointMake(CGRectGetMinX(_switchFloorView.frame) - 59, CGRectGetMinY(_mapView.frame) + 10) currentMajorArea:_majorArea];
    _switchBlockView.delegate = self;
    [self.view insertSubview:_switchBlockView belowSubview:_navigationBar];
    
    [self redrawBlockAndFloorSwitch];
}

-(void)redrawBlockAndFloorSwitch{
    if ([[[[_curDisplayedMajorArea floor] block]mall]blocks].count > 1) {
        _switchBlockView.hidden = NO;
        [_switchBlockView redrawWithMajorArea:_curDisplayedMajorArea];
    }else{
        _switchBlockView.hidden = YES;
    }
    [_switchFloorView redrawWithMajorArea:_curDisplayedMajorArea];
}



-(void)createNavigationView{
    _navigationView = [[YTNavigationView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 80 ,  CGRectGetWidth(_mapView.frame), 80)];
    _navigationView.hidden = YES;
    _navigationView.isShowSwitchButton = NO;
    _navigationView.delegate = self;
    [self.view addSubview:_navigationView];
}
-(void)createPoiView{
    _poiView = [[YTPoiView alloc]initWithShow:NO];
    _poiView.delegate = self;
}

#pragma mark MapViewDelegate
-(void)mapView:(YTMapView2 *)mapView singleTapOnMap:(CLLocationCoordinate2D)coordinate{
    if (_multipleView.isShow) {
        [_multipleView hide];
        _multipleView = nil;
    }
    if (_selectedPoi && mapView.currentState == YTMapViewDetailStateShowDetail) {
        //hide callout and POI for
        
        if([_selectedPoi isMemberOfClass:[YTMerchantPoi class]]){
            [mapView hidePoi:_selectedPoi animated:NO];
            [self hideCallOut];
        }
        else{
            if (!_selectOnOneOfThePoi){
                [mapView hidePoi:_selectedPoi animated:NO];
                [self hideCallOut];
            }
        }
    }
    if (_switchBlockView.toggle) {
        [_switchBlockView toggleBlockView];
    }
    if (_switchFloorView.toggle) {
        [_switchFloorView toggleFloor];
    }
}

-(void)mapView:(YTMapView2 *)mapView doubleTapOnMap:(CLLocationCoordinate2D)coordinate{
    if (_multipleView.isShow) {
        [_multipleView hide];
        _multipleView = nil;
    }
    if (_selectedPoi && mapView.currentState == YTMapViewDetailStateShowDetail) {
        //hide callout and POI for
        [mapView hidePoi:_selectedPoi animated:NO];
        [self hideCallOut];
    }
    if (_switchBlockView.toggle) {
        [_switchBlockView toggleBlockView];
    }
    if (_switchFloorView.toggle) {
        [_switchFloorView toggleFloor];
    }
}

-(void)mapView:(YTMapView2 *)mapView tapOnPoi:(YTPoi *)poi{
    if (_navigationView.isNavigating) return;
    
    if (_multipleView.isShow) {
        [_multipleView hide];
        _multipleView = nil;
    }
    
    id<YTPoiSource> sourceModel = [poi sourceModel];
    
    //if there's activePoi
    if([sourceModel isKindOfClass:[YTLocalMerchantInstance class]] && _selectOnOneOfThePoi){
        return;
    }
    
    if([mapView currentState] == YTMapViewDetailStateNormal){
        
        if([sourceModel isMemberOfClass:[YTLocalMerchantInstance class]]){
            [mapView highlightPoi:poi animated:YES];
            [_detailsView setCommonPoi:sourceModel];
            _selectedPoi = poi;
            [self showCallOut];
        }
        else{
            if (![poi.poiKey isEqualToString:_selectedPoi.poiKey]) {
                if (!_selectOnOneOfThePoi) {
                    [mapView hidePoi:_selectedPoi animated:YES];
                    [mapView highlightPoi:poi animated:YES];
                    [_detailsView setCommonPoi:sourceModel];
                    _selectedPoi = poi;
                    [self showCallOut];
                }else{
                    if([self selectedOnSameGroupCommonPoi:poi]){
                        [mapView highlightPoi:_selectedPoi animated:NO];
                        [mapView superHighlightPoi:poi animated:NO];
                        [_detailsView setCommonPoi:sourceModel];
                        _selectedPoi = poi;
                        [self showCallOut];
                    }
                }
                
            }
        }
    }else if([mapView currentState] == YTMapViewDetailStateShowDetail){
        
        if([sourceModel isMemberOfClass:[YTLocalMerchantInstance class]]){
            if (![poi.poiKey isEqualToString:_selectedPoi.poiKey]) {
                [mapView hidePoi:_selectedPoi animated:YES];
                _selectedPoi = poi;
                [mapView highlightPoi:_selectedPoi animated:YES];
                [_detailsView setCommonPoi:sourceModel];
            }
        }
        else{
            if (![poi.poiKey isEqualToString:_selectedPoi.poiKey]) {
                if (!_selectOnOneOfThePoi) {
                    [mapView hidePoi:_selectedPoi animated:YES];
                    [mapView highlightPoi:poi animated:YES];
                    [_detailsView setCommonPoi:sourceModel];
                    _selectedPoi = poi;
                }else{
                    if([self selectedOnSameGroupCommonPoi:poi]){
                        [mapView highlightPoi:_selectedPoi animated:NO];
                        [mapView superHighlightPoi:poi animated:NO];
                        _selectedPoi = poi;
                    }
                }
                
            }
        }
    }
    else if([mapView currentState] == YTMapViewDetailStateNavigating){
        
        if([self userOnCurdisplayedArea] && ![self userOnTargetPoiMajorArea]){
            if([sourceModel isMemberOfClass:[YTLocalElevator class]]
               || [sourceModel isMemberOfClass:[YTLocalEscalator class]]){
                
                [self showPathFromUserToPoi:poi];
            }
        }
    }
}


-(void)showPathFromUserToPoi:(YTPoi *)poi{
    
    [_mapView highlightPoi:_selectedTransport animated:NO];
    
    [_mapView superHighlightPoi:poi animated:NO];
    _selectedTransport = poi;
    _targetCord = ((id<YTPoiSource>)poi.sourceModel).coordinate;
    
    [self setTargetCordToDoorCoordIfPossible:((id<YTPoiSource>)poi.sourceModel)];
    
    _forceRepath = true;
}

-(BOOL)userOnCurdisplayedArea{
    if(_userMinorArea == nil){
        return NO;
    }
    
    BOOL onSameArea = [[_userMinorArea majorArea].identifier isEqualToString:_curDisplayedMajorArea.identifier];
    return onSameArea;
}

-(BOOL)userOnTargetPoiMajorArea{
    if(_userMinorArea == nil || _navigationPlan.targetPoiSource == nil){
        return NO;
    }
    
    BOOL onSameArea = [[_userMinorArea majorArea].identifier isEqualToString:[_navigationPlan targetPoiSource].majorArea.identifier];
    return onSameArea;
}

-(BOOL)selectedOnSameGroupCommonPoi:(YTPoi *)poi{
    if (_multipleView.isShow) {
        [_multipleView hide];
        _multipleView = nil;
    }
    if(_activeGroupName == nil){
        return NO;
    }
    
    Class k;
    if([_activeGroupName isEqualToString:@"洗手间"]){
        k = [YTBathroomPoi class];
    }
    if([_activeGroupName isEqualToString:@"出入口"]){
        k = [YTExitPoi class];
    }
    if([_activeGroupName isEqualToString:@"电梯"]){
        k = [YTElevatorPoi class];
    }
    if([_activeGroupName isEqualToString:@"扶梯"]){
        k = [YTEscalatorPoi class];
    }
    if([_activeGroupName isEqualToString:@"服务台"]){
        k = [YTServiceStationPoi class];
    }
    
    if(![poi isMemberOfClass:k]){
        return NO;
    }
    return YES;
}

-(void)showCallOut{
    if ([_mapView currentState] != YTMapViewDetailStateShowDetail) {
        _poiButton.hidden = YES;
        _moveTargetButton.hidden = NO;
        _shownCallout = YES;
        _detailsView.hidden = NO;
        if(_type == YTMapViewControllerTypeMerchant){
            _shownFloorChange = YES;
        }
        [UIView animateWithDuration:.5 animations:^{
            [_mapView setMapViewDetailState:YTMapViewDetailStateShowDetail];
            CGRect frame = _moveCurrentButton.frame;
            frame.origin.y -= HOISTING_HEIGHT;
            _moveCurrentButton.frame = frame;
            
            frame = _changeFloorIndicator.frame;
            frame.origin.y -= HOISTING_HEIGHT;
            _changeFloorIndicator.frame = frame;
            
            frame = _moveTargetButton.frame;
            frame.origin.y -= HOISTING_HEIGHT;
            _moveTargetButton.frame = frame;
            
            frame = _zoomStepper.frame;
            frame.origin.y -= HOISTING_HEIGHT;
            _zoomStepper.frame = frame;
            
            frame = _selectedPoiButton.frame;
            frame.origin.y -= HOISTING_HEIGHT;
            _selectedPoiButton.frame = frame;
            
            
            frame = _detailsView.frame;
            frame.origin.y -= HOISTING_HEIGHT;
            _detailsView.frame = frame;
            
        } completion:^(BOOL finished) {
            if(_type == YTMapViewControllerTypeMerchant){
                _shownFloorChange = NO;
            }
            
        }];
        
    }
}
-(void)hideCallOut{
    if ([_mapView currentState] != YTMapViewDetailStateNormal) {
        _selectedPoi = nil;
        _shownCallout = NO;
        [UIView animateWithDuration:.5 animations:^{
            [_mapView setMapViewDetailState:YTMapViewDetailStateNormal];
            
            CGRect frame = _moveCurrentButton.frame;
            frame.origin.y += HOISTING_HEIGHT;
            _moveCurrentButton.frame = frame;
            
            frame = _changeFloorIndicator.frame;
            frame.origin.y += HOISTING_HEIGHT;
            _changeFloorIndicator.frame = frame;
            
            
            frame = _moveTargetButton.frame;
            frame.origin.y += HOISTING_HEIGHT;
            _moveTargetButton.frame = frame;
            
            frame = _zoomStepper.frame;
            frame.origin.y += HOISTING_HEIGHT;
            _zoomStepper.frame = frame;
            
            frame = _selectedPoiButton.frame;
            frame.origin.y += HOISTING_HEIGHT;
            _selectedPoiButton.frame = frame;
            
            frame = _detailsView.frame;
            frame.origin.y += HOISTING_HEIGHT;
            _detailsView.frame = frame;
            
        } completion:^(BOOL finished) {
            _poiButton.hidden = NO;
            _moveTargetButton.hidden = YES;
            _detailsView.hidden = YES;
            _navigationView.hidden = YES;
            
        }];
    }
    
}

#pragma mark YTNavigationBarManager

-(void)searchButtonClicked{
    if (_multipleView.isShow) {
        [_multipleView hide];
    }
    _navigationBar.hidden = true;
    [_searchView showSearchViewWithAnimation:YES];
}

-(void)backButtonClicked{
    if (_switchFloorView.toggle) {
        [_switchFloorView toggleFloor];
    }
    if (_switchBlockView.toggle){
        [_switchBlockView toggleBlockView];
    }
    if (_selectedPoi != nil){
        _navigationView.hidden = YES;
    }
    if(_type != YTMapViewControllerTypeNavigation){
        [_beaconManager removeListener:_locator];
        _locator = nil;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark YTSearchViewManager
-(void)searchCancelButtonClicked{
    _navigationBar.hidden = false;
    [_searchView hideSearchViewWithAnimation:YES];
    /*if(_activePoiMajorArea != nil){
     [self cancelCommonPoiState];
     }*/
}

-(void)selectedUniIds:(NSArray *)uniIds{
    if (uniIds.count <= 0) {
        [[[YTMessageBox alloc]initWithTitle:@"虾逛提示" Message:[NSString stringWithFormat:@"%@ 中没有这个商家",[_targetMall mallName]] cancelButtonTitle:@"知道了"]show];
        
        return;
    }
    if (uniIds.count >= 2){
        _multipleView =  [[YTMultipleMerchantView alloc]initWithUniIds:uniIds delegate:self];
        [_multipleView showInView:self.view];
        return;
    }
    
    FMDatabase *db = [YTDataManager defaultDataManager].database;
    if([db open]){
        NSString *uniId = [uniIds firstObject];
        FMResultSet *result = [db executeQuery:@"select * from MerchantInstance where uniId = ?",uniId];
        [result next];
        
        YTLocalMerchantInstance *tmpMerchantInstance = [[YTLocalMerchantInstance alloc] initWithDBResultSet:result];
        
        id<YTMajorArea> tmpMajorArea = [tmpMerchantInstance majorArea];
        
        if(_selectedPoi != nil){
            [_mapView hidePoi:_selectedPoi animated:NO];
        }
        _selectedPoi = [tmpMerchantInstance producePoi];
        [_detailsView setCommonPoi:[_selectedPoi sourceModel]];
        
        if (![[_curDisplayedMajorArea identifier]isEqualToString:[tmpMajorArea identifier]]) {
            [self switchFloor:[tmpMajorArea floor] hideCallOut:NO];
            
            //switchFloor will empty _selectedPoi rehighlight here
            _selectedPoi = [tmpMerchantInstance producePoi];
            [_mapView highlightPoi:_selectedPoi animated:YES];
            
        }else{
            [_mapView highlightPoi:_selectedPoi animated:YES];
        }
        [_mapView setCenterCoordinate:[tmpMerchantInstance coordinate] animated:YES];
        
        if(!_shownCallout){
            [self showCallOut];
        }
        
    }
    if(_activePoiMajorArea != nil){
        [self cancelCommonPoiState];
    }
}

-(void)selectToMerchantInstance:(id<YTMerchantLocation>)merchantInstance{
    
    id<YTMajorArea> tmpMajorArea = [merchantInstance majorArea];
    
    if(_selectedPoi != nil){
        [_mapView hidePoi:_selectedPoi animated:NO];
    }
    _selectedPoi = [merchantInstance producePoi];
    [_detailsView setCommonPoi:[_selectedPoi sourceModel]];
    
    if (![[_curDisplayedMajorArea identifier]isEqualToString:[tmpMajorArea identifier]]) {
        [self switchFloor:[tmpMajorArea floor] hideCallOut:NO];
        
        //switchFloor will empty _selectedPoi rehighlight here
        _selectedPoi = [merchantInstance producePoi];
        [_mapView highlightPoi:_selectedPoi animated:YES];
        
    }else{
        [_mapView highlightPoi:_selectedPoi animated:YES];
    }
    [_mapView setCenterCoordinate:[merchantInstance coordinate] animated:YES];
    
    if(!_shownCallout){
        [self showCallOut];
    }
    
}

#pragma mark beacons delegate methods
-(void)noBeaconsFound{
    
}


-(void)rangedObjects:(NSArray *)objects{
    if(_locator==nil){
        NSLog(@"locator nil");
    }
    if(objects.count <= 0){
        return;
    }
    NSMutableArray *beacons = [NSMutableArray array];
    for (NSDictionary *beaconDict in objects) {
        [beacons addObject:beaconDict[@"Beacon"]];
    }
    
    /*
     for(YTMinorAreaPoi *beaconPoi in _beaconsPoi){
     [_mapView setScore:-1.0 forMinorAreaPoi:beaconPoi];
     }
     for(ESTBeacon *beacon in beacons){
     YTLocalMinorArea *tmpMinor = [self getMinorArea:beacon];
     YTMinorAreaPoi *relatedBeacon = [tmpMinor producePoi];
     [_mapView setScore:[beacon.distance doubleValue] forMinorAreaPoi:relatedBeacon];
     }*/
    
    NSString *votedMajorAreaId = [_voter shouldSwitchToMajorAreaId:objects];
    if(_lastMajorAreaId != nil){
        if(![votedMajorAreaId isEqualToString:_lastMajorAreaId]){
            NSString *tmp = [votedMajorAreaId copy];
            votedMajorAreaId = _lastMajorAreaId;
            _lastMajorAreaId = tmp;
        }
    }
    id<YTMinorArea> bestGuessMinorArea = [self topMinorAreaWithInMajorAreaId:votedMajorAreaId inBeacons:beacons];
    if(bestGuessMinorArea == nil){
        return;
    }
    _majorArea = [bestGuessMinorArea majorArea];
    
    if (_majorArea != nil) {

        [self userMoveToMinorArea:bestGuessMinorArea];
        
        if (_type == YTMapViewControllerTypeNavigation) {
            [self setTargetMall:[[[_majorArea floor] block] mall]];
        }
    }
}

-(id<YTMinorArea>)topMinorAreaWithInMajorAreaId:(NSString *)majorAreaId
                                      inBeacons:(NSArray *)beacons
{
    for(ESTBeacon *tmp in beacons){
        id<YTMinorArea> minor = [self getMinorArea:tmp];
        if([[[minor majorArea] identifier] isEqualToString:majorAreaId]){
            return minor;
        }
    }
    return nil;
}

-(void)showUserAtCoordinate:(CLLocationCoordinate2D)coordinate{
    
    if(_shownUser){
        if(coordinate.latitude == -888){
            [_mapView setUserCoordinate:_userCord];
        }
        else
        {
            if(_navigationView.isNavigating && [ _mapView canonicalDistanceFromCoordinate1:coordinate toCoordinate2:_lastStableCoordinate] > 10) {
                _lastStableCoordinate = coordinate;
                [_mapView showPathFromCoord1:coordinate toCoord2:_targetCord forMajorArea:_curDisplayedMajorArea];
            }
            
            [_mapView setUserCoordinate:coordinate];
        }
    }
    else{
        if(coordinate.latitude == -888){
            [_mapView showUserLocationAtCoordinate:_userCord];
        }
        else
        {
            [_mapView showUserLocationAtCoordinate:_userCoordintate];
        }
        _shownUser = YES;
    }
}

-(void)userMoveToMinorArea:(id<YTMinorArea>)minorArea{
    
    if(_type == YTMapViewControllerTypeFloor || _type == YTMapViewControllerTypeMerchant){
        
        if(![[[[[[minorArea majorArea] floor] block] mall] identifier] isEqualToString:[_recordMall identifier]]){
            return;
        }
        
    }
    
    if(_blurMenuShown){
        [UIView animateWithDuration:0.3 animations:^{
            [self hideBlur];
            
        }];
    }
    
    _userCoordintate = [minorArea coordinate];
    //if this minorArea is in a different major area or _userMinorArea is not created yet
    if (![[[minorArea majorArea]identifier] isEqualToString:[_curDisplayedMajorArea identifier]]) {
        _switchingFloor = YES;
        [_mapView removeUserLocation];
        /*if (![[[_navigationPlan.targetPoiSource majorArea] identifier]isEqualToString:[[minorArea majorArea] identifier]] && _navigationView.isNavigating) {
         _navigationView.isShowSwitchButton = YES;
         }*/
        if(!_navigationView.isNavigating){
            if(!_shownFloorChange && _viewDidAppear){
                [_moveCurrentButton promptFloorChange:[[[_userMinorArea majorArea] floor] floorName]];
                [_changeFloorIndicator.layer removeAllAnimations];
                
                _changeFloorIndicator.hidden = NO;
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
                animation.toValue = [NSNumber numberWithFloat:_changeFloorIndicator.layer.position.y+30];
                animation.fromValue = [NSNumber numberWithFloat:_changeFloorIndicator.layer.position.y];
                animation.duration = 0.5;
                animation.delegate = self;
                animation.repeatCount = 5;
                [_changeFloorIndicator.layer addAnimation:animation forKey:@"animation"];
                _shownFloorChange = YES;
                
            }
        }else{
            _navigationView.isShowSwitchButton = true;
        }
        _shownUser = NO;
        
    }else{
        _shownFloorChange = NO;
//        if (_userCoordintate.latitude == -888) {
//            _userCoordintate = _userCord;
//        }
//        [self showUserAtCoordinate:_userCoordintate];
        _switchingFloor = NO;
    }
    
    
    
    //当检测到换了一个mall
    if(![[[[[[minorArea majorArea] floor] block] mall] identifier] isEqualToString:[[[[_curDisplayedMajorArea floor] block] mall] identifier]]){
        
        if(_navigationView.isNavigating){
            [_mapView removePath];
            [_mapView removeUserLocation];
            return;
        }
        [self switchFloor:[[minorArea majorArea] floor] hideCallOut:true];
        [self refreshLocatorWithMapView:_mapView.map majorArea:[minorArea majorArea]];
        [self redrawBlockAndFloorSwitch];
        _shownFloorChange = NO;
    }
    _userMinorArea = minorArea;
    [self updateNavManagerIfNeeded];
    
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    _changeFloorIndicator.hidden = YES;
}


-(id<YTBeacon>)getYTBeacon:(ESTBeacon *)beacon{
    
    FMDatabase *db = [YTDataManager defaultDataManager].database;
    [db open];
    FMResultSet *result = [db executeQuery:@"select * from Beacon where major = ? and minor = ?",[beacon.major stringValue],[beacon.minor stringValue]];
    [result next];
    YTLocalBeacon *localBeacon = [[YTLocalBeacon alloc] initWithDBResultSet:result];
    
    
    return localBeacon;
}


#pragma mark switch floor and block delegate methods
-(void)switchBlock:(id<YTBlock>)block{
    if(_switchFloorView.toggle){
        [_switchFloorView toggleFloor];
    }

    id<YTMajorArea> majorArea = [[[[block floors] firstObject] majorAreas] firstObject];
    if (![[block blockName] isEqualToString:[[[_curDisplayedMajorArea floor]block] blockName]]) {
        if(_shownCallout && [_mapView currentState] == YTMapViewDetailStateNormal){
            _selectedPoi = nil;
            [self hideCallOut];
        }
        [_mapView displayMapNamed:[majorArea mapName]];
        _shownFloorChange = NO;
        if([[[_userMinorArea majorArea] identifier] isEqualToString:[majorArea identifier]]){
            [self refreshLocatorWithMapView:_mapView.map majorArea:majorArea];
        }
        else{
            [_beaconManager removeListener:_locator];
            _locator = nil;
        }
        _curDisplayedMajorArea = majorArea;
        [self cancelCommonPoiState];
    }
    [_switchFloorView redrawWithMajorArea:_curDisplayedMajorArea];
    
    [self handlePoiForMajorArea:majorArea];
    
}
-(void)switchFloor:(id<YTFloor>)floor{
    
    [self switchFloor:floor hideCallOut:YES];
    
    
}

-(void)switchFloor:(id<YTFloor>)floor
       hideCallOut:(BOOL)hide{
    
    id<YTMajorArea> majorArea = [[floor majorAreas] firstObject];
    if (![[floor identifier] isEqualToString:[[_curDisplayedMajorArea floor]identifier]]) {
        if( hide && _shownCallout && [_mapView currentState] != YTMapViewDetailStateNavigating ){
            [self hideCallOut];
        }
        [_switchFloorView promptFloorChange:floor];
        [_mapView displayMapNamed:[majorArea mapName]];
        _shownFloorChange = NO;
        [_mapView setZoom:1 animated:NO];
        
        if([[[_userMinorArea majorArea] identifier] isEqualToString:[majorArea identifier]]){
            [self refreshLocatorWithMapView:_mapView.map majorArea:majorArea];
        }
        else{
            [_beaconManager removeListener:_locator];
            _locator = nil;
        }
        
        _curDisplayedMajorArea = majorArea;
        [self cancelCommonPoiState];
        return;
    }
    
    [self handlePoiForMajorArea:majorArea];
}


-(void)handlePoiForMajorArea:(id<YTMajorArea>)majorArea{
    [_mapView removeAnnotations];
    [_mapView removeUserLocation];
    [_allElvatorAndEscalator removeAllObjects];
    _shownUser = NO;
    [self injectPoisForMajorArea:majorArea];
}



#pragma mark moveToTarget/self

-(void)moveToTargetLocationButtonClicked{
    id<YTPoiSource>target = [_selectedPoi sourceModel];
    id<YTFloor> floor = [[target majorArea] floor];
    if (![[[_curDisplayedMajorArea floor] floorName] isEqualToString:[ floor floorName]]) {
        [self switchFloor:floor];
        [_mapView setCenterCoordinate:[target coordinate] animated:YES];
        
    }else{
        [_mapView setCenterCoordinate:[target coordinate] animated:YES];
    }
}

-(void)moveToUserLocationButtonClicked{
    
    //if user is not present
    if(_userMinorArea == nil){
        [[[YTMessageBox alloc]initWithTitle:@"虾逛提示" Message:[self messageFromButtonType:YTMessageTypeFromCurrentButton] cancelButtonTitle:@"知道了"]show];
        return;
    }
    
    //if same flooor
    if([[[_curDisplayedMajorArea floor] identifier] isEqualToString:[[[_userMinorArea majorArea] floor] identifier]]){
        if (_userCoordintate.latitude == -888) {
            _userCoordintate = _userCord;
        }
        [_mapView setCenterCoordinate:_userCoordintate animated:YES];
        [AVAnalytics event:@"sameFloorMoveToUser"];
        
        if(_navigationView.isShowSwitchButton){
            _navigationView.isShowSwitchButton = false;
        }
        
    }
    //different floor
    else{
        
        [self switchFloor:[[_userMinorArea majorArea] floor]];
        //[_mapView showUserLocationAtCoordinate:_userCoordintate];
        [_mapView setCenterCoordinate:[_userMinorArea coordinate] animated:NO];
        [_switchFloorView promptFloorChange:[[_userMinorArea majorArea] floor]];
        [AVAnalytics event:@"differentFloorMoveToUser"];
    }
    
}

#pragma mark YTZoomSteep delegate
-(void)increasing{
    [_mapView zoomIn];
}
-(void)diminishing{
    [_mapView zoomOut];
}
#pragma mark DetailsView delegate
-(void)navigatingToPoiSourceClicked:(id<YTPoiSource>)merchantLocation{
    _navigationView.hidden = NO;
    NSString *message = nil;
    [AVAnalytics event:@"开始导航" label:[merchantLocation name]];
    if(_userMinorArea == nil){
        
        [[[YTMessageBox alloc]initWithTitle:@"虾逛提示" Message:[self messageFromButtonType:YTMessageTypeFromNavigationButton] cancelButtonTitle:@"知道了"]show];
        return;
    }
    
    [_navigationView startNavigationAndSetDestination:merchantLocation];
    
    _navigationPlan = [[YTNavigationModePlan alloc] initWithTargetPoiSource:merchantLocation];
    _navigationView.plan = _navigationPlan;
    
    if (![[[_userMinorArea majorArea] identifier]isEqualToString:[_curDisplayedMajorArea identifier]]) {
        _shownFloorChange = NO;
        [self switchFloor:[[_userMinorArea majorArea] floor] hideCallOut:false];
        [_switchFloorView promptFloorChange:[[_userMinorArea majorArea] floor]];
    }
    
    
    if([[[[merchantLocation majorArea]floor] floorName] isEqualToString:[[[_userMinorArea majorArea] floor] floorName]]){
        
        [_mapView zoomToShowPoint1:[merchantLocation coordinate]  point2:[_userMinorArea coordinate]];
        YTPoi *poi = [merchantLocation producePoi];
        
        [_mapView superHighlightPoi:poi animated:YES];
        
        _targetCord = [merchantLocation coordinate];
        [self setTargetCordToDoorCoordIfPossible:merchantLocation];
        
        if (_userCoordintate.latitude == -888) {
            _userCoordintate = _userCord;
        }
        _lastStableCoordinate = _userCoordintate;
        [_mapView showPathFromCoord1:_userCoordintate toCoord2:_targetCord forMajorArea:_curDisplayedMajorArea];
        
    }
    
    double distance = [_mapView canonicalDistanceFromCoordinate1:_userCoordintate toCoordinate2:[_navigationPlan.targetPoiSource coordinate]];
    [_navigationPlan updateWithCurrentUserMinorArea:_userMinorArea distanceToTarget:distance andDisplayedMajorArea:_curDisplayedMajorArea];
    [_navigationView updateInstruction];
    
    [self showNavigationViewsCopmeletion:^{
        _shownCallout = NO;
        _poiButton.hidden = YES;
        _moveTargetButton.hidden = NO;
    }];
}

-(void)showNavigationViewsCopmeletion:(void(^)(void))copmeletion{
    [UIView animateWithDuration:.2 animations:^{
        [_mapView setMapViewDetailState:YTMapViewDetailStateNavigating];
        CGRect frame = _detailsView.frame;
        frame.origin.x = -CGRectGetWidth(self.view.frame);
        _detailsView.frame = frame;
        
        frame = _navigationView.frame;
        frame.origin.x = 0;
        _navigationView.frame = frame;
        //
        //        frame = _switchBlockView.frame;
        //        frame.origin.y -= 44;
        //        _switchBlockView.frame = frame;
        //
        //        frame = _switchFloorView.frame;
        //        frame.origin.y -= 44;
        //        _switchFloorView.frame = frame;
        
    } completion:^(BOOL finished) {
        if (copmeletion != nil && finished) {
            copmeletion();
        }
    }];
    
}

#pragma mark navigationView delegate
-(void)jumToUserFloor{
    if(_navigationView.isShowSwitchButton){
        [self moveToUserLocationButtonClicked];
    }
}


-(void)stopNavigationMode{
    switch (_type) {
        case YTMapViewControllerTypeNavigation:
            
            break;
            
        default:
            [_mapView removeUserLocation];
            _shownUser = NO;
            break;
    }
    
    [_mapView hidePoi:_selectedPoi animated:YES];
    [_mapView hidePois:_allElvatorAndEscalator animated:YES];
    [_mapView removePath];
    _forceRepath = true;
    [_navigationBar setHidden:false];
    
    [UIView animateWithDuration:.2 animations:^{
        [_mapView setMapViewDetailState:YTMapViewDetailStateNormal];
        CGRect frame = _navigationView.frame;
        frame.origin.y = CGRectGetHeight(self.view.frame);
        _navigationView.frame = frame;
        
        frame = _moveTargetButton.frame;
        frame.origin.y += HOISTING_HEIGHT;
        _moveTargetButton.frame = frame;
        
        frame = _zoomStepper.frame;
        frame.origin.y += HOISTING_HEIGHT;
        _zoomStepper.frame = frame;
        
        frame = _moveCurrentButton.frame;
        frame.origin.y += HOISTING_HEIGHT;
        _moveCurrentButton.frame = frame;
        
        frame = _changeFloorIndicator.frame;
        frame.origin.y += HOISTING_HEIGHT;
        _changeFloorIndicator.frame = frame;
        
        //        frame = _switchBlockView.frame;
        //        frame.origin.y += 44;
        //        _switchBlockView.frame = frame;
        //
        //        frame = _switchFloorView.frame;
        //        frame.origin.y += 44;
        //        _switchFloorView.frame = frame;
        
        frame = _selectedPoiButton.frame;
        frame.origin.y += HOISTING_HEIGHT;
        _selectedPoiButton.frame = frame;
        
        
    } completion:^(BOOL finished) {
        _detailsView.frame = CGRectMake(CGRectGetMinX(_mapView.frame), CGRectGetHeight(self.view.frame), CGRectGetWidth(_mapView.frame), 80);
        _navigationView.frame =CGRectMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 80 ,  CGRectGetWidth(_mapView.frame), 80);
        _navigationView.hidden = YES;
        _selectedPoi = nil;
        _poiButton.hidden = NO;
        _moveTargetButton.hidden = YES;
        _navigationView.hidden = YES;
        if(_activePois != nil){
            [self cancelCommonPoiState];
        }
    }];
}
#pragma mark poiButton & poiView  delegate
-(void)poiButtonClicked{
    [_poiView show];
}

-(void)highlightTargetGroupOfPoi:(id)poiObject{
    if ([poiObject isMemberOfClass:[YTCategory class]]){
        YTCategory *category = poiObject;
        [_selectedPoiButton setPoiImage:category.image];
        
    }else{
        if (_activePois.count > 0) {
            [_mapView hidePois:_activePois animated:YES];
        }
        YTCommonlyUsed *commonlyUsed = poiObject;
        _activePois = [self getPoisForGroupName:[poiObject name]];
        _activeGroupName = [poiObject name];
        _activePoiMajorArea = _curDisplayedMajorArea;
        if(_activePois != nil && _activePois.count > 0){
            [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(0, 0) animated:YES];
            [_mapView setZoom:1 animated:NO];
            [_mapView highlightPois:_activePois animated:YES];
            [_selectedPoiButton setPoiImage:commonlyUsed.icon];
            _selectOnOneOfThePoi = YES;
        }else{
            YTCommonlyUsed *commonlyUsed = poiObject;
            NSString *message = [NSString stringWithFormat:@"很抱歉，该楼层没有%@",commonlyUsed.name];
            [[[YTMessageBox alloc]initWithTitle:@"" Message:message cancelButtonTitle:@"知道了"]show];
            [_poiView deleteSelectedPoi];
            [self cancelCommonPoiState];
            _selectOnOneOfThePoi = NO;
        }
    }
}


-(NSArray *)getPoisForGroupName:(NSString *)groupName{
    NSArray *models;
    if([groupName isEqualToString:@"洗手间"]){
        models = [_curDisplayedMajorArea bathrooms];
    }
    if([groupName isEqualToString:@"出入口"]){
        models = [_curDisplayedMajorArea exits];
    }
    if([groupName isEqualToString:@"电梯"]){
        models = [_curDisplayedMajorArea elevators];
    }
    if([groupName isEqualToString:@"扶梯"]){
        models = [_curDisplayedMajorArea escalators];
    }
    if([groupName isEqualToString:@"服务台"]){
        models = [_curDisplayedMajorArea serviceStations];
    }
    
    if([models count] <= 0){
        
        return nil;
    }
    NSMutableArray *pois = [NSMutableArray array];
    for(id<YTPoiSource> source in models){
        [pois addObject:[source producePoi]];
    }
    return pois;
}

#pragma mark selectedPoi delegate
-(void)selectedPoiButtonClicked{
    if(_navigationView.isNavigating){
        return;
    }
    
    [self cancelCommonPoiState];
    [_selectedPoiButton hide];
    [_mapView hidePoi:_selectedPoi animated:NO];
    if(_selectedPoi != nil){
        [self hideCallOut];
    }
    
}

-(void)cancelCommonPoiState{
    _activePois = nil;
    _activeGroupName = nil;
    _activePoiMajorArea = nil;
    [_poiView deleteSelectedPoi];
    [_mapView hidePois:_activePois animated:YES];
    [_mapView removePois:_activePois];
    _selectedPoiButton.hidden = YES;
    _selectOnOneOfThePoi = NO;
    [self handlePoiForMajorArea:_curDisplayedMajorArea];
}

//设置状态栏颜色
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark helper
-(void)updateNavManagerIfNeeded{
    if(_navigationView.isNavigating == YES){
        double distance = [_mapView canonicalDistanceFromCoordinate1:_userCoordintate toCoordinate2:[_navigationPlan.targetPoiSource coordinate]];
        [_navigationPlan updateWithCurrentUserMinorArea:_userMinorArea distanceToTarget:distance andDisplayedMajorArea:_curDisplayedMajorArea];
        [_navigationView updateInstruction];
    }
}
#pragma mark bluetoothState
-(void)bluetoothStateChange:(NSNotification *)notification{
    
    if(_currentViewDisplay && _firstBlueToothRefresh){
        NSDictionary *userInfo = notification.userInfo;
        BOOL on = [userInfo[@"isOpen"] boolValue];
        if(on){
            [AVAnalytics event:@"进入mapview时蓝牙开启"];
        }
        else{
            [AVAnalytics event:@"进入mapview时蓝牙关闭"];
        }
    }
    
    if([_mapView currentState] != YTMapViewDetailStateNormal){
        if([_mapView currentState] == YTMapViewDetailStateNavigating){
            [_navigationView stopNavigationMode];
        }
        if([_mapView currentState] == YTMapViewDetailStateShowDetail){
            //[self hideCallOut];
        }
        [self handlePoiForMajorArea:_curDisplayedMajorArea];
    }
    if (_currentViewDisplay) {
        NSDictionary *userInfo = notification.userInfo;
        _bluetoothOn = [userInfo[@"isOpen"] boolValue];
        if (_bluetoothOn) {
            if(!_firstBlueToothRefresh){
                [AVAnalytics event:@"开启蓝牙动作"];
            }
            [_beaconManager startRangingBeacons];
            _beaconManager.delegate = self;
            if(_userMinorArea != nil){
                if(_blurMenuShown){
                    [UIView animateWithDuration:0.51 animations:^{
                        [self hideBlur];
                    }];
                    [self redrawBlockAndFloorSwitch];
                }
            }
        }else{
            
            if(!_firstBlueToothRefresh){
                [AVAnalytics event:@"关闭蓝牙动作"];
            }
            
            _userMinorArea = nil;
            [_mapView removeUserLocation];
            _shownUser = NO;
            [_beaconManager stopRanging];
            if (!_isFirstBluetoothPrompt) {
                
                _isFirstBluetoothPrompt = NO;
            }
        }
    }
    
    _firstBlueToothRefresh = NO;
}

- (NSString *)messageFromButtonType:(YTMessageType)type{
    NSMutableString *subMessage = [NSMutableString string];
    NSString *mallId = [[[NSUserDefaults standardUserDefaults]valueForKey:@"currentMall"] stringValue];
    
    if (!_bluetoothOn){
        [subMessage appendString:@"请开启蓝牙功能以支持室内定位"];
    }else{
        if ([mallId isEqualToString:[_targetMall identifier]]) {
            // 在附近一公里范围内
            [subMessage appendString:@"很抱歉，您不在覆盖范围"];
        }else{
            // 不在附近一公里范围内
            [subMessage appendString:@"很抱歉，当前您不在该商城"];
        }
    }
    
//    if (_bluetoothOn) {
//        if (!_userMinorArea) {
//            [subMessage appendString:[NSString stringWithFormat:@"您当前不在%@,",[[[[_curDisplayedMajorArea floor] block] mall] mallName]]];
//        }else{
//            [subMessage appendString:@"您当前不处于导航模式"];
//        }
//    }else{
//        [subMessage appendString:@"请开启蓝牙功能以支持室内定位"];
//        return subMessage;
//    }
//    
//    switch (type) {
//        case YTMessageTypeFromCurrentButton:
//            [subMessage appendString:@"无法定位当前位置"];
//            break;
//        case YTMessageTypeFromNavigationButton:
//            [subMessage appendString:@"无法使用导航功能"];
//            break;
//    }
    return subMessage;
}



-(void)selectedItemAtIndex:(NSInteger)index{
    id<YTMall> selected = [_malls objectAtIndex:index];
    YTLocalMall *local;
    if([selected isMemberOfClass:[YTLocalMall class]]){
        local = selected;
    }
    else{
        local = [_mallDict changeMallObject:selected resultType:YTMallClassLocal];
    }
    id<YTBlock> firstBlock = [[local blocks] objectAtIndex:0];
    id<YTFloor> firstFloor = [[firstBlock floors] objectAtIndex:0];
    _majorArea = [[firstFloor majorAreas] objectAtIndex:0];
    
    [_mapView displayMapNamed:[_majorArea mapName]];
    _shownFloorChange = NO;
    [self refreshLocatorWithMapView:_mapView.map majorArea:_majorArea];
    _curDisplayedMajorArea = _majorArea;
    [self handlePoiForMajorArea:_majorArea];
    [self redrawBlockAndFloorSwitch];
    [self setTargetMall:[[[_majorArea floor] block] mall]];
    [self hideBlur];
}

-(void)backClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark YTBeaconBasedLocatorDelegate method
- (void)YTBeaconBasedLocator:(YTBeaconBasedLocator *)locator
           coordinateUpdated:(CLLocationCoordinate2D)coordinate{
    
    _userCoordintate = coordinate;
    
    if([[_curDisplayedMajorArea identifier] isEqualToString:[[_userMinorArea majorArea] identifier]]){
        //[_mapView showUserLocationAtCoordinate:coordinate];
        [self showUserAtCoordinate:coordinate];
    }
    else{
        //NSLog(@"shouldn't even be here");
    }
}

-(void)refreshLocatorWithMapView:(RMMapView *)aMapView
                       majorArea:(id<YTMajorArea>)aMajorArea{
    
    
    [_beaconManager removeListener:_locator];
    
    _locator = [[YTBeaconBasedLocator alloc] initWithMapView:aMapView beaconManager:_beaconManager majorArea:aMajorArea mapOffset:[_targetMall offset]];
    
    
    [_locator start];
    [_beaconManager addListener:_locator];
    _locator.delegate = self;
    _userCoordintate = CLLocationCoordinate2DMake(-888, -888);
    _lastStableCoordinate = CLLocationCoordinate2DMake(-888, -888);
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _malls.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor colorWithString:@"000000" alpha:0.1];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textAlignment = 1;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [_malls[indexPath.row] mallName];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        if(indexPath.row == _malls.count - 1){
            if ([[UIDevice currentDevice].systemVersion hasPrefix:@"7"]){
                [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(_mallTableView.frame))];
            }else{
                [cell setSeparatorInset:UIEdgeInsetsMake(0, CGRectGetWidth(_mallTableView.frame), 0, 0)];
            }
            
        }else{
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
        }
        
    }
    if ([[UIDevice currentDevice].systemVersion hasPrefix:@"8"] && [cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 10)];
        if (indexPath.row == _malls.count -1){
            [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(_mallTableView.frame))];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self selectedItemAtIndex:indexPath.row];
}

-(void)setTargetMall:(id<YTMall>)aMall{
    if ([[_targetMall identifier]isEqualToString:[aMall identifier]]) {
        return;
    }
    
    if (!_navigationView.isNavigating || _type != YTMapViewControllerTypeFloor) {
        _navigationBar.titleName = [aMall mallName];
        _targetMall = aMall;
        [_mapView setMapOffset:[_targetMall offset]];
        [self createSearchView];
        
        id <YTMall> mall = [_mallDict changeMallObject:aMall resultType:YTMallClassCloud];
        _mapView.isShowPath = [mall isShowPath];
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(_alert!= nil){
        [self dismissViewControllerAnimated:YES completion:nil];
        _alert = nil;
    }
}

-(void)dealloc{
    NSLog(@"destroy mapviewController");
    [_searchView removeFromSuperview];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:YTBluetoothStateHasChangedNotification object:nil];
}
@end
