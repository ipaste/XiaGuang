//
//  YTMerchantIndexViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-12.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTMallInfoViewController.h"

#define ROW_HEIGHT 90
#define HEAD_HEIGHT 35
#define DEFAULT_ANIMTAION_TIME 0.5

NSString *const kMerchantCellIdentify = @"MerchantCell";

@interface YTMallInfoViewController (){
    UIImageView *_searchBackgroundView;
    UIScrollView *_scrollView;
    UITableView *_tableView;
    UIButton *_leftBarButton;
    UIButton *_rightBarButton;
    UIButton *_leftButton;
    UIButton *_rightButton;
    UIView *_saleView;
    UIView *_categoryView;
    UIView *_loadingView;
    YTSearchView *_searchView;
    YTStateView *_stateView;
    
    NSArray *_sales;
    NSArray *_categorys;
    NSArray *_hots;
    NSTimeInterval _loadingTime;
    id <YTMall> _mall;
    YTMallDict *_mallDict;
    YTDataManager *_dataManager;
    
    YTMallPositionViewController *_poisitionViewController;
}

@end

@implementation YTMallInfoViewController

- (instancetype)initWithMallIdentify:(NSString *)identify{
    self = [super init];
    if (self) {
        _mallDict = [YTMallDict sharedInstance];
        _mall = [_mallDict getMallFromIdentifier:identify];
        if ([_mall isMemberOfClass:[YTLocalMall class]]) {
            _mall = [_mallDict changeMallObject:_mall resultType:YTMallClassCloud];
        }
        _searchView = [[YTSearchView alloc]initWithMall:_mall placeholder:@"商城/品牌" indent:false];
        _searchView.delegate  = self;
        _dataManager = [YTDataManager defaultDataManager];
        if ([_dataManager currentNetworkStatus] == YTNetworkSatusNotNomal) {
            _stateView = [[YTStateView alloc]initWithStateType:YTStateTypeNoNetWork];
        }else{
            _stateView = [[YTStateView alloc]initWithStateType:YTStateTypeLoading];
            [_stateView startAnimation];
        }
        [_mall getMallBasicMallInfoWithCallBack:^(NSString *mallName, NSString *address, CLLocationCoordinate2D coord, NSError *error) {
            _poisitionViewController = [[YTMallPositionViewController alloc]initWithMallCoordinate:[_mall coord] address:address mallName:[_mall mallName]];
        }];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self defaultNavigationBar];
    _loadingTime = [[NSDate date]timeIntervalSinceReferenceDate];
    
    [_searchView addInNavigationBar:self.navigationController.navigationBar show:false];
    
    _scrollView = [[UIScrollView alloc]init];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.showsVerticalScrollIndicator = false;
    _scrollView.scrollEnabled = false;
    [self.view addSubview:_scrollView];
    
    _leftButton = [[UIButton alloc]init];
    _leftButton.backgroundColor = [UIColor colorWithString:@"ebebeb" alpha:0.2];
    [_leftButton setTitle:@"商圈位置" forState:UIControlStateNormal];
    [_leftButton setTitleColor:[UIColor colorWithString:@"e5e5e5"] forState:UIControlStateNormal];
    [_leftButton setImage:[UIImage imageNamed:@"mall_img_location"] forState:UIControlStateNormal];
    [_leftButton setImage:[UIImage imageNamed:@"mall_img_location"] forState:UIControlStateHighlighted];
    [_leftButton setBackgroundImage:[UIImage imageNamed:@"shop_bg_2_pr"] forState:UIControlStateHighlighted];
    [_leftButton addTarget:self action:@selector(jumpToMallPosition:) forControlEvents:UIControlEventTouchUpInside];
    [_leftButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_leftButton.layer setCornerRadius:2.5];
    [_leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [self.view addSubview:_leftButton];
    
    _rightButton = [[UIButton alloc]init];
    _rightButton.backgroundColor = [UIColor colorWithString:@"ebebeb" alpha:0.2];
    [_rightButton setTitle:@"楼层地图" forState:UIControlStateNormal];
    [_rightButton setTitleColor:[UIColor colorWithString:@"e5e5e5"] forState:UIControlStateNormal];
    [_rightButton setImage:[UIImage imageNamed:@"mall_img_floor"] forState:UIControlStateNormal];
    [_rightButton setImage:[UIImage imageNamed:@"mall_img_floor"] forState:UIControlStateHighlighted];
    [_rightButton setBackgroundImage:[UIImage imageNamed:@"shop_bg_2_pr"] forState:UIControlStateHighlighted];
    [_rightButton addTarget:self action:@selector(jumpToFloorMap:) forControlEvents:UIControlEventTouchUpInside];
    [_rightButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_rightButton.layer setCornerRadius:2.5];
    [_rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [self.view addSubview:_rightButton];
    
    _categoryView = [[UIView alloc]init];
    _categoryView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
    _categorys = [YTCategory commonlyCategorysWithAddMore:YES];
    for (int i = 0; i < _categorys.count; i++) {
        UIButton *categoryBtn = [[UIButton alloc]initWithFrame:CGRectMake(15 + i % 4 * 80, 15 + i / 4  * 93, 50, 50)];
        YTCategory *category = _categorys[i];
        [categoryBtn setImage:category.image forState:UIControlStateNormal];
        [categoryBtn addTarget:self action:@selector(jumpToCategory:) forControlEvents:UIControlEventTouchUpInside];
        categoryBtn.tag = i;
        [_categoryView addSubview:categoryBtn];
        
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
        [_categoryView addSubview:categoryLabel];
    }
    [_scrollView addSubview:_categoryView];
    
    
    _tableView = [[UITableView alloc]init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = false;
    _tableView.rowHeight = ROW_HEIGHT;
    _tableView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_scrollView addSubview:_tableView];
    
    [_mall existenceOfPreferentialInformationQueryMall:^(BOOL isExistence) {
        if (isExistence) {
            _saleView = [[UIView alloc]init];
            _saleView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
            
            UIImage *titleImage = [UIImage imageNamed:@"title_disco"];
            UIImageView *titleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, titleImage.size.width, titleImage.size.height)];
            titleImageView.image = titleImage;
            titleImageView.tag = 10;
            [_saleView addSubview:titleImageView];
            
            UIButton *more = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 100, 0, 100, 35)];
            [more setTitle:@"更多" forState:UIControlStateNormal];
            [more setTitleColor:[UIColor colorWithString:@"e95e37"] forState:UIControlStateNormal];
            [more.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [more setImage:[UIImage imageNamed:@"icon_arrow_orange"] forState:UIControlStateNormal];
            [more setImageEdgeInsets:UIEdgeInsetsMake(0, 66, 0, 0)];
            [more addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
            [_saleView addSubview:more];
            [_scrollView addSubview:_saleView];
            
            for (NSInteger index = 0;index < 3;index++){
                YTSaleView *saleView = [[YTSaleView alloc]initWithFrame:CGRectMake(index * (CGRectGetWidth(self.view.frame) / 3), CGRectGetMaxY(titleImageView.frame), CGRectGetWidth(self.view.frame) / 3, 130)];
                saleView.delegate = self;
                saleView.tag = index;
                saleView.tag = index;
                [_saleView addSubview:saleView];
            }
        }
    }];
    
    [_scrollView addSubview:_stateView];
    
    [self getHot];
    [self getSale];
    
    self.automaticallyAdjustsScrollViewInsets = false;
    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
}

