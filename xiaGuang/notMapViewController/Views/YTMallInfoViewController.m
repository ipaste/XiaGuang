//
//  YTMerchantIndexViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-12.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTMallInfoViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "YTMoreCategoryViewController.h"
#import "YTMajorArea.h"
#import "YTCloudMerchant.h"
#import "YTCategory.h"
#import "YTSearchView.h"
#import "YTMerchantViewCell.h"
#import "YTMerchantInfoViewController.h"
#import "YTResultsViewController.h"
#import "YTMallDict.h"
#import "YTMapViewController2.h"
typedef void(^YTPreferentialsCallBack)(NSArray *preferentials);
@interface YTMallInfoViewController ()<UITableViewDataSource,UITableViewDelegate,YTSearchViewDelegate>{
    YTSearchView *_searchView;
    UIImageView *_searchBackgroundView;
    UIScrollView *_scrollView;
    NSArray *_categorys;
    UITableView *_tableView;
    NSArray *_hots;
    UIActivityIndicatorView *_loading;
    UILabel *_loadingLabel;
    UIImage *_infoBackgroundImage;
    UIButton *_leftButton;
    UIButton *_rightButton;
    UIView *_preferentialView;
    YTMallPosistionViewController *_posistionVC;
    YTPreferentialsCallBack _callBack;
    YTMallDict *_mallDict;
    BOOL _isShowSearchView;
    NSArray *_preferentials;
}
@end

@implementation YTMallInfoViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame) + 50, 320, CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame) - 50)];
    _scrollView.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
    _mallDict = [YTMallDict sharedInstance];
    _searchView = [[YTSearchView alloc]initWithMall:[_mallDict changeMallObject:self.mall resultType:YTMallClassLocal] placeholder:@"商城/品牌" indent:NO];
    _searchView.delegate = self;
    [_searchView addInNavigationBar:self.navigationController.navigationBar show:NO];
    
    [self.view addSubview:_scrollView];
    [self setNavigation];
    [self mainView];
    
    self.navigationItem.title = [_mall mallName];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.titleView.hidden = NO;
    self.navigationController.navigationBar.clipsToBounds = true;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithString:@"e65e37"] forKey:NSForegroundColorAttributeName]];
    [AVAnalytics beginLogPageView:@"mallInfoViewController"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [AVAnalytics endLogPageView:@"mallInfoViewController"];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_isShowSearchView) {
        [_searchView hideSearchViewWithAnimation:NO];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSURLCache sharedURLCache]removeAllCachedResponses];
    });
}
#pragma mark Navigation
-(void)setNavigation{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self rightBarButton]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButton]];
}

-(UIView *)rightBarButton{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 35, 20, 20, 20)];
    [button addTarget:self action:@selector(jumpToSearch:) forControlEvents:UIControlEventTouchUpInside];

    [button setImage:[UIImage imageNamed:@"icon_search"] forState:UIControlStateNormal];
     [button setImage:[UIImage imageNamed:@"icon_searchOn"] forState:UIControlStateHighlighted];
    _rightButton = button;
    return button;
}

-(UIView *)leftBarButton{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 35, 20, 20, 20)];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icon_backOn"] forState:UIControlStateHighlighted];
    _leftButton = button;
    return button;
}

-(void)back:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:true];
}

-(void)jumpToSearch:(UIButton *)sender{

    self.navigationItem.title = @"";
    _leftButton.hidden = true;
    _rightButton.hidden = true;
    _isShowSearchView = YES;
    [_searchView showSearchViewWithAnimation:YES];
}



-(void)searchCancelButtonClicked{
    _isShowSearchView = NO;
    self.navigationItem.title = [self.mall mallName];
    _leftButton.hidden = false;
    _rightButton.hidden = false;
    [_searchView hideSearchViewWithAnimation:NO];
}
-(void)selectedUniIds:(NSArray *)uniIds{
    YTResultsViewController *resultsVC = [[YTResultsViewController alloc]initWithSearchInMall:self.mall andResultsLocalDBIds:uniIds];
    resultsVC.isSearch = YES;
    [self.navigationController pushViewController:resultsVC animated:YES];
}


