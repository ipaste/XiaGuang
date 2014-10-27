//
//  YTSettingViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-28.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTSettingViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "YTUserAgreementViewController.h"
#import "YTInvitationViewController.h"
#import "YTAboutViewController.h"
#import "YTFeedBackViewController.h"
@interface YTSettingViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
}
@end

@implementation YTSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_1"]];
    _tableView.separatorColor = [UIColor colorWithString:@"dcdcdc"];
    [self.view addSubview:_tableView];
    self.navigationItem.title = @"设置";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            
            return 1;
        case 1:
            
            return 2;
        case 2:
            
            return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    UIView *selectView = [[UIView alloc]initWithFrame:CGRectZero];
    selectView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_2_pr"]];
    cell.selectedBackgroundView = selectView;
    cell.textLabel.textColor = [UIColor colorWithString:@"202020"];
    if (indexPath.section == 0) {
        cell.textLabel.text = @"邀请好友使用虾逛";
    }else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"给虾逛评分";
                break;
            case 1:
                cell.textLabel.text = @"意见反馈";
                break;
        }
    }else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
            {
                cell.textLabel.text = @"版本更新";
                if (!self.isLatest) {
                    UIButton *latestBtn  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 20)];
                    latestBtn.center = CGPointMake(CGRectGetWidth(self.view.frame) - 50, 22);
                    [latestBtn setTitle:@"新版本" forState:UIControlStateNormal];
                    [latestBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
                    [latestBtn setTitleColor:[UIColor colorWithString:@"ffffff"] forState:UIControlStateNormal];
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
                cell.textLabel.text = @"关于虾逛";
                break;
            case 2:
                cell.textLabel.text = @"用户协议";
                break;
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 19   ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIViewController *controller = nil;
    if (indexPath.section == 0) {
        controller = [[YTInvitationViewController alloc]init];
    }else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"给虾逛评分";
                break;
            case 1:
            {
               controller = [[YTFeedBackViewController alloc]init];
                break;
            }
              
        }
    }else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
            {
                cell.textLabel.text = @"版本更新";
                if (!self.isLatest) {
                    //跳转AppStore
                }else{
                    return;
                }
                
            }
                break;
            case 1:
            {
                controller = [[YTAboutViewController alloc]init];
            }
                break;
            case 2:
            {
                controller = [[YTUserAgreementViewController alloc]init];
               
            }
                break;
        }
    }
     cell.selected = NO;
     [self.navigationController pushViewController:controller animated:YES];
    
}

-(void)dealloc{
    NSLog(@"settingDealloc");
}
@end
