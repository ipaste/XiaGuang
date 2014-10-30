//
//  YTHomeViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-8-28.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTMallViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "YTMallCell.h"
#import "YTCloudMall.h"
#import "YTMerchantInfoViewController.h"
#import "YTSettingViewController.h"
#import <MMProgressHUD.h>
#import "YTMallMerchantBundle.h"
#import "YTMallInfoViewController.h"
#import "MJRefresh.h"
#import <AVQuery.h>
#define DEVICE_VERSION [[[UIDevice currentDevice]systemVersion] floatValue]
#define TABLEVIEWCELL_HEIGHT 110
@interface YTMallViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    NSMutableArray *_mallObjects;
    NSMutableArray *_bundleObjects;
    float _num;
    BOOL _isLoadingDone;
}
@end

@implementation YTMallViewController
-(instancetype)init{
    self = [super init];
    if (self) {
        self.navigationItem.title = @"商圈";
        self.automaticallyAdjustsScrollViewInsets = NO;
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadTableView];
    
}


-(void)viewWillLayoutSubviews{
    CGFloat topHeight = [self.topLayoutGuide length];
    CGRect frame = _tableView.frame;
    frame.origin.y = topHeight;
    frame.size.height = CGRectGetHeight(self.view.bounds) - topHeight;
    _tableView.frame = frame;
}


-(void)loadTableView{
        __block BOOL isFetch = NO;
        _mallObjects = [NSMutableArray array];
        _bundleObjects = [NSMutableArray array];
        AVQuery *query = [AVQuery queryWithClassName:@"Mall"];
        //query.cachePolicy = kAVCachePolicyCacheElseNetwork;
        //query.maxCacheAge = 1800;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (AVObject *mallObject in objects) {
                    YTCloudMall *mall = [[YTCloudMall alloc]initWithAVObject:mallObject];
                    [_mallObjects addObject:mall];
                    YTMallMerchantBundle *tmpBundle = [[YTMallMerchantBundle alloc] initWithMall:mall];
                    [_bundleObjects addObject:tmpBundle];
                }
                isFetch = YES;
                
                [_tableView headerEndRefreshing];
                if (isFetch) {
                    [_tableView removeHeader];
                }
                
                [_tableView reloadData];
            }else{
                //获取失败
            }
            
        }];
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
    return 7;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YTMallInfoViewController * mallVC = [[YTMallInfoViewController alloc]init];
    mallVC.mall = _mallObjects[indexPath.section];
    [self.navigationController pushViewController:mallVC animated:YES];
}


-(void)dealloc{
    NSLog(@"mallViewController Dealloc");
}
@end
