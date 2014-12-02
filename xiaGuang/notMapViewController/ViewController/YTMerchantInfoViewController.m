//
//  YTMerchantInfoViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-19.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTMerchantInfoViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "YTCloudMerchant.h"
#import "YTLocalMerchantInstance.h"
#import "YTMapViewController2.h"
@interface YTMerchantInfoViewController (){
    id<YTMerchant> _merchant;
    UIImageView *_merchantLogo;
    UILabel *_merchantName;
    UIButton *_category;
    UIButton *_subCategory;
    UILabel *_addressLabel;
    UIImageView *_addressLogo;
    UIView *_naviView;
    UIButton *_jumpToMapButton;
    UIImageView *_merchantInfoImageView;
    UIView *_merchantInfoView;
}
@end

@implementation YTMerchantInfoViewController

-(id)initWithMerchant:(id <YTMerchant>)merchant{
    if (self = [super init]) {
        _merchant = merchant;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"all_bg_navbar-1"] forBarMetrics:UIBarMetricsDefault];
    UIImageView *background = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"shop_bg_map"]];
    
    
    [self.view addSubview:background];
    
    self.navigationItem.title = @"店铺详情";
    UIImage *merchantInfoImage = [UIImage imageNamed:@"shop_img_inforbg"];
    _merchantInfoView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(self.view.frame), CGRectGetWidth(self.view.frame), 175 - merchantInfoImage.size.height )];
    _merchantInfoView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_img_inforbg2"]];
    [self.view addSubview:_merchantInfoView];
    
    _merchantInfoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_merchantInfoView.frame), CGRectGetMaxY(_merchantInfoView.frame), merchantInfoImage.size.width, merchantInfoImage.size.height)];
    _merchantInfoImageView.image = merchantInfoImage;
    [self.view addSubview:_merchantInfoImageView];
    
    _merchantLogo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, 60, 60)];
    [_merchantInfoView addSubview:_merchantLogo];
    
    _merchantName = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_merchantLogo.frame) + 10, CGRectGetWidth(self.view.frame), 17)];
    [_merchantInfoView addSubview:_merchantName];
    
    _category = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_merchantName.frame) + 10, 42, 16)];
    [_merchantInfoView addSubview:_category];
    
    
    _subCategory = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(_category.frame), CGRectGetWidth(_category.frame),     CGRectGetHeight(_category.frame))];
    [_merchantInfoView addSubview:_subCategory];
    
    CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds);
    if (height < 568) {
        height = 50;
    }else{
        height = 80;
    }
    
    _naviView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_merchantInfoImageView.frame) + height, CGRectGetWidth(self.view.frame), 92)];
    [self.view addSubview:_naviView];
    
    CGSize textSize = [[_merchant address] boundingRectWithSize:CGSizeMake(200, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    _addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, textSize.width,textSize.height)];

    
    _addressLogo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
    [self.view addSubview:_addressLogo];
    
    
    _jumpToMapButton  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 180, 45)];
    [_jumpToMapButton addTarget:self action:@selector(jumpToMap:) forControlEvents:UIControlEventTouchUpInside];
    [_naviView addSubview:_jumpToMapButton];
    
    [_naviView addSubview:_addressLabel];
    

}

-(void)jumpToMap:(id)button{
    YTLocalMerchantInstance *targetMerchantInstance = [(YTCloudMerchant *)_merchant getLocalMerchantInstance];
    if(targetMerchantInstance == nil){
        [[[UIAlertView alloc]initWithTitle:@"对不起" message:@"当前商铺没有进入数据库" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil] show];
        return;
    }
    YTMapViewController2 *mapVC = [[YTMapViewController2 alloc] initWithMerchant:targetMerchantInstance];
    //mapVC.fromMerchant = YES;
    mapVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:mapVC animated:YES completion:nil];

}

