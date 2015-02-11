//
//  YTBlurMallView.m
//  虾逛
//
//  Created by YunTop on 14/12/24.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTBlurMallView.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"

@implementation YTBlurMallView{

}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.tintColor = [UIColor blackColor];
        self.barStyle = UIBarStyleBlack;
        self.translucent = YES;
//        _backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 0, _defaultBackImage.size.width, _defaultBackImage.size.height)];
//        _defaultBackImage = [UIImage imageNamed:@"nav_ico_back_un"];
//        _backImageView.image = _defaultBackImage;
//        
//        
//        _backButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 20, 100, 40)];
//        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
//        [_backButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
//        [_backButton setTitleColor:[UIColor colorWithString:@"808080"] forState:UIControlStateHighlighted];
//        [_backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, CGRectGetWidth(_backImageView.frame) + 5, 0, 0)];
//        [_backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//        
//        
//        [_backButton addSubview:_backImageView];
//        [self addSubview:_backButton];
        
        
    }
    return self;
}

-(void)layoutSubviews{
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}
@end
