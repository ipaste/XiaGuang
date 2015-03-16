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
#import "YTStaticResourceManager.h"
#import "YTMallInfoViewController.h"
#import "YTMapViewController2.h"
#import "Reachability.h"
#import "YTMallCell.h"
#import "YTParkingViewController.h"
#import "YTBluetoothManager.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "BBTableView.h"
#import "YTMallDict.h"
@interface YTHomeViewController : UIViewController<YTBeaconManagerDelegate,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>

@end