#pragma mark View 1
-(void)mainView{
    UIButton *left = [[UIButton alloc]initWithFrame:CGRectMake(8, CGRectGetMaxY(self.navigationController.navigationBar.frame), 148, 44)];
    left.backgroundColor = [UIColor colorWithString:@"ebebeb" alpha:0.2];
    [left setTitle:@"商圈位置" forState:UIControlStateNormal];
    [left setTitleColor:[UIColor colorWithString:@"e5e5e5"] forState:UIControlStateNormal];
    [left setImage:[UIImage imageNamed:@"mall_img_location"] forState:UIControlStateNormal];
    [left setImage:[UIImage imageNamed:@"mall_img_location"] forState:UIControlStateHighlighted];
    [left setBackgroundImage:[UIImage imageNamed:@"shop_bg_2_pr"] forState:UIControlStateHighlighted];
    [left addTarget:self action:@selector(showMallPosition:) forControlEvents:UIControlEventTouchUpInside];
    [left.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [left.layer setCornerRadius:2.5];
    [left setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    
    UIButton *right = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(left.frame)+ 8, CGRectGetMinY(left.frame), CGRectGetWidth(left.frame), CGRectGetHeight(left.frame))];
    right.backgroundColor = [UIColor colorWithString:@"ebebeb" alpha:0.2];
    [right setTitle:@"楼层地图" forState:UIControlStateNormal];
    [right setTitleColor:[UIColor colorWithString:@"e5e5e5"] forState:UIControlStateNormal];
    [right setImage:[UIImage imageNamed:@"mall_img_floor"] forState:UIControlStateNormal];
    [right setImage:[UIImage imageNamed:@"mall_img_floor"] forState:UIControlStateHighlighted];
    [right setBackgroundImage:[UIImage imageNamed:@"shop_bg_2_pr"] forState:UIControlStateHighlighted];
    [right addTarget:self action:@selector(jumpToFloorMap:) forControlEvents:UIControlEventTouchUpInside];
    [right.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [right.layer setCornerRadius:2.5];
    [right setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    
    UIView *categoryView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_scrollView.frame), 200)];
    categoryView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
    _categorys = [YTCategory commonlyCategorysWithAddMore:YES];
    for (int i = 0; i < _categorys.count; i++) {
        UIButton *categoryBtn = [[UIButton alloc]initWithFrame:CGRectMake(15 + i % 4 * 80, 15 + i / 4  * 93, 50, 50)];
        YTCategory *category = _categorys[i];
        [categoryBtn setImage:category.image forState:UIControlStateNormal];
        [categoryBtn addTarget:self action:@selector(jumpToCategory:) forControlEvents:UIControlEventTouchUpInside];
        categoryBtn.tag = i;
        [categoryView addSubview:categoryBtn];
        
        UILabel *categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(categoryBtn.frame) + 8, 50, 20)];
        categoryLabel.center = CGPointMake(categoryBtn.center.x, categoryLabel.center.y);
        NSString *title = category.text;
        if ([title isEqualToString:@"全部分类"]) {
            title = @"更多";
        }
        categoryLabel.text = title;
        categoryLabel.tintColor = [UIColor colorWithString:@"808080"];
        categoryLabel.textAlignment = 1;
        categoryLabel.font = [UIFont systemFontOfSize:14];
        [categoryView addSubview:categoryLabel];
    }
    CGFloat offSetY = CGRectGetMaxY(categoryView.frame);
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, offSetY + 10, CGRectGetWidth(_scrollView.frame),  935) style:UITableViewStylePlain];
    _tableView.scrollEnabled = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   
    _loading = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect frame = _loading.frame;
    frame.origin.x = CGRectGetWidth(_scrollView.frame) / 2 - 50;
    frame.origin.y = CGRectGetMaxY(_tableView.frame) + 20;
    _loading.frame = frame;
    [_loading startAnimating];
    _loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_loading.frame) + 5, CGRectGetMinY(_loading.frame), 84, CGRectGetHeight(_loading.frame))];
    _loadingLabel.text = @"正在加载数据";
    _loadingLabel.textColor = _loading.color;
    _loadingLabel.font = [UIFont systemFontOfSize:14];
    [_scrollView addSubview:_loadingLabel];
    [_scrollView addSubview:_loading];
    
    [self.view addSubview:left];
    [self.view addSubview:right];
    
    [_scrollView addSubview:categoryView];
    [_scrollView addSubview:_tableView];
    
    
    
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame), CGRectGetMaxY(_tableView.frame));
    
    [self getHotsBlack:^(NSArray *merchants) {
        [_loading stopAnimating];
        [_loading removeFromSuperview];
        [_loadingLabel removeFromSuperview];
        _hots = merchants;
        [_tableView reloadData];
    }];
    
    id<YTMall> mall = _mall;
    
    if (mall == nil) {
        [[[YTMessageBox alloc]initWithTitle:@"" Message:@"您当前的网络状况不稳定，请检查网络后再试" cancelButtonTitle:@"确定"] show];
    }
    
    [mall getMallBasicMallInfoWithCallBack:^(NSString *mallName, NSString *address, CLLocationCoordinate2D coord, NSError *error) {
        _posistionVC = [[YTMallPosistionViewController alloc]initWithMallCoordinate:[_mall coord] address:address mallName:[_mall mallName]];
    }];
    
    //优惠信息块
    [_mall existenceOfPreferentialInformationQueryMall:^(BOOL isExistence) {
        if (isExistence) {
            _preferentialView = [[UIView alloc]initWithFrame:CGRectMake(0, offSetY + 10, CGRectGetWidth(_scrollView.frame), 165)];
            _preferentialView.alpha = 0;
            _preferentialView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
            
            UIImage *titleImage = [UIImage imageNamed:@"title_disco"];
            UIImageView *titleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, titleImage.size.width, titleImage.size.height)];
            titleImageView.image = titleImage;
            titleImageView.tag = 10;
            [_preferentialView addSubview:titleImageView];
            
            UIButton *more = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(_scrollView.frame) - 100, 0, 100, 35)];
            [more setTitle:@"更多" forState:UIControlStateNormal];
            [more setTitleColor:[UIColor colorWithString:@"e95e37"] forState:UIControlStateNormal];
            [more.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [more setImage:[UIImage imageNamed:@"icon_arrow_orange"] forState:UIControlStateNormal];
            [more setImageEdgeInsets:UIEdgeInsetsMake(0, 66, 0, 0)];
            [more addTarget:self action:@selector(preferentialMore:) forControlEvents:UIControlEventTouchUpInside];
            [_preferentialView addSubview:more];
            
            NSInteger count = 3;
            CGFloat oneCentenX = (CGRectGetWidth(_scrollView.frame) / count) / 2 - 30;
            CGFloat oneWidth = CGRectGetWidth(_scrollView.frame) / count;
            for (NSInteger  i = 0;i < count; i++){
                UIImageView *iconView = [[UIImageView alloc]initWithFrame:CGRectMake(oneCentenX + i * (60 + oneCentenX * 2), CGRectGetMaxY(titleImageView.frame) + 13.5, 60, 60)];
                iconView.layer.cornerRadius = CGRectGetWidth(iconView.frame) / 2;
                iconView.layer.masksToBounds = true;
                iconView.tag = i;
                iconView.image = [UIImage imageNamed:@"imgshop_default"];
                
                UIImageView *markImageView = [[UIImageView alloc]initWithFrame:CGRectMake((i + 1) * oneWidth - 30, CGRectGetMaxY(titleImageView.frame), 30, 30)];
                markImageView.tag = i + 3;
                markImageView.image = [UIImage imageNamed:@"flag_du"];
                
                UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(iconView.frame) + oneCentenX, CGRectGetMaxY(titleImageView.frame) + 12, 0.5, CGRectGetHeight(_preferentialView.frame) - CGRectGetMaxY(titleImageView.frame) - 24)];
                lineView.backgroundColor = [UIColor colorWithString:@"b2b2b2"];
                
                UILabel *merchantNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(12 +  i * oneWidth, CGRectGetMaxY(iconView.frame) + 10, oneWidth - 24, 15)];
                merchantNameLabel.text = @"敬请期待";
                merchantNameLabel.textColor = [UIColor colorWithString:@"333333"];
                merchantNameLabel.textAlignment = 1;
                merchantNameLabel.tag = i;
                merchantNameLabel.font = [UIFont systemFontOfSize:13];
                
                UILabel *preferentialLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(merchantNameLabel.frame), CGRectGetMaxY(merchantNameLabel.frame) + 5, CGRectGetWidth(merchantNameLabel.frame), CGRectGetHeight(merchantNameLabel.frame))];
                preferentialLabel.textColor = [UIColor colorWithString:@"e95e37"];
                preferentialLabel.textAlignment = 1;
                preferentialLabel.font = [UIFont systemFontOfSize:13];
                preferentialLabel.text = @"暂无优惠";
                preferentialLabel.tag = i + 3;
                
                UIButton *preferentialButton = [[UIButton alloc]initWithFrame:CGRectMake(i * oneWidth, CGRectGetMaxY(titleImageView.frame), oneWidth, CGRectGetHeight(_preferentialView.frame) - CGRectGetMaxY(titleImageView.frame))];
                preferentialButton.tag = i;
                [preferentialButton addTarget:self action:@selector(clickPreferential:) forControlEvents:UIControlEventTouchUpInside];
                
                [_preferentialView addSubview:iconView];
                
                [_preferentialView addSubview:markImageView];
                
                [_preferentialView addSubview:lineView];
                
                [_preferentialView addSubview:merchantNameLabel];
                
                [_preferentialView addSubview:preferentialLabel];
                
                [_preferentialView addSubview:preferentialButton];
                
                [_scrollView addSubview:_preferentialView];
            }
            [self getPreferential:^(NSArray *preferentials) {
                [self reloadPreferentialWithPreferentials:preferentials];
                _preferentials = preferentials;
                [UIView animateWithDuration:0.5 animations:^{
                    CGRect frame = _tableView.frame;
                    frame.origin.y =  CGRectGetMaxY(_preferentialView.frame) + 10;
                    _tableView.frame = frame;
                    _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, CGRectGetMaxY(_tableView.frame));
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.5 animations:^{
                        _preferentialView.alpha = 1;
                    }];
                }];
            }];
            
        }
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YTMerchantViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[YTMerchantViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.titleColor = [UIColor colorWithString:@"333333"];
        cell.backgroundColor = [UIColor clearColor];
    }
    if (_hots.count > 0) {
        cell.merchant = _hots[indexPath.row];
    }
    
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *background = [[UIView alloc]init];
    UIImage *hotImage = [UIImage imageNamed:@"title_hotbrand"];
    UIImageView *hotImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, hotImage.size.width, 27)];
    hotImageView.image = hotImage;
    [background addSubview:hotImageView];
    return background;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YTMerchantViewCell *cell = (YTMerchantViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.merchant){
    YTMerchantInfoViewController *merchantInfoVC = [[YTMerchantInfoViewController alloc]initWithMerchant:cell.merchant];
    [self.navigationController pushViewController:merchantInfoVC animated:YES];
    cell.selected = NO;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:false];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 36;
}

