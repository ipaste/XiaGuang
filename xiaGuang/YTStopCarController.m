//
//  YTStopCarController.m
//  xiaGuang
//
//  Created by YunTop on 14/10/30.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTStopCarController.h"

@implementation YTStopCarController{
    YTMapView2 *_mapView;
    YTNavigationBar *_navigationBar;
    YTZoomStepper *_zoomStepper;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        backgroundView.image = [UIImage imageNamed:@"nav_bg_pic.jpg"];
        [self.view addSubview:backgroundView];
        
        [self createNavigationBar];
        [self createMapView];
        [self createZoomStepper];
        
    }
    return self;
}

-(void)createNavigationBar{
    _navigationBar = [[YTNavigationBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
    _navigationBar.backTitle = @"首页";
    _navigationBar.delegate = self;
    [_navigationBar changeSearchButton];
    [self.view addSubview:_navigationBar];
}
#pragma mark mapView
-(void)createMapView{
    _mapView = [[YTMapView2 alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_navigationBar.frame), CGRectGetWidth(self.view.bounds) - 20, CGRectGetHeight(self.view.frame) - CGRectGetHeight(_navigationBar.frame) - 70)];
    _mapView.delegate = self;
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

-(void)backButtonClicked{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
