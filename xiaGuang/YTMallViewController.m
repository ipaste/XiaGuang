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
@interface YTMallViewController ()<UITableViewDataSource,UITableViewDelegate,YTMallDelegate>{
    UITableView *_tableView;
    NSMutableArray *_mallObjects;
    NSMutableArray *_bundleObjects;
    float _num;
    BOOL _isLoadingDone;
    UILabel *_promptLabel;
}
@end

@implementation YTMallViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
/*    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButtonItemCustomView]];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self rightBarButtonItemCustomView]];
    self.navigationItem.title = @"商圈";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
*/
     self.navigationItem.title = @"商圈";
    _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_1"]];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    _promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 250, 60)];
    _promptLabel.textAlignment = 1;
    _promptLabel.numberOfLines = 3;
    _promptLabel.font = [UIFont systemFontOfSize:14];
    _promptLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _promptLabel.textColor = [UIColor colorWithString:@"202020"];
    [_tableView addSubview:_promptLabel];
    
    //[_tableView addHeaderWithTarget:self action:@selector(dropDown)];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self dropDown];
    
}
-(void)viewWillLayoutSubviews{
    CGFloat topHeight = [self.topLayoutGuide length];
    CGRect frame = _tableView.frame;
    frame.origin.y = topHeight ;
    frame.size.height = CGRectGetHeight(self.view.frame) - topHeight;
    _tableView.frame = frame;
    _promptLabel.center = _tableView.center;
}

-(UIView *)leftBarButtonItemCustomView{
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 60, 40)];
    [leftButton setTitle:@"深圳" forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor colorWithString:@"#fac890"] forState:UIControlStateHighlighted];
    [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0 , -10, 0, 0)];
    [leftButton setImage:[UIImage imageNamed:@"home1_ico_location_un"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"home1_ico_location_pr"] forState:UIControlStateHighlighted];
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    return leftButton;
}

-(UIView *)rightBarButtonItemCustomView{
    UIImage *image = [UIImage imageNamed:@"home1_ico_set_un"];
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, image.size.width, image.size.height)];
    [rightButton setImage:image forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(jumpToSetting:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImage:[UIImage imageNamed:@"home1_ico_set_pr"] forState:UIControlStateHighlighted];
    return rightButton;
}

-(void)dropDown{
    _promptLabel.hidden = YES;
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

-(void)jumpToSetting:(UIButton *)sender{
    YTSettingViewController *settingVC = [[YTSettingViewController alloc]init];
    settingVC.hidesBottomBarWhenPushed = YES;
    settingVC.isLatest = YES;
    [self.navigationController pushViewController:settingVC animated:YES];
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
    cell.delegate = self;
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
    mallVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mallVC animated:YES];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end
