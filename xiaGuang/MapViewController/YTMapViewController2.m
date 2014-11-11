//
//  YTMapViewController2.m
//  HighGuang
//
//  Created by Yuan Tao on 10/16/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTMapViewController2.h"

#define BIGGER_THEN_IPHONE5 ([[UIScreen mainScreen]currentMode].size.height >= 1136.0f ? YES : NO)

#define HOISTING_HEIGHT 70
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
    id<YTMinorArea> _minorArea;
    id<YTMajorArea> _majorArea;
    YTBeaconManager *_beaconManager;
    YTBluetoothManager *_bluetoothManager;
    id<YTMerchantLocation> _merchantLocation;
    
    BOOL _bluetoothOn;
    BOOL _isFirstBluetoothPrompt;
    BOOL _isFirstEnter;
    BOOL _currentViewDisplay;
    
    YTMapViewControllerType _type;
    
    YTNavigationBar *_navigationBar;
    
    YTSearchView *_searchView;
    YTMoveCurrentLocationButton *_moveCurrentButton;
    YTMoveTargetLocationButton *_moveTargetButton;
    YTPoiButton *_poiButton;
    YTZoomStepper *_zoomStepper;
    YTSwitchFloorView *_switchFloorView;
    YTSwitchBlockView *_switchBlockView;
    YTDetailsView *_detailsView;
    YTSelectedPoiButton *_selectedPoiButton;
    UIImageView *_noBeaconCover;
    BlurMenu *_menu;
    UIAlertView *_alert;
    
    
    
    //states
    id<YTMajorArea> _curDisplayedMajorArea;
    id<YTMinorArea> _userMinorArea;
    BOOL _switchingFloor;
    NSArray *_activePois;
    id<YTMajorArea> _activePoiMajorArea;
    BOOL _blurMenuShown;
    id<YTMall> _targetMall;
    BOOL _shownUser;
    
    //navigation related
    YTNavigationModePlan *_navigationPlan;
    YTNavigationView *_navigationView;
    
    YTPoiView *_poiView;
    
    YTPoi *_selectedPoi;
    CLLocationCoordinate2D _userCord;
    CLLocationCoordinate2D _targetCord;
    
    NSMutableArray *_malls;
    
    YTBeaconBasedLocator *_locator;
    
    CLLocationCoordinate2D _userCoordintate;
    
    CLLocationCoordinate2D _lastRecordedCoordinate;
    
    
}

@end

@implementation YTMapViewController2{
    YTMapView2 *_mapView;
}

-(id)initWithMinorArea:(id <YTMinorArea>)minorArea{
    self  = [super init];
    if (self) {
        if (minorArea != nil) {
            _minorArea = minorArea;
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
            _targetMall = [[[_majorArea floor] block]mall];
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
            _targetMall = [[[_majorArea floor] block]mall];
        }
        _type = YTMapViewControllerTypeFloor;
    }
    return self;
}


-(void)viewDidLoad{
    [super viewDidLoad];
    _shownUser = NO;
    
    _malls = [NSMutableArray array];
    _isFirstBluetoothPrompt = YES;
    _isFirstEnter = YES;
    _curDisplayedMajorArea = _majorArea;
    _bluetoothManager = [YTBluetoothManager shareBluetoothManager];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(bluetoothStateChange:) name:YTBluetoothStateHasChangedNotification object:nil];
    
    UIImageView *background = [[UIImageView alloc]initWithFrame:self.view.bounds];
    background.image = [UIImage imageNamed:@"nav_bg_pic.jpg"];
    [self.view addSubview:background];
    _beaconManager = [YTBeaconManager sharedBeaconManager];
    _beaconManager.delegate = self;
    
    [self createNavigationBar];
    [self createMapView];
    [self createBlockAndFloorSwitch];
    [self createCurLocationButton];
    [self createCommonPoiButton];
    [self createZoomStepper];
    [self createDetailsView];
    [self createNavigationView];
    [self createPoiView];
    [self createNoBeaconCover];
    [self createBlurMenuWithCallBack:nil];
    [self createSearchView];


    
    /*
    
    if(_minorArea == nil){
        
        NSLog(@"didload");
        [self createBlurMenu];
        
    }
    else{
        _noBeaconCover.hidden = YES;
    }
    
    if (_type == YTMapViewControllerTypeNavigation) {
        
        [self userMoveToMinorArea:_minorArea];
        [_beaconManager startRangingBeacons];
        return;
    }*/

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _currentViewDisplay = YES;
    [_bluetoothManager refreshBluetoothState];
    if (_type == YTMapViewControllerTypeMerchant) {
        [_mapView setCenterCoordinate:[_merchantLocation coordinate] animated:NO];
        _selectedPoi = [_merchantLocation producePoi];
        [_mapView highlightPoi:_selectedPoi animated:YES];
        [_detailsView setCommonPoi:_merchantLocation];
        
        [self showCallOut];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    _currentViewDisplay = NO;
    

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    
    NSLog(@"didAppear");
    if(_userMinorArea == nil){
        
        if(!_blurMenuShown){
            _noBeaconCover.hidden = NO;
            
            if(_type == YTMapViewControllerTypeNavigation){
                
            
                if(_menu == nil){
                    [self createBlurMenuWithCallBack:^{
                        [_menu show];
                    }];
                    //[_menu show];
                }
                else{
                    [_menu show];
                }
                if([_mapView currentState] != YTMapViewDetailStateNormal){
                    [_mapView setMapViewDetailState:YTMapViewDetailStateNormal];
                    [self hideCallOut];
                }
            }
            
            
            
        }
    }
    else{
        _noBeaconCover.hidden = YES;
        [_menu hide];
    }
    
    if(_type != YTMapViewControllerTypeNavigation){
        
        [_menu hide];
        _noBeaconCover.hidden = YES;
        [self redrawBlockAndFloorSwitch];
        
    }
}