-(void)jumpToCategory:(UIButton *)sender{
    YTCategory *category = _categorys[sender.tag];
    if (sender.tag == _categorys.count - 1) {
        YTMoreCategoryViewController *moreVC = [[YTMoreCategoryViewController alloc]init];
        moreVC.mall = self.mall;
        moreVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:moreVC animated:YES];
    }else{
        YTResultsViewController *resultsVC = [[YTResultsViewController alloc]initWithSearchInMall:self.mall andResutsKey:category.text];
        [self.navigationController pushViewController:resultsVC animated:YES];
    }
}
-(void)jumpToFloorMap:(UIButton *)sender{
    id <YTFloor> floor = nil;
    YTLocalMall *localmall = [_mallDict changeMallObject:self.mall resultType:YTMallClassLocal];
    if (localmall == nil){
        [[[YTMessageBox alloc]initWithTitle:@"" Message:@"很抱歉，此商城暂时不提供该服务，敬请期待" cancelButtonTitle:@"确定"] show];
        return;
    }
    NSArray * temp = [[[localmall blocks] objectAtIndex:0] floors];
    floor = [temp objectAtIndex:0];
    if (floor != nil) {
        YTMapViewController2 *mapVC = [[YTMapViewController2 alloc]initWithFloor:floor];
        mapVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:mapVC animated:YES completion:nil];
    }
}

