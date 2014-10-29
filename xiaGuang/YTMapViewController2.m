//
//  YTMapViewController2.m
//  HighGuang
//
//  Created by Yuan Tao on 10/16/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTMapViewController2.h"

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
    
    //states
    id<YTMajorArea> _curDisplayedMajorArea;
    id<YTMinorArea> _userMinorArea;
    BOOL _switchingFloor;
    NSArray *_activePois;
    
    
    //navigation related
    YTNavigationModePlan *_navigationPlan;
    YTNavigationView *_navigationView;
    
    YTPoiView *_poiView;
    
    YTPoi *_selectedPoi;
    CLLocationCoordinate2D _userCord;
    CLLocationCoordinate2D _targetCord;
    
    
    
    
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
        }
        _type = YTMapViewControllerTypeFloor;
    }
    return self;
}


-(void)viewDidLoad{
    [super viewDidLoad];
    _isFirstBluetoothPrompt = YES;
    _isFirstEnter = YES;
    _curDisplayedMajorArea = _majorArea;
    _bluetoothManager = [YTBluetoothManager shareBluetoothManager];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(bluetoothStateChange:) name:YTBluetoothStateHasChangedNotification object:nil];

    UIImageView *background = [[UIImageView alloc]initWithFrame:self.view.bounds];
    background.image = [UIImage imageNamed:@"nav_bg_pic.jpg"];
    [self.view addSubview:background];
    
    
    [self createNavigationBar];
    [self createMapView];
    [self createSearchView];
    [self createBlockAndFloorSwitch];
    [self createCurLocationButton];
    [self createCommonPoiButton];
    [self createZoomStepper];
    [self createDetailsView];
    [self createNavigationView];
    [self createPoiView];
    
    _beaconManager = [YTBeaconManager sharedBeaconManager];
    _beaconManager.delegate = self;
    
    if (_type == YTMapViewControllerTypeNavigation) {
        [self userMoveToMinorArea:_minorArea];
        [_beaconManager startRangingBeacons];
        return;
    }
    [_beaconManager startRangingBeacons];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_beaconManager.delegate == nil) {
        _beaconManager.delegate = self;
    }
    
    if (_type == YTMapViewControllerTypeMerchant) {
        [_mapView setCenterCoordinate:[_merchantLocation coordinate] animated:NO];
        _selectedPoi = [_merchantLocation producePoi];
        [_mapView highlightPoi:_selectedPoi animated:YES];
        [_detailsView setMerchantInfo:_merchantLocation];
        [self showCallOut];
    }
    [_bluetoothManager refreshBluetoothState];
}

-(void)createMapView{
    _mapView = [[YTMapView2 alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_navigationBar.frame), CGRectGetWidth(_navigationBar.frame) - 20, CGRectGetHeight(self.view.frame) - CGRectGetHeight(_navigationBar.frame) - 10)];
    _mapView.delegate = self;
    
    [self.view addSubview:_mapView];
    
    [_mapView displayMapNamed:[_majorArea mapName]];
    [self injectPoisForMajorArea:_majorArea];
}
    


