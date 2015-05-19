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
    UIImageView *_promptBackground;
    UITableView *_discountTableView;
    UIView *_discountHeadView;
    UITableView *_otherDiscountTableView;
    UIView *_otherDiscountHeadView;
    NSArray *_preferentials;
    NSArray *_otherPreferentials;
    UIScrollView *_scrollView;
    YTStateView *_stateView;
    NSTimeInterval _loadingTime;
    BOOL _isOtherLoadingDone;
    BOOL _isSaleLoadingDone;
}
@end

@implementation YTMerchantInfoViewController

-(id)initWithMerchant:(id <YTMerchant>)merchant{
    if (self = [super init]) {
        _merchant = merchant;
        _isOtherLoadingDone = false;
        _isSaleLoadingDone = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButton]];

    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
    
    self.automaticallyAdjustsScrollViewInsets = false;

    self.navigationItem.title = @"店铺详情";
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
    [self.view addSubview:_scrollView];
    
    
    UIImage *merchantInfoImage = [UIImage imageNamed:@"shop_img_inforbg"];
    _merchantInfoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 175 - merchantInfoImage.size.height )];
    _merchantInfoView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_img_inforbg2"]];
    [_scrollView addSubview:_merchantInfoView];
    
    
    _merchantLogo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, 60, 60)];
    [_merchantInfoView addSubview:_merchantLogo];
    
    _merchantName = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_merchantLogo.frame) + 10, CGRectGetWidth(self.view.frame), 17)];
    [_merchantInfoView addSubview:_merchantName];
    
    CGSize textSize = [[_merchant address] boundingRectWithSize:CGSizeMake(200, CGRectGetWidth(self.view.frame)) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size;
    _addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame),textSize.height)];
    
    _jumpToMapButton  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 36, 40)];
    [_jumpToMapButton addTarget:self action:@selector(jumpToMap:) forControlEvents:UIControlEventTouchUpInside];
    [_jumpToMapButton setImage:[UIImage imageNamed:@"shop_icon_nav"] forState:UIControlStateNormal];
    
    [_merchantInfoView addSubview:_jumpToMapButton];
    
    [_merchantInfoView addSubview:_addressLabel];
    
    //sole
    _discountHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 30)];
    _discountHeadView.backgroundColor = _merchantInfoView.backgroundColor;
    _discountHeadView.hidden = true;
    UIImage *image = [UIImage imageNamed:@"title_du"];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    imageView.frame = CGRectMake(15, 6, image.size.width, image.size.height);
    [_discountHeadView addSubview:imageView];
    [_scrollView insertSubview:_discountHeadView belowSubview:_merchantInfoView];
    
    _discountTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 20)];
    _discountTableView.rowHeight = 95;
    _discountTableView.scrollEnabled = false;
    _discountTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _discountTableView.hidden = true;
    _discountTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_img_inforbg2"]];
    _discountTableView.delegate = self;
    _discountTableView.dataSource = self;
    [_scrollView insertSubview:_discountTableView belowSubview:_merchantInfoView];
    
   // other
    _otherDiscountHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 30)];
    _otherDiscountHeadView.backgroundColor = _discountHeadView.backgroundColor;
    _otherDiscountHeadView.hidden = true;
    UIImage *otherImage = [UIImage imageNamed:@"title_tuan"];
    UIImageView *otherImageView = [[UIImageView alloc]initWithImage:otherImage];
    otherImageView.frame = CGRectMake(15, 6, otherImage.size.width, otherImage.size.height);
    [_otherDiscountHeadView addSubview:otherImageView];
    [_scrollView insertSubview:_otherDiscountHeadView belowSubview:_merchantInfoView];
    
    
    _otherDiscountTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 20)];
    _otherDiscountTableView.hidden = true;
    _otherDiscountTableView.scrollEnabled = false;
    _otherDiscountTableView.rowHeight = 95;
    _otherDiscountTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _otherDiscountTableView.backgroundColor = _discountTableView.backgroundColor;
    _otherDiscountTableView.delegate = self;
    _otherDiscountTableView.dataSource = self;
    [_scrollView insertSubview:_otherDiscountTableView belowSubview:_merchantInfoView];
    
    _promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(_merchantInfoView.frame), CGRectGetWidth(self.view.frame), 20)];
    _promptLabel.text = @"亲,暂时没有优惠信息";
    _promptLabel.textAlignment = 1;
    _promptLabel.hidden = true;
    _promptLabel.font = [UIFont systemFontOfSize:18];
    _promptLabel.textColor = [UIColor whiteColor];
    [_scrollView addSubview:_promptLabel];
    
    _promptBackground = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"shop_bg_map"]];
    _promptBackground.frame = CGRectMake(0,0, CGRectGetWidth(self.view.frame), CGRectGetHeight(_scrollView.frame));
    _promptBackground.hidden = true;
    [_scrollView insertSubview:_promptBackground atIndex:0];
    
    _stateView = [[YTStateView alloc]initWithStateType:YTStateTypeLoading];
    [_stateView startAnimation];
    [_scrollView insertSubview:_stateView belowSubview:_merchantInfoView];
    _loadingTime = [[NSDate date]timeIntervalSinceReferenceDate];
    
    //优惠专区
    [_merchant existenceOfPreferentialInformationQueryMall:^(BOOL isExistence) {
        if (isExistence){
            YTCloudMerchant *merchant = (YTCloudMerchant *)_merchant;
            if (!merchant.isOther) {
                _isOtherLoadingDone = true;
            }
            if (!merchant.isSole) {
                _isSaleLoadingDone = true;
            }
            
            [merchant  getSolePreferentials:^(NSArray *preferentials, NSError *error) {
                _preferentials = preferentials;
                CGRect frame = _discountTableView.frame;
                frame.size = CGSizeMake(CGRectGetWidth(_discountTableView.frame), 95 * _preferentials.count);
                _discountTableView.frame = frame;
                [_discountTableView reloadData];
                _isSaleLoadingDone = true;
                [self reloadUI];
            }];
            
            [merchant getOtherPreferentials:^(NSArray *preferentials, NSError *error) {
                _otherPreferentials = preferentials;
                CGRect frame = _otherDiscountTableView.frame;
                frame.size = CGSizeMake(CGRectGetWidth(_otherDiscountTableView.frame), 95 * _otherPreferentials.count);
                _otherDiscountTableView.frame = frame; 
                [_otherDiscountTableView reloadData];
                _isOtherLoadingDone = true;
                [self reloadUI];
            }];
        }else{
            _promptLabel.hidden = false;
            _promptBackground.hidden = false;
            _isOtherLoadingDone = true;
            _isSaleLoadingDone = true;
            [_stateView stopAnimation];
            [_stateView removeFromSuperview];
        }
    }];
}