- (void)viewWillLayoutSubviews{
    CGRect frame = _leftButton.frame;
    frame.origin.x = 8;
    frame.origin.y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    frame.size.width = 148;
    frame.size.height = 44;
    _leftButton.frame = frame;
    
    frame = _rightButton.frame;
    frame.origin.x = CGRectGetMaxX(_leftButton.frame) + 8;
    frame.origin.y = CGRectGetMinY(_leftButton.frame);
    frame.size.width = CGRectGetWidth(_leftButton.frame);
    frame.size.height = CGRectGetHeight(_leftButton.frame);
    _rightButton.frame = frame;
    
    frame = _scrollView.frame;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(_leftButton.frame) + 8;
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = CGRectGetHeight(self.view.frame) - frame.origin.y;
    _scrollView.frame = frame;
    
    frame = _categoryView.frame;
    frame.origin = CGPointZero;
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = 200;
    _categoryView.frame = frame;
    
    frame = _saleView.frame;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(_categoryView.frame) + 10;
    frame.size.width = CGRectGetWidth(_scrollView.frame);
    frame.size.height = 165;
    _saleView.frame = frame;
    
    
    frame = _tableView.frame;
    frame.origin.x = 0;
    frame.origin.y = _saleView != nil ? CGRectGetMaxY(_saleView.frame) + 10:CGRectGetMaxY(_categoryView.frame) + 10;
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = ROW_HEIGHT * 10 + HEAD_HEIGHT;
    _tableView.frame = frame;
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(_tableView.frame));
    
    //    if (_saleView) {
    //        [UIView animateWithDuration:DEFAULT_ANIMTAION_TIME animations:^{
    //            CGRect frame = _tableView.frame;
    //            frame.origin.y = CGRectGetMaxY(_saleView.frame) + 10;
    //            _tableView.frame = frame;
    //        } completion:^(BOOL finished) {
    //            [UIView animateWithDuration:DEFAULT_ANIMTAION_TIME animations:^{
    //                _saleView.alpha  = 1;
    //            }];
    //        }];
    //    }
    
}