-(void)viewDidLayoutSubviews{
    CGFloat topHeight = [self.topLayoutGuide length];
    CGRect frame = _merchantInfoView.frame;
    frame.origin.y += topHeight;
    _merchantInfoView.frame = frame;
    
    frame = _merchantInfoImageView.frame;
    frame.origin.y += topHeight;
    _merchantInfoImageView.frame = frame;
    
    frame = _naviView.frame;
    frame.origin.y += topHeight;
    _naviView.frame = frame;
    
    
    _merchantLogo.center = CGPointMake(self.view.center.x, _merchantLogo.center.y);
    _merchantLogo.layer.cornerRadius = CGRectGetWidth(_merchantLogo.frame) / 2;
    _merchantLogo.layer.borderWidth = 0.5;
    _merchantLogo.layer.borderColor = [UIColor colorWithString:@"c8c8c8"].CGColor;
    _merchantLogo.layer.masksToBounds = YES;
    [_merchant getThumbNailWithCallBack:^(UIImage *result, NSError *error) {
        if (result) {
            _merchantLogo.image = result;
        }
    }];
    
    _merchantName.center = CGPointMake(self.view.center.x, _merchantName.center.y);
    _merchantName.textColor = [UIColor colorWithString:@"404040"];
    _merchantName.textAlignment = 1;
    _merchantName.text = [_merchant merchantName];
    
    _category.center = CGPointMake(self.view.center.x - CGRectGetWidth(_category.frame) / 2 - 5, _category.center.y);
    
    [_category setBackgroundImage:[UIImage imageNamed:@"shop_img_label_2"] forState:UIControlStateNormal];
    [_category setTitle:[[_merchant type] firstObject] forState:UIControlStateNormal];
    [_category setTitleColor:[UIColor colorWithString:@"e95e37"] forState:UIControlStateNormal];
    [_category.titleLabel setFont:[UIFont systemFontOfSize:10]];
    _category.userInteractionEnabled = NO;
    
    
    _subCategory.center = CGPointMake(self.view.center.x + CGRectGetWidth(_subCategory.frame) / 2 + 5, _subCategory.center.y);
    [_subCategory setBackgroundImage:[UIImage imageNamed:@"shop_img_label_2"] forState:UIControlStateNormal];
    [_subCategory setTitle:[[_merchant type] lastObject] forState:UIControlStateNormal];
    [_subCategory setTitleColor:[UIColor colorWithString:@"e95e37"] forState:UIControlStateNormal];
    [_subCategory.titleLabel setFont:[UIFont systemFontOfSize:10]];
    _subCategory.userInteractionEnabled = NO;
    
    
    _addressLabel.center = CGPointMake(_naviView.center.x,0);
    _addressLabel.font = [UIFont systemFontOfSize:14];
    _addressLabel.textAlignment = 1;
    _addressLabel.textColor = [UIColor colorWithString:@"404040"];;
    _addressLabel.text = [_merchant address];
    _addressLabel.numberOfLines = 2;
    _addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _addressLogo.center = CGPointMake(self.view.center.x, CGRectGetMaxY(_merchantInfoImageView.frame) + 36);
    _addressLogo.image = [UIImage imageNamed:@"nav_ico_end_pr"];
    
    
    _jumpToMapButton.center = CGPointMake(_naviView.center.x, CGRectGetMaxY(_addressLabel.frame) + 15 + CGRectGetHeight(_jumpToMapButton.frame) / 2);
    [_jumpToMapButton setBackgroundImage:[UIImage imageNamed:@"shop_btn_nav_un"] forState:UIControlStateNormal];
    [_jumpToMapButton setTitle:@"查看商家位置" forState:UIControlStateNormal];
    [_jumpToMapButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_jumpToMapButton setBackgroundImage:[UIImage imageNamed:@"shop_btn_nav_pr"] forState:UIControlStateHighlighted];
    
    _naviView.center = CGPointMake(self.view.center.x, CGRectGetMaxY(_addressLogo.frame) + CGRectGetHeight(_naviView.frame) / 2 + 20);
}

-(void)dealloc{
    NSLog(@"商铺主页销毁");
}




@end
