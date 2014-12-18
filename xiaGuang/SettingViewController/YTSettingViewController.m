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
#import <POP.h>
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
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setBackgroundColor:[UIColor clearColor]];
    _tableView.separatorColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    [self.view addSubview:_tableView];
    self.navigationItem.title = @"设置";
}

-(void)viewWillLayoutSubviews{
    CGFloat topHeight = [self.topLayoutGuide length];
    CGRect frame = _tableView.frame;
    frame.origin.y = topHeight;
    frame.size.height = CGRectGetHeight(self.view.bounds) - topHeight;
    _tableView.frame = frame;
    

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            
            return 0;
        case 1:
            
            return 2;
        case 2:
            
            return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    [cell pop_animationForKey:@"show"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    UIView *selectView = [[UIView alloc]initWithFrame:CGRectZero];
    [selectView setBackgroundColor:[UIColor colorWithString:@"e95e37"]];
    cell.selectedBackgroundView = selectView;
    cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    //cellAnimation
    if (_isShowAnimation) {
        _duration += 0.2;
        POPBasicAnimation *showAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        showAnimation.fromValue = [NSNumber numberWithFloat:CGRectGetWidth(tableView.frame)];
        showAnimation.toValue = [NSNumber numberWithFloat:CGRectGetWidth(tableView.frame) / 2];
        showAnimation.duration = _duration;
        //showAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [cell.layer pop_addAnimation:showAnimation forKey:@"show"];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = @"邀请好友使用虾逛";
        cell.imageView.image = [UIImage imageNamed:@"set_ico_1"];
    }else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"给虾逛评分";
                cell.imageView.image = [UIImage imageNamed:@"set_ico_2"];
                break;
            case 1:
                cell.textLabel.text = @"意见反馈";
                cell.imageView.image = [UIImage imageNamed:@"set_ico_3"];
                break;
        }
    }else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
            {
                cell.textLabel.text = @"版本更新";
                cell.imageView.image = [UIImage imageNamed:@"set_ico_4"];
                if (!self.isLatest) {
                    UIButton *latestBtn  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 20)];
                    latestBtn.center = CGPointMake(CGRectGetWidth(self.view.frame) - 50, 22);
                    [latestBtn setTitle:@"新版本" forState:UIControlStateNormal];
                    [latestBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
                    [latestBtn setTitleColor:[UIColor colorWithString:@"ffffff"] forState:UIControlStateNormal];
                    [latestBtn setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
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
                cell.imageView.image = [UIImage imageNamed:@"set_ico_5"];
                break;
            case 2:
                cell.textLabel.text = @"用户协议";
                cell.imageView.image = [UIImage imageNamed:@"set_ico_6"];
                _isShowAnimation = NO;
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
    if (indexPath.section == 0) {
        controller = [[YTInvitationViewController alloc]init];
    }else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
            {
                NSString *url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d",922405498];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                 return;
            }
               
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
                    NSString *url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d",922405498];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
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
    
     [self.navigationController pushViewController:controller animated:YES];
    
}


-(void)dealloc{
    for (UITableViewCell *tmpCell in [_tableView visibleCells]) {
        [tmpCell pop_removeAllAnimations];
    }
    NSLog(@"settingDealloc");
}
@end