-(void)jumpToMap:(id)button{
    YTLocalMerchantInstance *targetMerchantInstance = [(YTCloudMerchant *)_merchant getLocalMerchantInstance];
    if(targetMerchantInstance == nil){
        YTMessageBox *messageBox = [[YTMessageBox alloc]initWithTitle:@"" Message:@"该商城地图还未下载,需要跳转至地图管理页面下载吗"];
        [messageBox show];
        [messageBox callBack:^(NSInteger tag) {
            if (tag == 1){
                UIViewController *controller = [YTMallManageListViewController shareMallListController];
                [self.navigationController pushViewController:controller animated:true];
            }
        }];
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

    
    _addressLabel.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2,CGRectGetMaxY(_merchantName.frame) + CGRectGetHeight(_addressLabel.frame));
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
 
    
    frame = _stateView.frame;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(_merchantInfoView.frame) + 10;
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = CGRectGetHeight(self.view.frame) - CGRectGetMinY(frame);
    _stateView.frame = frame;
    
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
    _discountTableView.frame = frame;
    
    
    frame = _otherDiscountHeadView.frame;
    frame.origin.y = CGRectGetMaxY(_discountTableView.frame) + 10;
    _otherDiscountHeadView.frame = frame;
    
    frame = _otherDiscountTableView.frame;
    frame.origin.y = CGRectGetMaxY(_otherDiscountHeadView.frame);
    _otherDiscountTableView.frame = frame;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:_otherDiscountTableView]) {
        return _otherPreferentials.count;
    }
    return _preferentials.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YTPreferentialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[YTPreferentialCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
    }
    if ([tableView isEqual:_otherDiscountTableView]){
        cell.preferential = _otherPreferentials[indexPath.row];
        cell.style = YTPreferentialCellStyleOther;
       
        cell.selectionStyle = cell.preferential.url == nil ? UITableViewCellSelectionStyleNone:UITableViewCellSelectionStyleDefault;
    }else{
        cell.preferential = _preferentials[indexPath.row];
        cell.style = YTPreferentialCellStyleSole;
        cell.selectionStyle = cell.preferential.url == nil ? UITableViewCellSelectionStyleNone:UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    if ([tableView isEqual:_otherDiscountTableView]) {
        YTPreferential *preferential = _otherPreferentials[indexPath.row];
        if (preferential.url != nil) {
            YTH5ViewController *VC = [[YTH5ViewController alloc]initWithH5_url:preferential.url];
            [self.navigationController pushViewController:VC animated:true];
        }
    }
    
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

- (void)reloadUI{
    if (_isOtherLoadingDone && _isSaleLoadingDone) {
        dispatch_time_t time =  dispatch_time(DISPATCH_TIME_NOW, 0);
        if ([[NSDate date]timeIntervalSinceReferenceDate] - _loadingTime < 2) time = dispatch_time(DISPATCH_TIME_NOW,NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [_stateView stopAnimation];
            [_stateView removeFromSuperview];
        });
        
    }
    
    CGRect frame = _otherDiscountHeadView.frame;
    if (_preferentials.count <= 0 ) {
        _discountHeadView.hidden = true;
        _discountTableView.hidden = true;
        frame.origin.y = CGRectGetMinY(_discountHeadView.frame);
    }else{
        _discountHeadView.hidden = false;
        _discountTableView.hidden = false;
        frame.origin.y = CGRectGetMaxY(_discountTableView.frame) + 12;
    }
    _otherDiscountHeadView.frame = frame;
    
    frame = _otherDiscountTableView.frame;
    frame.origin.y = CGRectGetMaxY(_otherDiscountHeadView.frame);
    _otherDiscountTableView.frame = frame;
    
    
    if (_otherPreferentials.count <= 0) {
        _otherDiscountHeadView.hidden = true;
        _otherDiscountTableView.hidden = true;
        _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, CGRectGetMaxY(_discountTableView.frame));
    }else{
        _otherDiscountHeadView.hidden = false;
        _otherDiscountTableView.hidden = false;
        _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, CGRectGetMaxY(_otherDiscountTableView.frame));
    }
    
    if (_preferentials.count > 0 && CGRectGetMaxY(_discountTableView.frame) < CGRectGetHeight(self.view.frame) && _otherPreferentials.count <= 0) {
        CGRect frame = _discountTableView.frame;
        frame.size.height = CGRectGetHeight(_scrollView.frame) - CGRectGetMaxY(_merchantInfoView.frame) - 10;
        _discountTableView.frame = frame;
    }else if (_otherPreferentials.count > 0 && _preferentials.count <= 0 && CGRectGetMaxY(_otherDiscountTableView.frame) < CGRectGetHeight(self.view.frame)){
        CGRect frame = _otherDiscountTableView.frame;
        frame.size.height = CGRectGetHeight(_scrollView.frame) - CGRectGetMaxY(_merchantInfoView.frame);
        _otherDiscountTableView.frame = frame;
    }
   
}

-(void)dealloc{
    NSLog(@"商铺主页销毁");
}


@end