-(void)createBlurMenuWithCallBack:(void (^)())callback{
    AVQuery *query = [AVQuery queryWithClassName:@"Mall"];
    [query whereKeyExists:@"localDBId" ];
    query.cachePolicy = kAVCachePolicyCacheElseNetwork;
    query.maxCacheAge = 3 * 24 * 3600;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            
            _malls = [NSMutableArray array];
            
            for (AVObject *mallObject in objects) {
                YTCloudMall *mall = [[YTCloudMall alloc]initWithAVObject:mallObject];
                
                [_malls addObject:mall];
                
            }
            [self instantiateMenu];
            if(callback!= nil){
                callback();
            }
            
        }else{
            //获取失败
            if(_alert == nil){
                _alert = [[UIAlertView alloc]initWithTitle:@"对不起" message:@"您的网络状况不好，无法显示商城内容，请检查是否开启无线网络" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
                
                if(_userMinorArea == nil){
                    [_alert show];
                }
                
            }
        }
        
    }];
}

-(void)createNoBeaconCover{
    UIImage *fake;
    if (BIGGER_THEN_IPHONE5) {
        fake = [UIImage imageNamed:@"home_bg1136@2x.jpg"];
    }else{
        fake = [UIImage imageNamed:@"home_bg960@2x.jpg"];
    }
    _noBeaconCover = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _noBeaconCover.image = fake;
    //_noBeaconCover.backgroundColor = [UIColor blackColor];
    //_noBeaconCover.alpha = 0.5;
    _noBeaconCover.hidden = NO;
    
    [self.view addSubview:_noBeaconCover];
}

-(void)instantiateMenu{
    NSMutableArray *mallNames = [NSMutableArray array];
    for(id<YTMall> mall in _malls){
        [mallNames addObject:[mall mallName]];
    }
    
    _menu = [[BlurMenu alloc] initWithItems:mallNames parentView:self.view delegate:self];
    
    //[_menu show];
}





-(void)createMapView{
    _mapView = [[YTMapView2 alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_navigationBar.frame), CGRectGetWidth(_navigationBar.frame) - 20, CGRectGetHeight(self.view.frame) - CGRectGetHeight(_navigationBar.frame) - 10)];
    _mapView.delegate = self;
    
    [self.view addSubview:_mapView];
    
    [_mapView displayMapNamed:[_majorArea mapName]];
    [self refreshLocatorWithMapView:_mapView.map majorArea:_majorArea];
    
    [_mapView setZoom:1 animated:NO];
    [self injectPoisForMajorArea:_majorArea];
}
    