#pragma mark
#pragma mark NavigationBar Handle
- (void)defaultNavigationBar{
    if (!_leftBarButton) {
        _leftBarButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 35, 20, 20, 20)];
        [_leftBarButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [_leftBarButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
        [_leftBarButton setImage:[UIImage imageNamed:@"icon_backOn"] forState:UIControlStateHighlighted];
    }
    
    if (!_rightBarButton) {
        _rightBarButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 35, 20, 20, 20)];
        [_rightBarButton addTarget:self action:@selector(jumpToSearch:) forControlEvents:UIControlEventTouchUpInside];
        [_rightBarButton setImage:[UIImage imageNamed:@"icon_search"] forState:UIControlStateNormal];
        [_rightBarButton setImage:[UIImage imageNamed:@"icon_searchOn"] forState:UIControlStateHighlighted];
    }
    self.navigationItem.hidesBackButton = true;
    self.navigationItem.title = [_mall mallName];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_leftBarButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_rightBarButton];
    self.navigationController.navigationBar.clipsToBounds = true;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithString:@"e65e37"] forKey:NSForegroundColorAttributeName]];
}

-(void)back:(UIButton *)sender{
    [_searchView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:true];
}

-(void)jumpToSearch:(UIButton *)sender{
    [_searchView showSearchViewWithAnimation:YES];
}

#pragma mark
#pragma mark Custom method
- (void)getHot{
    AVQuery *query = [AVQuery queryWithClassName:@"Merchant"];
    [query whereKeyExists:@"Icon"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *hotMerchants = [NSMutableArray new];
            for (AVObject *object in objects) {
                YTCloudMerchant *merchant = [[YTCloudMerchant alloc]initWithAVObject:object];
                [hotMerchants addObject:merchant];
            }
            _hots = hotMerchants.copy;
            [_tableView reloadData];
            [hotMerchants removeAllObjects];
            hotMerchants = nil;
            [self checkAnimationisStop];
        }else{
            _stateView.type = YTStateTypeNoNetWork;
        }
    }];
}

- (void)getSale{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://xiaguang.avosapps.com/coupon" parameters:@{@"count":@3,@"mallId":[_mall identifier]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            NSArray *objects = responseObject;
            NSMutableArray *preferentials = [NSMutableArray array];
            for (NSDictionary *object in objects) {
                YTPreferential *preferential = [[YTPreferential alloc]initWithDaZhongDianPing:object];
                [preferentials addObject:preferential];
            }
            _sales = preferentials.copy;
            [self reloadSaleData];
            [self checkAnimationisStop];
        }else{
            if (_stateView.type != YTStateTypeNoNetWork) {
                _stateView.type = YTStateTypeNoNetWork;
            }
        }
    } failure:nil];
}

- (void)checkAnimationisStop{
    if (_hots && _sales) {
        _loadingTime -= [[NSDate date]timeIntervalSinceReferenceDate];
        
        dispatch_time_t time;
        if (_loadingTime < 2) {
            time = dispatch_time(DISPATCH_TIME_NOW,NSEC_PER_SEC);
        }else{
            time = dispatch_time(DISPATCH_TIME_NOW, 0);
        }

        dispatch_after(time, dispatch_get_main_queue(), ^{
            [_stateView stopAnimation];
            [_stateView removeFromSuperview];
            _scrollView.scrollEnabled = true;
        });
    }
}

- (void)reloadSaleData{
    [_saleView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[YTSaleView class]]) {
            YTSaleView *saleView = obj;
            YTPreferential *preferential = _sales[saleView.tag];
            [preferential getMerchantInstanceWithCallBack:^(YTCloudMerchant *merchant) {
               [merchant getThumbNailWithCallBack:^(UIImage *result, NSError *error) {
                   if (!error) {
                       [saleView setSaleViewWithMerchantImage:result merchantName:[merchant merchantName] saleInfo:[preferential preferentialInfo] isSole:[preferential type]];
                   }
               }];
            }];
        }
        
    }];
}

#pragma mark
#pragma mark Button Method
- (void)jumpToMallPosition:(UIButton *)sender{
    if (_poisitionViewController){
        [self.navigationController pushViewController:_poisitionViewController animated:YES];
    }
}

-(void)more:(UIButton *)sender{
    YTResultsViewController *resultVC = [[YTResultsViewController alloc]initWithPreferntialInMall:_mall];
    [self.navigationController pushViewController:resultVC animated:true];
}