-(void)getHotsBlack:(void (^)(NSArray *merchants))black{
    AVQuery *query = [AVQuery queryWithClassName:MERCHANT_CLASS_NAME];
    [query whereKeyExists:@"uniId"];
    [query whereKey:@"uniId" notEqualTo:@"0"];
    AVObject *mall = [AVObject objectWithoutDataWithClassName:@"Mall" objectId:[_mall identifier]];
    [query whereKey:@"mall" equalTo:mall];
    query.cachePolicy = kAVCachePolicyCacheElseNetwork;
    query.maxCacheAge = 1 * 3600;
    [query includeKey:@"mall,floor"];
    query.limit = 10;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *merchants = [NSMutableArray array];
            for (AVObject *object in objects) {
                YTCloudMerchant *merchant = [[YTCloudMerchant alloc]initWithAVObject:object];
                [merchants addObject:merchant];
            }
            black([merchants copy]);
            [merchants removeAllObjects];
        }
        else{
           // error 
        }
    }];
    
}

-(void)getPreferential:(void (^)(NSArray *preferentials))black{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://xiaguang.avosapps.com/coupon" parameters:@{@"count":@3,@"mallId":[_mall identifier]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *objects = responseObject;
        NSMutableArray *preferentials = [NSMutableArray array];
        for (NSDictionary *object in objects) {
            YTPreferential *preferential = [[YTPreferential alloc]initWithDaZhongDianPing:object];
            [preferentials addObject:preferential];
        }
        black(preferentials.copy);
        [preferentials removeAllObjects];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        black(nil);
    }];
}

