//
//  YTStopCarController.h
//  xiaGuang
//
//  Created by YunTop on 14/10/30.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMapView2.h"
#import "YTZoomStepper.h"
#import "YTNavigationBar.h"
#import "YTBluetoothManager.h"
#import "YTLocalBeacon.h"
#import "YTMinorArea.h"
#import "YTParkingPoi.h"
#import "YTMessageBox.h"
#import "YTParkingMarkPoi.h"
#import "YTCurrentParkingButton.h"
#import "YTUserDefaults.h"
#import "YTBeaconManager.h"
#import "YTMoveCurrentLocationButton.h"
@interface YTParkingViewController : UIViewController<YTNavigationBarDelegate,YTMapViewDelegate,YTZoomStepperDelegate,YTCurrentParkingDelegate,YTMoveCurrentLocationDelegate,YTBeaconManagerDelegate,YTMessageBoxDelegate>
-(instancetype)initWithMinorArea:(id<YTMinorArea>)minorArea;
@end