-(void)injectPoisForMajorArea:(id<YTMajorArea>)majorArea{
    
    
    
    if([[[_userMinorArea majorArea] identifier] isEqualToString:[_curDisplayedMajorArea identifier]]){
        [_mapView showUserLocationAtCoordinate:[_userMinorArea coordinate]];
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
    
    if(_activePois != nil && _activePois.count > 0){
        [_mapView addPois:_activePois];
        [_mapView highlightPois:_activePois animated:NO];
    }
    
}
    
    
    
-(void)createNavigationBar{
    _navigationBar = [[YTNavigationBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
    _navigationBar.delegate = self;
    NSString *title = nil;
    switch (_type) {
        case YTMapViewControllerTypeFloor:
            title = [[[[_majorArea floor] block] mall] mallName];
            break;
        case YTMapViewControllerTypeMerchant:
            title = @"店铺详情";
            break;
        case YTMapViewControllerTypeNavigation:
            title = @"导航";
            break;
    }
    _navigationBar.backTitle = title;
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
    [self.view addSubview:_detailsView];
}

-(void)createBlockAndFloorSwitch{
    _switchBlockView = [[YTSwitchBlockView alloc]initWithPosition:CGPointMake(CGRectGetMaxX(_mapView.frame) - 52, CGRectGetMinY(_mapView.frame) + 14) currentMajorArea:_majorArea];
    _switchBlockView.delegate = self;
    [self.view addSubview:_switchBlockView];
    
    _switchFloorView = [[YTSwitchFloorView alloc]initWithPosition:CGPointMake(CGRectGetMaxX(_mapView.frame) - 50, CGRectGetMinY(_mapView.frame) + 10) AndCurrentMajorArea:_majorArea];
    _switchFloorView.delegate = self;
    [self.view addSubview:_switchFloorView];
}


-(void)createNavigationView{
    _navigationView = [[YTNavigationView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 70 , CGRectGetWidth(self.view.frame) - 20, 60)];
    _navigationView.isShowSwitchButton = NO;
    _navigationView.delegate = self;
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
-(void)mapView:(YTMapView2 *)mapView tapOnPoi:(YTPoi *)poi{
    id<YTPoiSource> sourceModel = [poi sourceModel];
    if([mapView currentState] == YTMapViewDetailStateNormal){
        _selectedPoi = poi;
        if([sourceModel isMemberOfClass:[YTLocalMerchantInstance class]]){
            [mapView highlightPoi:_selectedPoi animated:YES];
            [_detailsView setMerchantInfo:sourceModel];
            [self showCallOut];
        }
        else if([sourceModel isMemberOfClass:[YTLocalBathroom class]]){
            [_detailsView setCommonPoi:sourceModel];
            [self showCallOut];
        }
    }
    else if([mapView currentState] == YTMapViewDetailStateNavigating){
        
    }
    else if([mapView currentState] == YTMapViewDetailStateShowDetail){
        if (![poi.poiKey isEqualToString:_selectedPoi.poiKey]) {
            [mapView hidePoi:_selectedPoi animated:YES];
            _selectedPoi = poi;
            [mapView highlightPoi:_selectedPoi animated:YES];
            [_detailsView setMerchantInfo:sourceModel];
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
        
        frame = _detailsView.frame;
        frame.origin.y -= HOISTING_HEIGHT;
        _detailsView.frame = frame;
        
    } completion:^(BOOL finished) {
        
    }];
}
-(void)hideCallOut{
    
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
        
        frame = _detailsView.frame;
        frame.origin.y += HOISTING_HEIGHT;
        _detailsView.frame = frame;
        
    } completion:^(BOOL finished) {
        _poiButton.hidden = NO;
        _moveTargetButton.hidden = YES;
        _selectedPoi = nil;
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
    
}



#pragma mark beacons delegate methods
-(void)noBeaconsFound{
    
}
-(void)primaryBeaconShiftedTo:(ESTBeacon *)beacon{
    _majorArea = [self getMajorArea:beacon];
    if (_majorArea != nil) {
        NSArray *minorAreas = [_majorArea minorAreas];
        for(id<YTMinorArea> minorArea in minorAreas){
            NSArray *beacons = [minorArea beacons];
            for(id<YTBeacon> tempBeacon in beacons){
                if([[tempBeacon major] integerValue] == [[beacon major] integerValue] && [[tempBeacon minor] integerValue] == [[beacon minor] integerValue])
                {
                    [self userMoveToMinorArea:minorArea];
                }
            }
        }
    }
}


-(void)userMoveToMinorArea:(id<YTMinorArea>)minorArea{
    
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
        
    }else{
        
        [_mapView showUserLocationAtCoordinate:[minorArea coordinate]];
        
        _switchingFloor = NO;
    }
    
    _userCord = [minorArea coordinate];
    _userMinorArea = minorArea;
    [self updateNavManagerIfNeeded];
    
}


-(id<YTMajorArea>)getMajorArea:(ESTBeacon *)beacon{
    
    FMDatabase *db = [YTDBManager sharedManager];
    [db open];
    FMResultSet *result = [db executeQuery:@"select * from Beacon where major = ? and minor = ?",[beacon.major stringValue],[beacon.minor stringValue]];
    [result next];
    YTLocalBeacon *localBeacon = [[YTLocalBeacon alloc] initWithDBResultSet:result];
    
    YTLocalMajorArea * majorArea = [[localBeacon minorArea] majorArea];
    return majorArea;
}


#pragma mark switch floor and block delegate methods
-(void)switchBlock:(id<YTBlock>)block{
    id<YTMajorArea> majorArea = [[[[block floors] firstObject] majorAreas] firstObject];
    if (![[block blockName] isEqualToString:[[[_curDisplayedMajorArea floor]block] blockName]]) {
        
        [_mapView displayMapNamed:[majorArea mapName]];
        _curDisplayedMajorArea = majorArea;
    }
    
    [self handlePoiForMajorArea:majorArea];
    
}
-(void)switchFloor:(id<YTFloor>)floor{
    [self cancelCommonPoiState];
    id<YTMajorArea> majorArea = [[floor majorAreas] firstObject];
    if (![[floor floorName] isEqualToString:[[_curDisplayedMajorArea floor]floorName]]) {
        [_switchFloorView promptFloorChange:floor];
        [_mapView displayMapNamed:[majorArea mapName]];
        _curDisplayedMajorArea = majorArea;
    }
    [self handlePoiForMajorArea:majorArea];
    
    
}


-(void)handlePoiForMajorArea:(id<YTMajorArea>)majorArea{
    [_mapView removeAnnotations];
    [_mapView removeUserLocation];
    [self injectPoisForMajorArea:majorArea];
}



#pragma mark moveToTarget/self

-(void)moveToTargetLocationButtonClicked{
    id<YTMerchantLocation>tmpMerchantLocation = [_selectedPoi sourceModel];
    id<YTFloor> floor = [tmpMerchantLocation floor];
    if (![[[_curDisplayedMajorArea floor] floorName] isEqualToString:[ floor floorName]]) {
        [self switchFloor:floor];
        [_mapView setCenterCoordinate:[tmpMerchantLocation coordinate] animated:YES];
        
    }else{
        [_mapView setCenterCoordinate:[tmpMerchantLocation coordinate] animated:YES];
    }
}

-(void)moveToUserLocationButtonClicked{
    //if user is not present
    if(_userMinorArea == nil){
        [[[YTMessageBox alloc]initWithTitle:@"瞎逛提示" Message:[self messageFromButtonType:YTMessageTypeFromCurrentButton] cancelButtonTitle:@"知道了"]show];
        return;
    }
    
    //if same floor
    if([[[_curDisplayedMajorArea floor] identifier] isEqualToString:[[[_userMinorArea majorArea] floor] identifier]]){
        [_mapView setCenterCoordinate:[_userMinorArea coordinate] animated:YES];
        
    }
    //different floor
    else{
        [self switchFloor:[[_userMinorArea majorArea] floor]];
        [_mapView showUserLocationAtCoordinate:[_userMinorArea coordinate]];
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
-(void)startNavigatingToMerchantLocation:(id<YTMerchantLocation>)merchantLocation{
    NSString *message = nil;
    if (!_bluetoothOn) {
        message = @"蓝牙尚未打开";
        [[[YTMessageBox alloc]initWithTitle:@"瞎逛提示" Message:message cancelButtonTitle:@"知道了"]show];
        return;
    }
    if(_userMinorArea == nil){
        
        [[[YTMessageBox alloc]initWithTitle:@"瞎逛提示" Message:[self messageFromButtonType:YTMessageTypeFromNavigationButton] cancelButtonTitle:@"知道了"]show];
        return;
    }
    
    
    [_navigationView startNavigationAndSetTargetMerchant:merchantLocation];
    
    _navigationPlan = [[YTNavigationModePlan alloc] initWithTargetMerchantLocation:merchantLocation];
    _navigationView.plan = _navigationPlan;
    
    if (![[[_userMinorArea majorArea] identifier]isEqualToString:[_curDisplayedMajorArea identifier]]) {
        [_mapView displayMapNamed:[[_userMinorArea majorArea] mapName]];
        [_switchFloorView promptFloorChange:[[_userMinorArea majorArea] floor]];
        _curDisplayedMajorArea = [_userMinorArea majorArea];
        [self handlePoiForMajorArea:[_userMinorArea majorArea]];
    }
    
    
    
    
    if([[[merchantLocation floor] floorName] isEqualToString:[[[_userMinorArea majorArea] floor] floorName]]){
        [_mapView zoomToShowPoint1:[merchantLocation coordinate]  point2:[_userMinorArea coordinate]];
        YTPoi *poi = [merchantLocation producePoi];
        [_mapView superHighlightPoi:poi];
        //[_mapView setCenterCoordinate:CLLocationCoordinate2DMake(0, 0) animated:YES];
        //[_mapView setZoom:0.7 animated:NO];
        _targetCord = [merchantLocation coordinate];
        
    }
    else{
        
        id<YTElevator> userMajorAreaElevator = [[[_userMinorArea majorArea] elevators] objectAtIndex:0];
        [_mapView zoomToShowPoint1:[userMajorAreaElevator coordinate]  point2:[_userMinorArea coordinate]];
        _targetCord =[userMajorAreaElevator coordinate];
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
        
    } completion:^(BOOL finished) {
        _detailsView.frame = CGRectMake(CGRectGetMinX(_mapView.frame), CGRectGetHeight(self.view.frame), CGRectGetWidth(_mapView.frame), 60);
        _navigationView.frame = CGRectMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 70 , CGRectGetWidth(self.view.frame) - 20, 60);
        _selectedPoi = nil;
        _poiButton.hidden = NO;
        _moveTargetButton.hidden = YES;
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
        if(_activePois != nil && _activePois.count > 0){
            [_mapView addPois:_activePois];
            [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(0, 0) animated:YES];
            [_mapView setZoom:1 animated:NO];
            [_mapView highlightPois:_activePois animated:YES];
            [_selectedPoiButton setPoiImage:commonlyUsed.icon];
            
        }
        else{
            [[[UIAlertView alloc]initWithTitle:@"骚瑞" message:@"本楼层没有你想选的目标" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil]show];
        }
        
    }
}


-(NSArray *)getPoisForGroupName:(NSString *)groupName{
    NSArray *models;
    if([groupName isEqualToString:@"洗手间"]){
        models = [_curDisplayedMajorArea bathrooms];
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
    [self cancelCommonPoiState];
}

-(void)cancelCommonPoiState{
    _activePois = nil;
    [_poiView deleteSelectedPoi];
    [_mapView removePois:_activePois];
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
    NSDictionary *userInfo = notification.userInfo;
    _bluetoothOn = [userInfo[@"isOpen"] boolValue];
    if (_bluetoothOn) {
        
    }else{
        if (!_isFirstBluetoothPrompt) {
            [[[YTMessageBox alloc]initWithTitle:@"瞎逛提示" Message:@"蓝牙已关闭" cancelButtonTitle:@"知道了"]show];
        }else{
            _isFirstBluetoothPrompt = NO;
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

@end
