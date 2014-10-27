//
//  YTSelectedPoiButton.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-16.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YTSelectedPoiButton;
@protocol YTSelectedPoiDelegate <NSObject>
-(void)selectedPoiButtonClicked;
@end
@interface YTSelectedPoiButton : UIButton
@property (weak,nonatomic) id<YTSelectedPoiDelegate> delegate;
-(void)setPoiImage:(UIImage *)image;
@end