-(void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result{
    NSMutableArray *preferentials = [NSMutableArray arrayWithArray:request.object];
    for (NSDictionary *dictionary in result[@"deals"]) {
        YTPreferential *preferential = [[YTPreferential alloc]initWithDaZhongDianPing:dictionary];
        [preferentials addObject:preferential];
    }
    
    _callBack(preferentials.copy);
    _callBack = nil;
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showMallPosition:(UIButton *)sender{
    [AVAnalytics event:@"showMallmap"];
    if (_posistionVC){
        [self.navigationController pushViewController:_posistionVC animated:YES];
    }
}

-(void)clickPreferential:(UIButton *)sender{
    if (_preferentials.count <= 0) return;
    if (sender.tag > _preferentials.count - 1) return;

    YTPreferential *preferential = _preferentials[sender.tag];
    [preferential getMerchantInstanceWithCallBack:^(YTCloudMerchant *merchant) {
        if (merchant == nil){
            return ;
        }
        YTMerchantInfoViewController *merchantInfoVC = [[YTMerchantInfoViewController alloc]initWithMerchant:merchant];
        [self.navigationController pushViewController:merchantInfoVC animated:YES];
    }];
}

-(void)reloadPreferentialWithPreferentials:(NSArray *)preferentials{
    for (YTPreferential *preferential in preferentials){
        NSInteger index =  [preferentials indexOfObject:preferential];
        for (UIView *view in _preferentialView.subviews) {
            if (view.tag == 10) continue;
            if ([view isMemberOfClass:[UIImageView class]]) {
                if  (view.tag == index){
                    [preferential getMerchantInstanceWithCallBack:^(YTCloudMerchant *merchant) {
                        [merchant getThumbNailWithCallBack:^(UIImage *result, NSError *error) {
                            ((UIImageView *)view).image = result;
                        }];
                    }];
                }else if (view.tag == index + 3){
                    if (preferential.type == YTPreferentialTypeSole) {
                        ((UIImageView *)view).image = [UIImage imageNamed:@"flag_du"];
                    }else{
                        ((UIImageView *)view).image = [UIImage imageNamed:@"flag_tuan"];
                    }
                }
    
            }
            if ([view isMemberOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                if (view.tag == index) {
                    [preferential getMerchantInstanceWithCallBack:^(YTCloudMerchant *merchant) {
                        label.text = [merchant merchantName];
                    }];
                }else if(view.tag == index + 3){
                    label.text = [preferential preferentialInfo];
                }
            }
        }
    }
}

-(void)preferentialMore:(UIButton *)sender{
    YTResultsViewController *resultVC = [[YTResultsViewController alloc]initWithPreferntialInMall:_mall];
    [self.navigationController pushViewController:resultVC animated:true];
}

-(void)dealloc{
    [_searchView removeFromSuperview];
    _posistionVC = nil;
    NSLog(@"mallInfoDealloc");}

@end
