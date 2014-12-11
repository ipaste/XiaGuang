//
//  YTHomeViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-8-28.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTMallViewController.h"
#define DEVICE_VERSION [[[UIDevice currentDevice]systemVersion] floatValue]
#define TABLEVIEWCELL_HEIGHT 90
#define MALL_SORT @"mall_sort"
@interface YTMallViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    NSMutableArray *_mallObjects;
    NSMutableArray *_bundleObjects;
    YTUserDefaults *_userDefaults;
    YTLoadingView *_loadingView;
    float _num;
    BOOL _isLoadingDone;
}
@end

@implementation YTMallViewController
-(instancetype)init{
    self = [super init];
    if (self) {
        self.navigationItem.title = @"商圈";
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
        
        _userDefaults = [YTUserDefaults standardUserDefaults];
        _bundleObjects = [NSMutableArray array];
        _mallObjects = [NSMutableArray array];
        
        
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _loadingView = [[YTLoadingView alloc]initWithPosistion:CGPointMake(0, 64)];
    [self.view addSubview:_loadingView];
    [self loadTableView];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [AVAnalytics beginLogPageView:@"mallViewController"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [AVAnalytics endLogPageView:@"mallViewController"];
}

-(void)viewWillLayoutSubviews{
    CGFloat topHeight = [self.topLayoutGuide length];
    CGRect frame = _tableView.frame;
    frame.origin.y = topHeight;
    frame.size.height = CGRectGetHeight(self.view.frame) - topHeight;
    _tableView.frame = frame;
}


-(void)loadTableView{
    [_loadingView start];
    AVQuery *query = [AVQuery queryWithClassName:@"Mall"];
    query.cachePolicy = kAVCachePolicyCacheElseNetwork;
    query.maxCacheAge = 2*3600;
    [query whereKeyExists:@"localDBId"];
    [query includeKey:@"mallNameLogo"];
    [query whereKey:@"localDBId" notEqualTo:@""];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *tmpMallObjects = [NSMutableArray array];
            for (AVObject *mallObject in objects) {
                YTCloudMall *mall = [[YTCloudMall alloc]initWithAVObject:mallObject];
                [tmpMallObjects addObject:mall];
            }
            
            if ([_userDefaults existenceOfTheKey:MALL_SORT]) {
                [_mallObjects addObjectsFromArray:[self mallCenterSortFromObjects:tmpMallObjects]];
            }else{
                NSMutableDictionary *tmpMutableDict = [NSMutableDictionary dictionary];
                for (YTCloudMall *tmpMall in tmpMallObjects) {
                    [tmpMutableDict setValue:@"0" forKey:[tmpMall mallName]];
                    YTMallMerchantBundle *merchantBundle = [[YTMallMerchantBundle alloc]initWithMall:tmpMall];
                    [_bundleObjects addObject:merchantBundle];
                    [_mallObjects addObject:tmpMall];
                }
                [_userDefaults setDictionary:tmpMutableDict forKey:MALL_SORT];
            }
            
            [_tableView reloadData];
            
        }else{
            //获取失败
            NSLog(@"无网络");
            [[[UIAlertView alloc]initWithTitle:@"对不起" message:@"您的网络状况不好，无法显示商城内容，请检查是否开启无线网络" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil]show];
        }
        [_loadingView stop];
    }];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)selectMerchant:(id<YTMerchant>)merchant{
    YTMerchantInfoViewController *merchantInfoVC = [[YTMerchantInfoViewController alloc]initWithMerchant:merchant];
    merchantInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:merchantInfoVC animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _mallObjects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YTMallCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[YTMallCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.mallMerchantBundle = _bundleObjects[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return TABLEVIEWCELL_HEIGHT;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id<YTMall> tmpMall = _mallObjects[indexPath.section];
    
    
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithDictionary:[_userDefaults dictionaryWithKey:MALL_SORT]];
    
    
    [tmpDict setValue:[NSString stringWithFormat:@"%d",[[tmpDict valueForKey:[tmpMall mallName]]intValue] + 1] forKey:[tmpMall mallName]];
    
    
    [_userDefaults setDictionary:tmpDict forKey:MALL_SORT];
    
    YTMallInfoViewController * mallVC = [[YTMallInfoViewController alloc]init];
    mallVC.mall = tmpMall;
    [self.navigationController pushViewController:mallVC animated:YES];
}

-(NSArray *)mallCenterSortFromObjects:(NSArray *)objects{
    NSMutableArray *malls = [NSMutableArray array];
    NSDictionary *tmpDictionary = [_userDefaults dictionaryWithKey:MALL_SORT];
    NSArray *result = [tmpDictionary keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1 options:NSNumericSearch];
    }];
    for (NSString *mallName in result) {
        for (id<YTMall> tmpMall in objects) {
            if ([[tmpMall mallName] isEqualToString:mallName]) {
                [malls addObject:tmpMall];
                YTMallMerchantBundle *tmpMerchantBundle = [[YTMallMerchantBundle alloc]initWithMall:tmpMall];
                [_bundleObjects addObject:tmpMerchantBundle];
                
            }
        }
    }
    return malls;
}

-(void)dealloc{
    NSLog(@"mallViewController Dealloc");
}
@end
