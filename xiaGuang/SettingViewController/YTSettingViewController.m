//
//  YTSettingViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-28.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTSettingViewController.h"

@interface YTSettingViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    CGFloat _duration;
    BOOL _isShowAnimation;
}
@end

@implementation YTSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _duration = 0.0f;
    _isShowAnimation = YES;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame)) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setBackgroundColor:[UIColor clearColor]];
    _tableView.separatorColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    [self.view addSubview:_tableView];
    self.navigationItem.title = @"设置";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButton]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithString:@"e65e37"] forKey:NSForegroundColorAttributeName]];
    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
    self.automaticallyAdjustsScrollViewInsets = false;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 10:
            return 0;
        case 0:
            
            return 2;
        case 1:
            
            return 5;
    }
    return 0;
    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    UIView *selectView = [[UIView alloc]initWithFrame:CGRectZero];
    [selectView setBackgroundColor:[UIColor colorWithString:@"000000" alpha:0.3]];
    cell.selectedBackgroundView = selectView;
    cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    cell.textLabel.textColor = [UIColor whiteColor];

    if (indexPath.section == 10) {
        cell.textLabel.text = @"邀请好友使用虾逛";
        cell.imageView.image = [UIImage imageNamed:@"icon_1"];
    }else if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"商城地图管理";
                cell.imageView.image = [UIImage imageNamed:@"icon_2"];
                break;
            case 1:
                cell.textLabel.text = @"新手指引";
                cell.imageView.image = [UIImage imageNamed:@"icon_3"];
                break;
        }
    }else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
            {
                cell.textLabel.text = @"版本更新";
                cell.imageView.image = [UIImage imageNamed:@"icon_4"];
                if (!self.isLatest) {
                    UIButton *latestBtn  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 20)];
                    latestBtn.center = CGPointMake(CGRectGetWidth(self.view.frame) - 50, 22);
                    [latestBtn setTitle:@"新版本" forState:UIControlStateNormal];
                    [latestBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
                    [latestBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [latestBtn setBackgroundColor:[UIColor colorWithString:@"e95e37"]];
                    latestBtn.layer.cornerRadius = CGRectGetHeight(latestBtn.frame) / 2;
                    [cell addSubview:latestBtn];
                }else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.detailTextLabel.text = @"已是最新版本";
                    cell.detailTextLabel.textColor = [UIColor colorWithString:@"909090"];
                    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
            }
                break;
            case 1:
                cell.textLabel.text = @"给虾逛评分";
                cell.imageView.image = [UIImage imageNamed:@"icon_5"];
                break;
            case 2:
                cell.textLabel.text = @"关于虾逛";
                cell.imageView.image = [UIImage imageNamed:@"icon_6"];
                //_isShowAnimation = NO;
                break;
            case 3:
                cell.textLabel.text = @"用户协议";
                cell.imageView.image = [UIImage imageNamed:@"icon_7"];
                _isShowAnimation = NO;
                break;
            case 4:
                cell.textLabel.text = @"意见反馈";
                cell.imageView.image =[UIImage imageNamed:@"icon_8"];
                break;
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UIViewController *controller = nil;
    if (indexPath.section == 10) {
        controller = [[YTInvitationViewController alloc]init];
    }else if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                controller = [[YTMallManageListViewController alloc]init];
                /*NSString *url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d",922405498];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                 return;
                break;*/
            }
                break;
            case 1:
            {
               //controller = [[YTFeedBackViewController alloc]init];
                break;
            }
              
        }
    }else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
            {
                cell.textLabel.text = @"版本更新";
                if (!self.isLatest) {
                    //跳转AppStore
                    NSString *url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d",922405498];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                }else{
                    return;
                }
                
            }
                break;
            case 1:
            {
                //controller = [[YTAboutViewController alloc]init];
            }
                break;
            case 2:
            {
                controller = [[YTAboutViewController alloc]init];
               
            }
                break;
            case 3:{
                controller = [[YTUserAgreementViewController alloc]init];
            }
                break;
            case 4:{
                controller = [[YTFeedBackViewController alloc]init];
            }
                break;
        }
    }
    
     [self.navigationController pushViewController:controller animated:YES];
    
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
    NSLog(@"settingDealloc");
}
@end
