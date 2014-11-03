//
//  YTParking.h
//  xiaGuang
//
//  Created by YunTop on 14/11/3.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//


#import "YTPoiSource.h"

@protocol YTParkingMarked <YTPoiSource>
@property (nonatomic,weak) NSString *name;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,weak) id<YTMajorArea> majorArea;
@property (nonatomic,weak) id<YTMinorArea> inMinorArea;

-(BOOL)whetherMark;
-(void)saveParkingInfoWithMinorArea:(id<YTMinorArea>)minorArea;
-(void)clearParkingInfo;
@end
