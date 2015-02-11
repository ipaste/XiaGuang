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
#import "YTPreferentialCell.h"
@interface YTMerchantInfoViewController ()<UITableViewDataSource,UITableViewDelegate>{
    id<YTMerchant> _merchant;
    UIImageView *_merchantLogo;
    UILabel *_merchantName;
    UIButton *_category;
    UIButton *_subCategory;
    UILabel *_addressLabel;
    UIButton *_jumpToMapButton;
    UIView *_merchantInfoView;
    UILabel *_promptLabel;
    UITableView *_discountTableView;
    UIView *_discountHeadView;
    NSArray *_preferentials;
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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButton]];

    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;

    self.navigationItem.title = @"店铺详情";
    UIImage *merchantInfoImage = [UIImage imageNamed:@"shop_img_inforbg"];
    _merchantInfoView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(self.view.frame) + CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), 175 - merchantInfoImage.size.height )];
    _merchantInfoView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_img_inforbg2"]];
    [self.view addSubview:_merchantInfoView];
    
    
    _merchantLogo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, 60, 60)];
    [_merchantInfoView addSubview:_merchantLogo];
    
    _merchantName = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_merchantLogo.frame) + 10, CGRectGetWidth(self.view.frame), 17)];
    [_merchantInfoView addSubview:_merchantName];
    
    _category = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_merchantName.frame) + 10, 42, 16)];
    [_merchantInfoView addSubview:_category];
    
    
    _subCategory = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(_category.frame), CGRectGetWidth(_category.frame),     CGRectGetHeight(_category.frame))];
    [_merchantInfoView addSubview:_subCategory];

    
    CGSize textSize = [[_merchant address] boundingRectWithSize:CGSizeMake(200, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    _addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, textSize.width,textSize.height)];
    
    _jumpToMapButton  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 36, 40)];
    [_jumpToMapButton addTarget:self action:@selector(jumpToMap:) forControlEvents:UIControlEventTouchUpInside];
    [_jumpToMapButton setImage:[UIImage imageNamed:@"shop_icon_nav"] forState:UIControlStateNormal];
    
    [_merchantInfoView addSubview:_jumpToMapButton];
    
    [_merchantInfoView addSubview:_addressLabel];
    
    
    //优惠专区
    [_merchant existenceOfPreferentialInformationQueryMall:^(BOOL isExistence) {
        if (isExistence){
            _discountHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 30)];
            _discountHeadView.backgroundColor = _merchantInfoView.backgroundColor;
            UIImage *image = [UIImage imageNamed:@"title_disco_inner"];
            UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
            imageView.frame = CGRectMake(15, 6, image.size.width, image.size.height);
            [_discountHeadView addSubview:imageView];
            [self.view addSubview:_discountHeadView];
            
            _discountTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 20)];
            _discountTableView.rowHeight = 95;
            _discountTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_img_inforbg2"]];
            _discountTableView.delegate = self;
            _discountTableView.dataSource = self;
            [self.view addSubview:_discountTableView];
            
            [((YTCloudMerchant *)_merchant) merchantWithPreferentials:^(NSArray *preferentials, NSError *error) {
                _preferentials = preferentials;
                [_discountTableView reloadData];
            }];
            
        }else{
            UIImageView *background = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"shop_bg_map"]];
            background.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame));
            [self.view insertSubview:background atIndex:0];
            
            _promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(_merchantInfoView.frame), CGRectGetWidth(self.view.frame), 20)];
            _promptLabel.text = @"亲,暂时没有优惠信息";
            _promptLabel.textAlignment = 1;
            _promptLabel.font = [UIFont systemFontOfSize:18];
            _promptLabel.textColor = [UIColor whiteColor];
            [self.view addSubview:_promptLabel];
        }
    }];
    
    
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
    
    
    _addressLabel.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2,CGRectGetMaxY(_category.frame) + CGRectGetHeight(_addressLabel.frame));
    _addressLabel.font = [UIFont systemFontOfSize:12];
    _addressLabel.textAlignment = 1;
    _addressLabel.textColor = [UIColor colorWithString:@"999999"];;
    _addressLabel.text = [_merchant address];
    _addressLabel.numberOfLines = 2;
    _addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    
    _jumpToMapButton.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2, CGRectGetMaxY(_addressLabel.frame) + 15 + CGRectGetHeight(_jumpToMapButton.frame) / 2);
    [_jumpToMapButton setBackgroundImage:[UIImage imageNamed:@"shop_btn_nav"] forState:UIControlStateNormal];
    [_jumpToMapButton setTitle:@"查看商家位置" forState:UIControlStateNormal];
    [_jumpToMapButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_jumpToMapButton setBackgroundImage:[UIImage imageNamed:@"shop_btn_navOn"] forState:UIControlStateHighlighted];
    [_jumpToMapButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [_jumpToMapButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    
    
    CGRect frame = _merchantInfoView.frame;
    frame.size.height = CGRectGetMaxY(_jumpToMapButton.frame) + 19;
    _merchantInfoView.frame = frame;
 
    
    CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds);
    if (height < 568) {
        height = 90;
    }else{
        height = 108;
    }
    
    frame = _promptLabel.frame;
    frame.origin.y = height + CGRectGetMaxY(_merchantInfoView.frame);
    _promptLabel.frame = frame;
    
    frame = _discountHeadView.frame;
    frame.origin.y = CGRectGetMaxY(_merchantInfoView.frame) + 10;
    _discountHeadView.frame = frame;
    
    frame = _discountTableView.frame;
    frame.origin.y = CGRectGetMaxY(_discountHeadView.frame);
    frame.size.height = CGRectGetHeight(self.view.frame) - frame.origin.y;
    _discountTableView.frame = frame;
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _preferentials.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YTPreferentialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[YTPreferentialCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.preferential = _preferentials[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:false];
}

-(UIView *)leftBarButton{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 35, 20, 20, 20)];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icon_backOn"] forState:UIControlStateHighlighted];
    return button;
}

-(void)back:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:true];
}


-(void)dealloc{
    NSLog(@"商铺主页销毁");
}




@end
