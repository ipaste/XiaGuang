//
//  RMMarker+RMMarker_YTExtension.h
//  BeaconTest
//
//  Created by Ke ZhuoPeng on 14-7-28.
//  Copyright (c) 2014年 YunTOP. All rights reserved.
//

#import "RMMarker.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
typedef void (^YTCompletion)(void);
@interface RMMarker (RMMarker_YTExtension)
- (void)didAppear;
- (void)disappear;
- (id)initWithUserLocation;
- (void)userLocationDirection:(CATransform3D)transform3D;
- (id)initWithMerchantImage:(UIImage *)image;
-(id)initWithElevator;

- (id)initWithBeacon;
- (void)showMerchantAnimation:(BOOL)animation;
- (void)hideMerchantAnimation:(BOOL)animation;


- (void)showBubble:(BOOL)animation;
- (void)hideBubble:(BOOL)animation;

- (void)showElevatorAnimation;
-(void)hideElevatorAnimation;
-(id)initWithMerchant:(NSString *)merchantName;
-(id)initWithBubbleHeight:(float)height width:(float)width;
-(void)setMerchantIcon:(UIImage *)image;

-(void)superHightlightMerchantLayer;
-(void)cancelSuperHighlight;

-(instancetype)initWithParkingLayer;
-(void)startRespirationLampAnimation;
-(void)stopRespirationLampAnimation;
@end