- (void)jumpToFloorMap:(UIButton *)sender{
    id <YTFloor> floor = nil;
    YTLocalMall *localmall = [_mallDict changeMallObject:_mall resultType:YTMallClassLocal];
    if (localmall == nil){
        [[[YTMessageBox alloc]initWithTitle:@"" Message:@"很抱歉，该商城地图还未下载，请前往地图管理中下载地图" cancelButtonTitle:@"确定"] show];
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

-(void)jumpToCategory:(UIButton *)sender{
    YTCategory *category = _categorys[sender.tag];
    if (sender.tag == _categorys.count - 1) {
        YTMoreCategoryViewController *moreVC = [[YTMoreCategoryViewController alloc]init];
        moreVC.mall = _mall;
        moreVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:moreVC animated:YES];
    }else{
        YTResultsViewController *resultsVC = [[YTResultsViewController alloc]initWithSearchInMall:_mall andResutsKey:category.text];
        [self.navigationController pushViewController:resultsVC animated:YES];
    }
}

- (void)touchEndWithSaleView:(YTSaleView *)saleView{
    YTPreferential *preferential = _sales[saleView.tag];
    [preferential getMerchantInstanceWithCallBack:^(YTCloudMerchant *merchant) {
        if (merchant == nil){
            return ;
        }
        YTMerchantInfoViewController *merchantInfoVC = [[YTMerchantInfoViewController alloc]initWithMerchant:merchant];
        [self.navigationController pushViewController:merchantInfoVC animated:YES];
    }];
}


#pragma mark
#pragma mark SearchView Handle
- (void)selectedUniIds:(NSArray *)uniIds{
    YTResultsViewController *resultsVC = [[YTResultsViewController alloc]initWithSearchInMall:_mall andResultsLocalDBIds:uniIds];
    [self.navigationController pushViewController:resultsVC animated:YES];
}
#pragma mark
#pragma mark TableView Handle
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YTMerchantViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMerchantCellIdentify];
    if (!cell) {
        cell = [[YTMerchantViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMerchantCellIdentify];
        cell.titleColor = [UIColor colorWithString:@"333333"];
        cell.backgroundColor = [UIColor clearColor];
    }
    if (_hots && _hots.count > 0) {
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 36;
}
#pragma mark
#pragma mark Remove searchView else memory leak or viewController not destruction
- (void)dealloc{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSURLCache sharedURLCache]removeAllCachedResponses];
    });
}
@end

