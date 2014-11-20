//
//  YTMapViewController2.h
//  HighGuang
//
//  Created by Yuan Tao on 10/16/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMall.h"
#import "YTMinorArea.h"
#import "YTBeaconManager.h"
#import "YTBeacon.h"
#import <AVQuery.h>
#import "YTMapView2.h"
#import "YTCloudBeacon.h"
#import "YTDBManager.h"
#import "YTLocalBeacon.h"
#import "YTDBManager.h"
#import "YTNavigationBar.h"
#import "YTSearchView.h"
#import "YTMoveCurrentLocationButton.h"
#import "YTMoveTargetLocationButton.h"
#import "YTPoiButton.h"
#import "YTZoomStepper.h"
#import "YTSwitchFloorView.h"
#import "YTSwitchBlockView.h"
#import "YTNavigationModePlan.h"
#import "YTNavigationView.h"
#import "YTDetailsView.h"
#import "YTNavigationView.h"
#import "YTPoiView.h"
#import "YTSelectedPoiButton.h"
#import "YTBluetoothManager.h"
#import "YTMessageBox.h"
#import <POP.h>
#import "YTBathroom.h"
#import "YTMerchantPoi.h"
#import "BlurMenu.h"
#import "BlurMenuItemCell.h"
#import "YTBeaconBasedLocator.h"
#import "YTBeaconPosistionPoi.h"
#import "YTMajorAreaVoter.h"
@interface YTMapViewController2 : UIViewController<YTBeaconManagerDelegate,YTMapViewDelegate,YTNavigationBarDelegate,YTSearchViewDelegate,YTSwitchBlockDelegate,YTSwitchFloorDelegate,YTZoomStepperDelegate,YTMoveCurrentLocationDelegate,YTMoveTargetLocationDelegate,YTDetailsDelegate,YTNavigationDelegate,YTPoiDelegate,YTPoiViewDelegate,YTSelectedPoiDelegate,BlurMenuDelegate,YTBeaconBasedLocatorDelegate>

-(id)initWithMinorArea:(id <YTMinorArea>)minorArea;
-(id)initWithMerchant:(id<YTMerchantLocation>)merchantLocation;
-(id)initWithFloor:(id<YTFloor>)floor;

@end