-(void)injectPoisForMajorArea:(id<YTMajorArea>)majorArea{
    
    
    
    if([[[_userMinorArea majorArea] identifier] isEqualToString:[_curDisplayedMajorArea identifier]]){
        //[_mapView showUserLocationAtCoordinate:_userCoordintate];
        [self showUserAtCoordinate:_userCoordintate];
    }
    
    NSArray *merchants = [majorArea merchantLocations];
    NSMutableArray *pois = [NSMutableArray array];
    
    YTPoi *highlightPoi = nil;
    
    for(id<YTMerchantLocation> tmpMerchant in merchants){
        YTPoi *tmpPoi = [tmpMerchant producePoi];
        if ([tmpPoi.poiKey isEqualToString:_selectedPoi.poiKey]) {
            highlightPoi = tmpPoi;
            
        }
        [pois addObject:tmpPoi];
    }
    
    [_mapView addPois:pois];
    
    if(highlightPoi != nil && _navigationView.isNavigating){
        [_mapView superHighlightPoi:highlightPoi];
        //[_mapView highlightPoi:highlightPoi animated:NO];
    }
    if(highlightPoi != nil && !_navigationView.isNavigating){
        //[_mapView superHighlightPoi:highlightPoi];
        [_mapView highlightPoi:highlightPoi animated:NO];
    }
    
    if(_activePois != nil && _activePois.count > 0 && [[_activePoiMajorArea identifier] isEqualToString:[_curDisplayedMajorArea identifier]]){
        [_mapView addPois:_activePois];
        [_mapView highlightPois:_activePois animated:NO];
        [_mapView superHighlightPoi:_selectedPoi];
    }
    
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
            title = @"店铺详情";
            break;
        case YTMapViewControllerTypeNavigation:
            title = @"首页";
            break;
    }
    _navigationBar.backTitle = title;
    _navigationBar.titleName = [_targetMall mallName];
    [self.view addSubview:_navigationBar];
}
-(void)createSearchView{
    _searchView = [[YTSearchView alloc]initWithMall:[[[_majorArea floor]block]mall] placeholder:@"商城/品牌" indent:NO];
    _searchView.delegate = self;
    [_searchView addInView:self.view show:NO];
    [_searchView setBackgroundImage:[UIImage imageNamed:@"all_bg_navbar-1"]];
}
-(void)createCurLocationButton{
    _moveCurrentButton = [[YTMoveCurrentLocationButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_mapView.frame) + 10,CGRectGetMaxY(_mapView.frame) - 50, 40, 40)];
    _moveCurrentButton.delegate = self;
    [self.view addSubview:_moveCurrentButton];
    
    _moveTargetButton = [[YTMoveTargetLocationButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_moveCurrentButton.frame) + 10,CGRectGetMinY(_moveCurrentButton.frame), CGRectGetWidth(_moveCurrentButton.frame), CGRectGetHeight(_moveCurrentButton.frame))];
    _moveTargetButton.hidden = YES;
    _moveTargetButton.delegate = self;
    [self.view addSubview:_moveTargetButton];
}

-(void)createCommonPoiButton{
    _poiButton = [[YTPoiButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_mapView.frame) + 60, CGRectGetMaxY(_mapView.frame) - 50, 40, 40)];
    _poiButton.delegate = self;
    [self.view addSubview:_poiButton];
    
    _selectedPoiButton = [[YTSelectedPoiButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_poiButton.frame) + 10, CGRectGetMinY(_poiButton.frame), CGRectGetWidth(_poiButton.frame), CGRectGetHeight(_poiButton.frame))];
    _selectedPoiButton.delegate = self;
    [self.view addSubview:_selectedPoiButton];
}
-(void)createZoomStepper{
    _zoomStepper = [[YTZoomStepper alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_mapView.frame) - 55, CGRectGetMaxY(_mapView.frame) - 80, 45, 70)];
    _zoomStepper.delegate = self;
    [self.view addSubview:_zoomStepper];
}
-(void)createDetailsView{
    _detailsView = [[YTDetailsView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_mapView.frame), CGRectGetHeight(self.view.frame), CGRectGetWidth(_mapView.frame), 60)];
    _detailsView.delegate = self;
    _detailsView.hidden = YES;
    [self.view addSubview:_detailsView];
}

-(void)createBlockAndFloorSwitch{
    [_switchBlockView removeFromSuperview];
    _switchBlockView = [[YTSwitchBlockView alloc]initWithPosition:CGPointMake(CGRectGetMaxX(_mapView.frame) - 52, CGRectGetMinY(_mapView.frame) + 14) currentMajorArea:_majorArea];
    _switchBlockView.delegate = self;
    [self.view addSubview:_switchBlockView];
    
    [_switchFloorView removeFromSuperview];
    _switchFloorView = [[YTSwitchFloorView alloc]initWithPosition:CGPointMake(CGRectGetMaxX(_mapView.frame) - 50, CGRectGetMinY(_mapView.frame) + 10) AndCurrentMajorArea:_majorArea];
    _switchFloorView.delegate = self;
    [self.view addSubview:_switchFloorView];
}

-(void)redrawBlockAndFloorSwitch{
    [_switchBlockView redrawWithMajorArea:_curDisplayedMajorArea];
    [_switchFloorView redrawWithMajorArea:_curDisplayedMajorArea];
}