//
//@implementation YTMallInfoViewController
//
//- (instancetype)initWithMallIdentify:(NSString *)identify{
//    self = [super init];
//    if (self) {
//        _mallDict = [YTMallDict sharedInstance];
//        _mall = [_mallDict getMallFromIdentifier:identify];
//        if ([_mall isMemberOfClass:[YTLocalMall class]]) {
//            _mall = [_mallDict changeMallObject:_mall resultType:YTMallClassCloud];
//        }
//        _searchView = [[YTSearchView alloc]initWithMall:[_mallDict changeMallObject:_mall resultType:YTMallClassLocal] placeholder:@"商城/品牌" indent:NO];
//        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame) + 50, 320, CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame) - 50)];
//    }
//    return self;
//}
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    self.automaticallyAdjustsScrollViewInsets = false;
//    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
//
//    _scrollView.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:_scrollView];
//
//    _searchView.delegate = self;
//    [_searchView addInNavigationBar:self.navigationController.navigationBar show:NO];
//
//    [self setNavigation];
//    [self mainView];
//}
//
//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    self.navigationItem.hidesBackButton = NO;
//    self.navigationItem.titleView.hidden = NO;
//    self.navigationController.navigationBar.clipsToBounds = true;
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithString:@"e65e37"] forKey:NSForegroundColorAttributeName]];
//    [AVAnalytics beginLogPageView:@"mallInfoViewController"];
//}
//
//-(void)viewDidDisappear:(BOOL)animated{
//    [super viewDidDisappear:animated];
//    if (_isShowSearchView) {
//        [_searchView hideSearchViewWithAnimation:NO];
//    }
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [[NSURLCache sharedURLCache]removeAllCachedResponses];
//    });
//}
//#pragma mark Navigation
//-(void)setNavigation{
//    self.navigationItem.title = [_mall mallName];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self rightBarButton]];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButton]];
//}
//
//-(UIView *)rightBarButton{
//    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 35, 20, 20, 20)];
//    [button addTarget:self action:@selector(jumpToSearch:) forControlEvents:UIControlEventTouchUpInside];
//    [button setImage:[UIImage imageNamed:@"icon_search"] forState:UIControlStateNormal];
//     [button setImage:[UIImage imageNamed:@"icon_searchOn"] forState:UIControlStateHighlighted];
//    _rightButton = button;
//    return button;
//}
//
//-(UIView *)leftBarButton{
//    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 35, 20, 20, 20)];
//    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
//    [button setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
//    [button setImage:[UIImage imageNamed:@"icon_backOn"] forState:UIControlStateHighlighted];
//    _leftButton = button;
//    return button;
//}
//
//-(void)back:(UIButton *)sender{
//    [self.navigationController popViewControllerAnimated:true];
//}
//
//-(void)jumpToSearch:(UIButton *)sender{
//    self.navigationItem.title = @"";
//    _leftButton.hidden = true;
//    _rightButton.hidden = true;
//    _isShowSearchView = YES;
//    [_searchView showSearchViewWithAnimation:YES];
//}
//
//
//
//-(void)searchCancelButtonClicked{
//    _isShowSearchView = NO;
//    self.navigationItem.title = [_mall mallName];
//    _leftButton.hidden = false;
//    _rightButton.hidden = false;
//    [_searchView hideSearchViewWithAnimation:NO];
//}
//-(void)selectedUniIds:(NSArray *)uniIds{
//    YTResultsViewController *resultsVC = [[YTResultsViewController alloc]initWithSearchInMall:_mall andResultsLocalDBIds:uniIds];
//    [self.navigationController pushViewController:resultsVC animated:YES];
//}
//
//
//#pragma mark View 1
//-(void)mainView{
//    NSLog(@"%f",CGRectGetMaxY(self.navigationController.navigationBar.frame));
//    UIButton *left = [[UIButton alloc]initWithFrame:CGRectMake(8, CGRectGetMaxY(self.navigationController.navigationBar.frame), 148, 44)];
//    left.backgroundColor = [UIColor colorWithString:@"ebebeb" alpha:0.2];
//    [left setTitle:@"商圈位置" forState:UIControlStateNormal];
//    [left setTitleColor:[UIColor colorWithString:@"e5e5e5"] forState:UIControlStateNormal];
//    [left setImage:[UIImage imageNamed:@"mall_img_location"] forState:UIControlStateNormal];
//    [left setImage:[UIImage imageNamed:@"mall_img_location"] forState:UIControlStateHighlighted];
//    [left setBackgroundImage:[UIImage imageNamed:@"shop_bg_2_pr"] forState:UIControlStateHighlighted];
//    [left addTarget:self action:@selector(showMallPosition:) forControlEvents:UIControlEventTouchUpInside];
//    [left.titleLabel setFont:[UIFont systemFontOfSize:15]];
//    [left.layer setCornerRadius:2.5];
//    [left setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
//
//    UIButton *right = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(left.frame)+ 8, CGRectGetMinY(left.frame), CGRectGetWidth(left.frame), CGRectGetHeight(left.frame))];
//    right.backgroundColor = [UIColor colorWithString:@"ebebeb" alpha:0.2];
//    [right setTitle:@"楼层地图" forState:UIControlStateNormal];
//    [right setTitleColor:[UIColor colorWithString:@"e5e5e5"] forState:UIControlStateNormal];
//    [right setImage:[UIImage imageNamed:@"mall_img_floor"] forState:UIControlStateNormal];
//    [right setImage:[UIImage imageNamed:@"mall_img_floor"] forState:UIControlStateHighlighted];
//    [right setBackgroundImage:[UIImage imageNamed:@"shop_bg_2_pr"] forState:UIControlStateHighlighted];
//    [right addTarget:self action:@selector(jumpToFloorMap:) forControlEvents:UIControlEventTouchUpInside];
//    [right.titleLabel setFont:[UIFont systemFontOfSize:15]];
//    [right.layer setCornerRadius:2.5];
//    [right setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
//
//    UIView *categoryView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_scrollView.frame), 200)];
//    categoryView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
//    _categorys = [YTCategory commonlyCategorysWithAddMore:YES];
//    for (int i = 0; i < _categorys.count; i++) {
//        UIButton *categoryBtn = [[UIButton alloc]initWithFrame:CGRectMake(15 + i % 4 * 80, 15 + i / 4  * 93, 50, 50)];
//        YTCategory *category = _categorys[i];
//        [categoryBtn setImage:category.image forState:UIControlStateNormal];
//        [categoryBtn addTarget:self action:@selector(jumpToCategory:) forControlEvents:UIControlEventTouchUpInside];
//         categoryBtn.tag = i;
//        [categoryView addSubview:categoryBtn];
//
//        UILabel *categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(categoryBtn.frame) + 8, 50, 20)];
//        categoryLabel.center = CGPointMake(categoryBtn.center.x, categoryLabel.center.y);
//        NSString *title = category.text;
//        if ([title isEqualToString:@"全部分类"]) {
//            title = @"更多";
//        }
//        categoryLabel.text = title;
//        categoryLabel.tintColor = [UIColor colorWithString:@"808080"];
//        categoryLabel.textAlignment = 1;
//        categoryLabel.font = [UIFont systemFontOfSize:14];
//        [categoryView addSubview:categoryLabel];
//    }
//
//
//    CGFloat offSetY = CGRectGetMaxY(categoryView.frame);
//    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, offSetY + 10, CGRectGetWidth(_scrollView.frame),  935) style:UITableViewStylePlain];
//    _tableView.scrollEnabled = NO;
//    _tableView.delegate = self;
//    _tableView.dataSource = self;
//    _tableView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//
//    _loading = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    CGRect frame = _loading.frame;
//    frame.origin.x = CGRectGetWidth(_scrollView.frame) / 2 - 50;
//    frame.origin.y = CGRectGetMaxY(_tableView.frame) + 20;
//    _loading.frame = frame;
//    [_loading startAnimating];
//    _loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_loading.frame) + 5, CGRectGetMinY(_loading.frame), 84, CGRectGetHeight(_loading.frame))];
//    _loadingLabel.text = @"正在加载数据";
//    _loadingLabel.textColor = _loading.color;
//    _loadingLabel.font = [UIFont systemFontOfSize:14];
//    [_scrollView addSubview:_loadingLabel];
//    [_scrollView addSubview:_loading];
//
//    [self.view addSubview:left];
//    [self.view addSubview:right];
//
//    [_scrollView addSubview:categoryView];
//    [_scrollView addSubview:_tableView];
//
//    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame), CGRectGetMaxY(_tableView.frame));
//
//    [self getHotsBlack:^(NSArray *merchants) {
//        [_loading stopAnimating];
//        [_loading removeFromSuperview];
//        [_loadingLabel removeFromSuperview];
//        _hots = merchants;
//        [_tableView reloadData];
//    }];
//
//    id<YTMall> mall = _mall;
//
//    if (mall == nil) {
//        [[[YTMessageBox alloc]initWithTitle:@"" Message:@"您当前的网络状况不稳定，请检查网络后再试" cancelButtonTitle:@"确定"] show];
//    }
//
//    [mall getMallBasicMallInfoWithCallBack:^(NSString *mallName, NSString *address, CLLocationCoordinate2D coord, NSError *error) {
//        _posistionVC = [[YTMallPosistionViewController alloc]initWithMallCoordinate:[_mall coord] address:address mallName:[_mall mallName]];
//    }];
//
//    //优惠信息块
//    [_mall existenceOfPreferentialInformationQueryMall:^(BOOL isExistence) {
//        if (isExistence) {
//            _preferentialView = [[UIView alloc]initWithFrame:CGRectMake(0, offSetY + 10, CGRectGetWidth(_scrollView.frame), 165)];
//            _preferentialView.alpha = 0;
//            _preferentialView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
//
//            UIImage *titleImage = [UIImage imageNamed:@"title_disco"];
//            UIImageView *titleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, titleImage.size.width, titleImage.size.height)];
//            titleImageView.image = titleImage;
//            titleImageView.tag = 10;
//            [_preferentialView addSubview:titleImageView];
//
//            UIButton *more = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(_scrollView.frame) - 100, 0, 100, 35)];
//            [more setTitle:@"更多" forState:UIControlStateNormal];
//            [more setTitleColor:[UIColor colorWithString:@"e95e37"] forState:UIControlStateNormal];
//            [more.titleLabel setFont:[UIFont systemFontOfSize:13]];
//            [more setImage:[UIImage imageNamed:@"icon_arrow_orange"] forState:UIControlStateNormal];
//            [more setImageEdgeInsets:UIEdgeInsetsMake(0, 66, 0, 0)];
//            [more addTarget:self action:@selector(preferentialMore:) forControlEvents:UIControlEventTouchUpInside];
//            [_preferentialView addSubview:more];
//
//            NSInteger count = 3;
//            CGFloat oneCentenX = (CGRectGetWidth(_scrollView.frame) / count) / 2 - 30;
//            CGFloat oneWidth = CGRectGetWidth(_scrollView.frame) / count;
//            for (NSInteger  i = 0;i < count; i++){
//                UIImageView *iconView = [[UIImageView alloc]initWithFrame:CGRectMake(oneCentenX + i * (60 + oneCentenX * 2), CGRectGetMaxY(titleImageView.frame) + 13.5, 60, 60)];
//                iconView.layer.cornerRadius = CGRectGetWidth(iconView.frame) / 2;
//                iconView.layer.masksToBounds = true;
//                iconView.tag = i;
//                iconView.image = [UIImage imageNamed:@"imgshop_default"];
//
//                UIImageView *markImageView = [[UIImageView alloc]initWithFrame:CGRectMake((i + 1) * oneWidth - 30, CGRectGetMaxY(titleImageView.frame), 30, 30)];
//                markImageView.tag = i + 3;
//                markImageView.image = [UIImage imageNamed:@"flag_du"];
//
//                UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(iconView.frame) + oneCentenX, CGRectGetMaxY(titleImageView.frame) + 12, 0.5, CGRectGetHeight(_preferentialView.frame) - CGRectGetMaxY(titleImageView.frame) - 24)];
//                lineView.backgroundColor = [UIColor colorWithString:@"b2b2b2"];
//
//                UILabel *merchantNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(12 +  i * oneWidth, CGRectGetMaxY(iconView.frame) + 10, oneWidth - 24, 15)];
//                merchantNameLabel.text = @"敬请期待";
//                merchantNameLabel.textColor = [UIColor colorWithString:@"333333"];
//                merchantNameLabel.textAlignment = 1;
//                merchantNameLabel.tag = i;
//                merchantNameLabel.font = [UIFont systemFontOfSize:13];
//
//                UILabel *preferentialLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(merchantNameLabel.frame), CGRectGetMaxY(merchantNameLabel.frame) + 5, CGRectGetWidth(merchantNameLabel.frame), CGRectGetHeight(merchantNameLabel.frame))];
//                preferentialLabel.textColor = [UIColor colorWithString:@"e95e37"];
//                preferentialLabel.textAlignment = 1;
//                preferentialLabel.font = [UIFont systemFontOfSize:13];
//                preferentialLabel.text = @"暂无优惠";
//                preferentialLabel.tag = i + 3;
//
//                UIButton *preferentialButton = [[UIButton alloc]initWithFrame:CGRectMake(i * oneWidth, CGRectGetMaxY(titleImageView.frame), oneWidth, CGRectGetHeight(_preferentialView.frame) - CGRectGetMaxY(titleImageView.frame))];
//                preferentialButton.tag = i;
//                [preferentialButton addTarget:self action:@selector(clickPreferential:) forControlEvents:UIControlEventTouchUpInside];
//
//                [_preferentialView addSubview:iconView];
//
//                [_preferentialView addSubview:markImageView];
//
//                [_preferentialView addSubview:lineView];
//
//                [_preferentialView addSubview:merchantNameLabel];
//
//                [_preferentialView addSubview:preferentialLabel];
//
//                [_preferentialView addSubview:preferentialButton];
//
//                [_scrollView addSubview:_preferentialView];
//            }
//            [self getPreferential:^(NSArray *preferentials) {
//                [self reloadPreferentialWithPreferentials:preferentials];
//                _preferentials = preferentials;
//                [UIView animateWithDuration:0.5 animations:^{
//                    CGRect frame = _tableView.frame;
//                    frame.origin.y =  CGRectGetMaxY(_preferentialView.frame) + 10;
//                    _tableView.frame = frame;
//                    _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, CGRectGetMaxY(_tableView.frame));
//                } completion:^(BOOL finished) {
//                    [UIView animateWithDuration:0.5 animations:^{
//                        _preferentialView.alpha = 1;
//                    }];
//                }];
//            }];
//
//        }
//    }];
//}
//
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 10;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    YTMerchantViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    if (!cell) {
//        cell = [[YTMerchantViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
//        cell.titleColor = [UIColor colorWithString:@"333333"];
//        cell.backgroundColor = [UIColor clearColor];
//    }
//    if (_hots.count > 0) {
//        cell.merchant = _hots[indexPath.row];
//    }
//
//    return cell;
//}
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *background = [[UIView alloc]init];
//    UIImage *hotImage = [UIImage imageNamed:@"title_hotbrand"];
//    UIImageView *hotImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, hotImage.size.width, 27)];
//    hotImageView.image = hotImage;
//    [background addSubview:hotImageView];
//    return background;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 36;
//}
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    YTMerchantViewCell *cell = (YTMerchantViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//    if (cell.merchant){
//    YTMerchantInfoViewController *merchantInfoVC = [[YTMerchantInfoViewController alloc]initWithMerchant:cell.merchant];
//    [self.navigationController pushViewController:merchantInfoVC animated:YES];
//    cell.selected = NO;
//    }
//    [tableView deselectRowAtIndexPath:indexPath animated:false];
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 90;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 36;
//}
//
//-(void)jumpToCategory:(UIButton *)sender{
//    YTCategory *category = _categorys[sender.tag];
//    if (sender.tag == _categorys.count - 1) {
//        YTMoreCategoryViewController *moreVC = [[YTMoreCategoryViewController alloc]init];
//        moreVC.mall = _mall;
//        moreVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:moreVC animated:YES];
//    }else{
//        YTResultsViewController *resultsVC = [[YTResultsViewController alloc]initWithSearchInMall:_mall andResutsKey:category.text];
//        [self.navigationController pushViewController:resultsVC animated:YES];
//    }
//}
//-(void)jumpToFloorMap:(UIButton *)sender{
//    id <YTFloor> floor = nil;
//    YTLocalMall *localmall = [_mallDict changeMallObject:_mall resultType:YTMallClassLocal];
//    if (localmall == nil){
//        [[[YTMessageBox alloc]initWithTitle:@"" Message:@"很抱歉，此商城暂时不提供该服务，敬请期待" cancelButtonTitle:@"确定"] show];
//        return;
//    }
//    NSArray * temp = [[[localmall blocks] objectAtIndex:0] floors];
//    floor = [temp objectAtIndex:0];
//    if (floor != nil) {
//        YTMapViewController2 *mapVC = [[YTMapViewController2 alloc]initWithFloor:floor];
//        mapVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//        [self presentViewController:mapVC animated:YES completion:nil];
//    }
//}
//
//-(void)getHotsBlack:(void (^)(NSArray *merchants))black{
//    AVQuery *query = [AVQuery queryWithClassName:MERCHANT_CLASS_NAME];
//    [query whereKeyExists:@"uniId"];
//    [query whereKey:@"uniId" notEqualTo:@"0"];
//    AVObject *mall = [AVObject objectWithoutDataWithClassName:@"Mall" objectId:[_mall identifier]];
//    [query whereKey:@"mall" equalTo:mall];
//    query.cachePolicy = kAVCachePolicyCacheElseNetwork;
//    query.maxCacheAge = 1 * 3600;
//    [query includeKey:@"mall,floor"];
//    query.limit = 10;
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            NSMutableArray *merchants = [NSMutableArray array];
//            for (AVObject *object in objects) {
//                YTCloudMerchant *merchant = [[YTCloudMerchant alloc]initWithAVObject:object];
//                [merchants addObject:merchant];
//            }
//            black([merchants copy]);
//            [merchants removeAllObjects];
//        }
//        else{
//           // error
//        }
//    }];
//
//}
//
//-(void)getPreferential:(void (^)(NSArray *preferentials))black{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager GET:@"http://xiaguang.avosapps.com/coupon" parameters:@{@"count":@3,@"mallId":[_mall identifier]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSArray *objects = responseObject;
//        NSMutableArray *preferentials = [NSMutableArray array];
//        for (NSDictionary *object in objects) {
//            YTPreferential *preferential = [[YTPreferential alloc]initWithDaZhongDianPing:object];
//            [preferentials addObject:preferential];
//        }
//        black(preferentials.copy);
//        [preferentials removeAllObjects];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        black(nil);
//    }];
//}
//
//-(void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result{
//    NSMutableArray *preferentials = [NSMutableArray arrayWithArray:request.object];
//    for (NSDictionary *dictionary in result[@"deals"]) {
//        YTPreferential *preferential = [[YTPreferential alloc]initWithDaZhongDianPing:dictionary];
//        [preferentials addObject:preferential];
//    }
//
//    _callBack(preferentials.copy);
//    _callBack = nil;
//}
//
//
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//-(void)showMallPosition:(UIButton *)sender{
//    [AVAnalytics event:@"showMallmap"];
//    if (_posistionVC){
//        [self.navigationController pushViewController:_posistionVC animated:YES];
//    }
//}
//
//-(void)clickPreferential:(UIButton *)sender{
//    if (_preferentials.count <= 0) return;
//    if (sender.tag > _preferentials.count - 1) return;
//
//    YTPreferential *preferential = _preferentials[sender.tag];
//    [preferential getMerchantInstanceWithCallBack:^(YTCloudMerchant *merchant) {
//        if (merchant == nil){
//            return ;
//        }
//        YTMerchantInfoViewController *merchantInfoVC = [[YTMerchantInfoViewController alloc]initWithMerchant:merchant];
//        [self.navigationController pushViewController:merchantInfoVC animated:YES];
//    }];
//}
//
//-(void)reloadPreferentialWithPreferentials:(NSArray *)preferentials{
//    for (YTPreferential *preferential in preferentials){
//        NSInteger index =  [preferentials indexOfObject:preferential];
//        for (UIView *view in _preferentialView.subviews) {
//            if (view.tag == 10) continue;
//            if ([view isMemberOfClass:[UIImageView class]]) {
//                if  (view.tag == index){
//                    [preferential getMerchantInstanceWithCallBack:^(YTCloudMerchant *merchant) {
//                        [merchant getThumbNailWithCallBack:^(UIImage *result, NSError *error) {
//                            ((UIImageView *)view).image = result;
//                        }];
//                    }];
//                }else if (view.tag == index + 3){
//                    if (preferential.type == YTPreferentialTypeSole) {
//                        ((UIImageView *)view).image = [UIImage imageNamed:@"flag_du"];
//                    }else{
//                        ((UIImageView *)view).image = [UIImage imageNamed:@"flag_tuan"];
//                    }
//                }
//
//            }
//            if ([view isMemberOfClass:[UILabel class]]) {
//                UILabel *label = (UILabel *)view;
//                if (view.tag == index) {
//                    [preferential getMerchantInstanceWithCallBack:^(YTCloudMerchant *merchant) {
//                        label.text = [merchant merchantName];
//                    }];
//                }else if(view.tag == index + 3){
//                    label.text = [preferential preferentialInfo];
//                }
//            }
//        }
//    }
//}
//
//-(void)preferentialMore:(UIButton *)sender{
//    YTResultsViewController *resultVC = [[YTResultsViewController alloc]initWithPreferntialInMall:_mall];
//    [self.navigationController pushViewController:resultVC animated:true];
//}
//
//-(void)dealloc{
//    [_searchView removeFromSuperview];
//    _posistionVC = nil;
//    NSLog(@"mallInfoDealloc");}
//
//@end
