//
//  ViewController.h
//  xiaGuang
//
//  Created by YunTop on 14-10-24.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTSettingViewController.h"
#import "YTSearchViewController.h"
#import "YTDataManager.h"
#import "YTMallInfoViewController.h"
#import "YTMapViewController2.h"
#import "YTMallCell.h"
#import "YTParkingViewController.h"
#import "YTBluetoothManager.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "BBTableView.h"
#import "YTMallDict.h"
#import "AppDelegate.h"
@interface YTHomeViewController : UIViewController<YTBeaconManagerDelegate,YTDataManagerDelegate,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>

@end