-(void)createNavigationView{
    _navigationView = [[YTNavigationView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 70 , CGRectGetWidth(self.view.frame) - 20, 60)];
    _navigationView.isShowSwitchButton = NO;
    _navigationView.delegate = self;
    _navigationView.hidden = YES;
    [self.view addSubview:_navigationView];
    [_navigationView.layer pop_animationForKey:@"shake"];
}
-(void)createPoiView{
    _poiView = [[YTPoiView alloc]initWithShow:NO];
    _poiView.delegate = self;
}
#pragma mark MapViewDelegate
-(void)mapView:(YTMapView2 *)mapView singleTapOnMap:(CLLocationCoordinate2D)coordinate{
    if (_selectedPoi && mapView.currentState == YTMapViewDetailStateShowDetail) {
        
        //hide callout and POI for 
        if([_selectedPoi isMemberOfClass:[YTMerchantPoi class]]){
            [mapView hidePoi:_selectedPoi animated:NO];
            [self hideCallOut];
        }
        else{
            [self hideCallOut];
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
    if (_selectedPoi && mapView.currentState == YTMapViewDetailStateShowDetail) {
        
        //hide callout and POI for
        if([_selectedPoi isMemberOfClass:[YTMerchantPoi class]]){
            [mapView hidePoi:_selectedPoi animated:NO];
            [self hideCallOut];
        }
        else{
            [self hideCallOut];
        }
    }
    if (_switchBlockView.toggle) {
        [_switchBlockView toggleBlockView];
    }
    if (_switchFloorView.toggle) {
        [_switchFloorView toggleFloor];
    }
}

-(void)mapView:(YTMapView2 *)mapView tapOnPoi:(YTPoi *)poi{
    
    id<YTPoiSource> sourceModel = [poi sourceModel];
    
    //if there's activePoi
    if(_activePois != nil && [sourceModel isKindOfClass:[YTLocalMerchantInstance class]]){
        
        return;
    }
    
    if([mapView currentState] == YTMapViewDetailStateNormal){
        
        if([sourceModel isMemberOfClass:[YTLocalMerchantInstance class]]){
            [mapView highlightPoi:poi animated:YES];
            [_detailsView setCommonPoi:sourceModel];
            [self showCallOut];
            _selectedPoi = poi;
        }
        else{
            
            if (![poi.poiKey isEqualToString:_selectedPoi.poiKey]) {
                [mapView highlightPoi:_selectedPoi animated:YES];
                _selectedPoi = poi;
                [mapView superHighlightPoi:_selectedPoi];
                [_detailsView setCommonPoi:sourceModel];
                [self showCallOut];
            }
        }
    }
    else if([mapView currentState] == YTMapViewDetailStateNavigating){
        
    }
    else if([mapView currentState] == YTMapViewDetailStateShowDetail){
        
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
                [mapView highlightPoi:_selectedPoi animated:YES];
                _selectedPoi = poi;
                [mapView superHighlightPoi:_selectedPoi];
                [_detailsView setCommonPoi:sourceModel];
            }
        }
    }
}

