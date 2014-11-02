//
//  YTEndNavigatingView.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-10.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YTMessageBox;
@protocol YTMessageBoxDelegate <NSObject>
@optional
-(void)clickToButtonAtTag:(NSInteger)tag;

@end
@interface YTMessageBox : UIView
@property(weak,nonatomic)id<YTMessageBoxDelegate> delegate;
-(id)initWithTitle:(NSString *)title Message:(NSString *)message;
-(id)initWithTitle:(NSString *)title Message:(NSString *)message cancelButtonTitle:(NSString *)buttonTitle;
-(void)show;
-(void)callBack:(void(^)(NSInteger tag))callBack;
@end