-(void)showCallOut{
    _poiButton.hidden = YES;
    _moveTargetButton.hidden = NO;
    [UIView animateWithDuration:.5 animations:^{
        [_mapView setMapViewDetailState:YTMapViewDetailStateShowDetail];
        CGRect frame = _moveCurrentButton.frame;
        frame.origin.y -= HOISTING_HEIGHT;
        _moveCurrentButton.frame = frame;
        
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
        _detailsView.hidden = NO;
        _navigationView.hidden = NO;
    }];
}
-(void)hideCallOut{
    if(![_selectedPoi isMemberOfClass:[YTMerchantPoi class]]){
        [_mapView highlightPoi:_selectedPoi animated:NO];
    }
    _selectedPoi = nil;
    
    [UIView animateWithDuration:.5 animations:^{
        [_mapView setMapViewDetailState:YTMapViewDetailStateNormal];
        
        CGRect frame = _moveCurrentButton.frame;
        frame.origin.y += HOISTING_HEIGHT;
        _moveCurrentButton.frame = frame;
        
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

#pragma mark YTNavigationBarManager

-(void)searchButtonClicked{
    [_searchView showSearchViewWithAnimation:YES];
}

-(void)backButtonClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark YTSearchViewManager
-(void)searchCancelButtonClicked{
    [_searchView hideSearchViewWithAnimation:YES];
}

-(void)selectedMerchantName:(NSString *)name{
    FMDatabase *db = [YTDBManager sharedManager].db;
    if([db open]){
        
        FMResultSet *result = [db executeQuery:@"select * from MerchantInstance where merchantInstanceName = ?",name];
        [result next];
        YTLocalMerchantInstance *tmpMerchantInstance = [[YTLocalMerchantInstance alloc] initWithDBResultSet:result];
        
        if([tmpMerchantInstance identifier] == nil){
            return;
        }
        
        id<YTMajorArea> tmpMajorArea = [tmpMerchantInstance majorArea];
        if(tmpMajorArea != nil){
            _selectedPoi = [tmpMerchantInstance producePoi];
            [_detailsView setCommonPoi:[_selectedPoi sourceModel]];
            
            if (![[_curDisplayedMajorArea identifier]isEqualToString:[tmpMajorArea identifier]]) {
                [self switchFloor:[tmpMajorArea floor]];
            }else{
                [_mapView highlightPoi:_selectedPoi animated:YES];
            }
            [self showCallOut];
        }else{
            
        }
    }
}



#pragma mark beacons delegate methods
-(void)noBeaconsFound{
    
}
-(void)primaryBeaconShiftedTo:(ESTBeacon *)beacon{
    _majorArea = [self getMajorArea:beacon];
    NSLog(@"primary beacon shifted to %@, %@",beacon.major,beacon.minor);
    if (_majorArea != nil) {
        NSArray *minorAreas = [_majorArea minorAreas];
        for(id<YTMinorArea> minorArea in minorAreas){
            NSArray *beacons = [minorArea beacons];
            for(id<YTBeacon> tempBeacon in beacons){
                if([[tempBeacon major] integerValue] == [[beacon major] integerValue] && [[tempBeacon minor] integerValue] == [[beacon minor] integerValue])
                {
                    if([self shouldSwitchToMinorArea:minorArea]){
                    
                        [self userMoveToMinorArea:minorArea];
                        if (_type == YTMapViewControllerTypeNavigation || _navigationView.isNavigating) {
                            _navigationBar.titleName = [[[[_majorArea floor] block] mall] mallName];
                        }
                    
                    }
                }
            }
        }
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

-(BOOL)shouldSwitchToMinorArea:(id<YTMinorArea>)minorArea{
    
    //if equal to current recorded _userminorArea
    if(_userMinorArea == nil || [[[_userMinorArea majorArea] identifier] isEqualToString: [[minorArea majorArea] identifier]]){
        NSLog(@"should remain on the same floor because same floor");
        return true;
    }
    else{
        
        if(_beaconManager.readbeacons.count <= 3){
            NSLog(@"should switch because readbeacons less than 3");
            return true;
        }
        else{
            int sameFloorVotes = [self numberOfSameFloorInFirstServeralClosestBeacons:minorArea];
            if(sameFloorVotes<2){
                NSLog(@"should remain on the same floor because no overrule");
                return false;
            }
        }
    }
    NSLog(@"overruled by another major area should not remain on the same floor");
    return true;
}


-(int)numberOfSameFloorInFirstServeralClosestBeacons:(id<YTMinorArea>)minorArea{
    int count = 0;
    for(int i = 0; i<3 ; i++){
        ESTBeacon *beacon = _beaconManager.readbeacons[i];
        id<YTBeacon> localBeacon = [self getYTBeacon:beacon];
        if([[[[localBeacon minorArea] majorArea] identifier] isEqualToString:[[minorArea majorArea] identifier]]){
            count++;
        }
    }
    return count;
}

-(void)userMoveToMinorArea:(id<YTMinorArea>)minorArea{
    
    
    if(_type != YTMapViewControllerTypeNavigation){
        if(![[[[[[minorArea majorArea] floor] block] mall] identifier] isEqualToString:[_targetMall identifier]]){
            return;
        }
    }
    
    
    if(_blurMenuShown){
        [_menu hide];
        _noBeaconCover.hidden = YES;
        [self redrawBlockAndFloorSwitch];
    }
    
    
    if(![[[[[[minorArea majorArea] floor] block] mall] identifier] isEqualToString:[[[[_curDisplayedMajorArea floor] block] mall] identifier]]){
        [_mapView displayMapNamed:[[minorArea majorArea] mapName]];
        [self refreshLocatorWithMapView:_mapView.map majorArea:[minorArea majorArea]];
        _curDisplayedMajorArea = [minorArea majorArea];
        [self redrawBlockAndFloorSwitch];
        [self handlePoiForMajorArea:_curDisplayedMajorArea];
    }
    //if this minorArea is in a different major area or _userMinorArea is not created yet
    if (![[[minorArea majorArea]identifier] isEqualToString:[_curDisplayedMajorArea identifier]]) {
        _switchingFloor = YES;
        
        if (![[_curDisplayedMajorArea identifier]isEqualToString:[[minorArea majorArea] identifier]] && _navigationView.isNavigating) {
            _navigationView.isShowSwitchButton = YES;
        }
        if(!_navigationView.isNavigating){
            [_moveCurrentButton promptFloorChange:[[[_userMinorArea majorArea] floor] floorName]];
        }
        
        [_mapView removeUserLocation];
        _shownUser = NO;
        
    }else{
        
        //[_mapView showUserLocationAtCoordinate:_userCoordintate];
        [self showUserAtCoordinate:_userCoordintate];
        _switchingFloor = NO;
    }
    
    _userCord = [minorArea coordinate];
    _userMinorArea = minorArea;
    [self updateNavManagerIfNeeded];
    
}


-(id<YTMajorArea>)getMajorArea:(ESTBeacon *)beacon{
    
    FMDatabase *db = [YTDBManager sharedManager].db;
    [db open];
    FMResultSet *result = [db executeQuery:@"select * from Beacon where major = ? and minor = ?",[beacon.major stringValue],[beacon.minor stringValue]];
    [result next];
    YTLocalBeacon *localBeacon = [[YTLocalBeacon alloc] initWithDBResultSet:result];
    
    YTLocalMajorArea * majorArea = [[localBeacon minorArea] majorArea];
    return majorArea;
}
-(id<YTBeacon>)getYTBeacon:(ESTBeacon *)beacon{
    
    FMDatabase *db = [YTDBManager sharedManager].db;
    [db open];
    FMResultSet *result = [db executeQuery:@"select * from Beacon where major = ? and minor = ?",[beacon.major stringValue],[beacon.minor stringValue]];
    [result next];
    YTLocalBeacon *localBeacon = [[YTLocalBeacon alloc] initWithDBResultSet:result];
    
    
    return localBeacon;
}


#pragma mark switch floor and block delegate methods
-(void)switchBlock:(id<YTBlock>)block{
    id<YTMajorArea> majorArea = [[[[block floors] firstObject] majorAreas] firstObject];
    if (![[block blockName] isEqualToString:[[[_curDisplayedMajorArea floor]block] blockName]]) {
        
        [_mapView displayMapNamed:[majorArea mapName]];
        if([[[_userMinorArea majorArea] identifier] isEqualToString:[majorArea identifier]]){
            [self refreshLocatorWithMapView:_mapView.map majorArea:majorArea];
        }
        else{
            _locator = nil;
        }
        _curDisplayedMajorArea = majorArea;
    }
    
    
    [self handlePoiForMajorArea:majorArea];
    
}
-(void)switchFloor:(id<YTFloor>)floor{

    id<YTMajorArea> majorArea = [[floor majorAreas] firstObject];
    if (![[floor floorName] isEqualToString:[[_curDisplayedMajorArea floor]floorName]]) {
        
        [_switchFloorView promptFloorChange:floor];
        [_mapView displayMapNamed:[majorArea mapName]];
        
        [_mapView setZoom:1 animated:NO];
        
        if([[[_userMinorArea majorArea] identifier] isEqualToString:[majorArea identifier]]){
            [self refreshLocatorWithMapView:_mapView.map majorArea:majorArea];
        }
        else{
            _locator = nil;
        }
        
        _curDisplayedMajorArea = majorArea;
    }
    
    
    [self handlePoiForMajorArea:majorArea];
    
    
}


-(void)handlePoiForMajorArea:(id<YTMajorArea>)majorArea{
    [_mapView removeAnnotations];
    [_mapView removeUserLocation];
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
    
    //if same floor
    if([[[_curDisplayedMajorArea floor] identifier] isEqualToString:[[[_userMinorArea majorArea] floor] identifier]]){
        [_mapView setCenterCoordinate:[_userMinorArea coordinate] animated:YES];
        
    }
    //different floor
    else{
        [self switchFloor:[[_userMinorArea majorArea] floor]];
        //[_mapView showUserLocationAtCoordinate:_userCoordintate];
        [_mapView setCenterCoordinate:[_userMinorArea coordinate] animated:NO];
        [_switchFloorView promptFloorChange:[[_userMinorArea majorArea] floor]];
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
    NSString *message = nil;
    if (!_bluetoothOn) {
        message = @"蓝牙尚未打开";
        [[[YTMessageBox alloc]initWithTitle:@"虾逛提示" Message:message cancelButtonTitle:@"知道了"]show];
        return;
    }
    if(_userMinorArea == nil){
        
        [[[YTMessageBox alloc]initWithTitle:@"虾逛提示" Message:[self messageFromButtonType:YTMessageTypeFromNavigationButton] cancelButtonTitle:@"知道了"]show];
        return;
    }
    
    
    [_navigationView startNavigationAndSetDestination:merchantLocation];
    
    _navigationPlan = [[YTNavigationModePlan alloc] initWithTargetPoiSource:merchantLocation];
    _navigationView.plan = _navigationPlan;
    
    if (![[[_userMinorArea majorArea] identifier]isEqualToString:[_curDisplayedMajorArea identifier]]) {
        [_mapView displayMapNamed:[[_userMinorArea majorArea] mapName]];
        [self refreshLocatorWithMapView:_mapView.map majorArea:[_userMinorArea majorArea]];
        [_switchFloorView promptFloorChange:[[_userMinorArea majorArea] floor]];
        _curDisplayedMajorArea = [_userMinorArea majorArea];
        [self handlePoiForMajorArea:[_userMinorArea majorArea]];
    }
    
    
    
    
    if([[[[merchantLocation majorArea]floor] floorName] isEqualToString:[[[_userMinorArea majorArea] floor] floorName]]){
        [_mapView zoomToShowPoint1:[merchantLocation coordinate]  point2:[_userMinorArea coordinate]];
        YTPoi *poi = [merchantLocation producePoi];
        [_mapView superHighlightPoi:poi];
        //[_mapView setCenterCoordinate:CLLocationCoordinate2DMake(0, 0) animated:YES];
        //[_mapView setZoom:0.7 animated:NO];
        _targetCord = [merchantLocation coordinate];
        
    }
    else{
        
        //id<YTElevator> userMajorAreaElevator = [[[_userMinorArea majorArea] elevators] objectAtIndex:0];
        //[_mapView zoomToShowPoint1:[userMajorAreaElevator coordinate]  point2:[_userMinorArea coordinate]];
        //_targetCord =[userMajorAreaElevator coordinate];
    }
    
    [_navigationPlan updateWithCurrentUserMinorArea:_userMinorArea andDisplayedMajorArea:_curDisplayedMajorArea];
    [_navigationView updateInstruction];
    
    [self showNavigationViewsCopmeletion:^{
        _poiButton.hidden = YES;
        _moveTargetButton.hidden = NO;
        [_navigationView.layer pop_removeAllAnimations];
        POPSpringAnimation *animation = [POPSpringAnimation animation];
        animation.property = [POPAnimatableProperty propertyWithName:kPOPLayerPositionX];
        animation.velocity = @1000;
        animation.springBounciness = 20;
        [_navigationView.layer pop_addAnimation:animation forKey:@"shake"];
    }];
}

-(void)showNavigationViewsCopmeletion:(void(^)(void))copmeletion{
    [UIView animateWithDuration:.2 animations:^{
        [_mapView setMapViewDetailState:YTMapViewDetailStateNavigating];
        CGRect frame = _detailsView.frame;
        frame.origin.x = -CGRectGetWidth(self.view.frame);
        _detailsView.frame = frame;
        
        frame = _navigationView.frame;
        frame.origin.x = 20;
        _navigationView.frame = frame;
        
        frame = _switchBlockView.frame;
        frame.origin.y -= 44;
        _switchBlockView.frame = frame;
        
        frame = _switchFloorView.frame;
        frame.origin.y -= 44;
        _switchFloorView.frame = frame;
        
    } completion:^(BOOL finished) {
        if (copmeletion != nil && finished) {
            copmeletion();
        }
    }];
    
}

#pragma mark navigationView delegate
-(void)jumToUserFloor{
    
    [self moveToUserLocationButtonClicked];
    
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
        
        frame = _switchBlockView.frame;
        frame.origin.y += 44;
        _switchBlockView.frame = frame;
        
        frame = _switchFloorView.frame;
        frame.origin.y += 44;
        _switchFloorView.frame = frame;
        
        frame = _selectedPoiButton.frame;
        frame.origin.y += HOISTING_HEIGHT;
        _selectedPoiButton.frame = frame;
        
        
    } completion:^(BOOL finished) {
        _detailsView.frame = CGRectMake(CGRectGetMinX(_mapView.frame), CGRectGetHeight(self.view.frame), CGRectGetWidth(_mapView.frame), 60);
        _navigationView.frame = CGRectMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 70 , CGRectGetWidth(self.view.frame) - 20, 60);
        _selectedPoi = nil;
        _poiButton.hidden = NO;
        _moveTargetButton.hidden = YES;
        
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
        YTCommonlyUsed *commonlyUsed = poiObject;
        _activePois = [self getPoisForGroupName:[poiObject name]];
        _activePoiMajorArea = _curDisplayedMajorArea;
        if(_activePois != nil && _activePois.count > 0){
            [_mapView addPois:_activePois];
            [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(0, 0) animated:YES];
            [_mapView setZoom:1 animated:NO];
            [_mapView highlightPois:_activePois animated:YES];
            [_selectedPoiButton setPoiImage:commonlyUsed.icon];
            
        }
        else{
            [[[UIAlertView alloc]initWithTitle:@"对不起" message:@"本楼层没有你想选的目标" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil]show];
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
    if(_navigationView.isNavigating || [_mapView currentState] == YTMapViewDetailStateShowDetail){
        return;
    }
    [self cancelCommonPoiState];
    [_selectedPoiButton hide];
}

-(void)cancelCommonPoiState{
    _activePois = nil;
    _activePoiMajorArea = nil;
    [_poiView deleteSelectedPoi];
    [_mapView removePois:_activePois];
    _selectedPoiButton.hidden = YES;
    [self handlePoiForMajorArea:_curDisplayedMajorArea];
}

//设置状态栏颜色
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark helper
-(void)updateNavManagerIfNeeded{
    if(_navigationView.isNavigating == YES){
        [_navigationPlan updateWithCurrentUserMinorArea:_userMinorArea andDisplayedMajorArea:_curDisplayedMajorArea];
        [_navigationView updateInstruction];
    }
}
#pragma mark bluetoothState
-(void)bluetoothStateChange:(NSNotification *)notification{
    
    if([_beaconManager currentClosest] != nil){
        [self userMoveToMinorArea:[self getMinorArea:[_beaconManager currentClosest]]];
    }
    
    
    
    if([_mapView currentState] != YTMapViewDetailStateNormal){
        if([_mapView currentState] == YTMapViewDetailStateNavigating){
            [_navigationView stopNavigationMode];
        }
        if([_mapView currentState] == YTMapViewDetailStateShowDetail){
            [self hideCallOut];
        }
        [self handlePoiForMajorArea:_curDisplayedMajorArea];
    }
    if (_currentViewDisplay) {
        NSDictionary *userInfo = notification.userInfo;
        _bluetoothOn = [userInfo[@"isOpen"] boolValue];
        if (_bluetoothOn) {
            [_beaconManager startRangingBeacons];
            if(_userMinorArea != nil){
                if(_blurMenuShown){
                    [_menu hide];
                    _noBeaconCover.hidden = YES;
                    [self redrawBlockAndFloorSwitch];
                }
            }
            
            
            
        }else{
            
            
            _userMinorArea = nil;
            [_mapView removeUserLocation];
            _shownUser = NO;
            [_beaconManager stopRanging];
            if (!_isFirstBluetoothPrompt) {
                
                _isFirstBluetoothPrompt = NO;
            }
        }
    }
}

- (NSString *)messageFromButtonType:(YTMessageType)type{
    NSMutableString *subMessage = [NSMutableString string];
    if (!_userMinorArea) {
        [subMessage appendString:[NSString stringWithFormat:@"您当前不在%@,",[[[[_curDisplayedMajorArea floor] block] mall] mallName]]];
    }else{
        [subMessage appendString:@"您当前不处于导航模式"];
    }
    
    switch (type) {
        case YTMessageTypeFromCurrentButton:
            [subMessage appendString:@"无法定位当前位置"];
            break;
        case YTMessageTypeFromNavigationButton:
            [subMessage appendString:@"无法使用导航功能"];
            break;
    }
    return subMessage;
}


#pragma mark blurMenu
-(void)menuDidHide{
    //[self dismissViewControllerAnimated:YES completion:nil];
    _blurMenuShown = NO;
}
-(void)menuDidShow{
    _blurMenuShown = YES;
}
-(void)selectedItemAtIndex:(NSInteger)index{
    _noBeaconCover.hidden = YES;
    
    YTCloudMall *selected = [_malls objectAtIndex:index];
    YTLocalMall *local = [selected getLocalCopy];
    id<YTBlock> firstBlock = [[local blocks] objectAtIndex:0];
    id<YTFloor> firstFloor = [[firstBlock floors] objectAtIndex:0];
    _majorArea = [[firstFloor majorAreas] objectAtIndex:0];
    [_mapView displayMapNamed:[_majorArea mapName]];
    [self refreshLocatorWithMapView:_mapView.map majorArea:_majorArea];
    _curDisplayedMajorArea = _majorArea;
    [self handlePoiForMajorArea:_majorArea];
    [self redrawBlockAndFloorSwitch];
    _navigationBar.titleName = [[[[_majorArea floor] block] mall] mallName];
    [_menu hide];
    
}

-(void)backClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)dealloc{
    
    NSLog(@"destroy mapviewController");
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:YTBluetoothStateHasChangedNotification object:nil];
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

#pragma mark YTBeaconBasedLocatorDelegate method
- (void)YTBeaconBasedLocator:(YTBeaconBasedLocator *)locator
           coordinateUpdated:(CLLocationCoordinate2D)coordinate{
    //NSLog(@"cordinate!!! lat: %f, long:%f",coordinate.latitude,coordinate.longitude);
    
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
    
    _locator = [[YTBeaconBasedLocator alloc] initWithMapView:aMapView beaconManager:_beaconManager majorArea:aMajorArea];
    [_locator start];
    _locator.delegate = self;
    _userCoordintate = CLLocationCoordinate2DMake(-888, -888);
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(_alert!= nil){
        [self dismissViewControllerAnimated:YES completion:nil];
        _alert = nil;
    }
}
@end
