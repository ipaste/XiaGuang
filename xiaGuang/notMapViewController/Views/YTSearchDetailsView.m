//
//  YTSearchEntranceView.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-15.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTSearchDetailsView.h"
#import <AVObject.h>
#import <AVQuery.h>
#import "Reachability.h"
#import "YTCloudMerchant.h"
#import "YTResultsViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "YTFileManager.h"
#define HISTORYTABLECELL_HEIGHT 40
@interface YTSearchDetailsView()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
    YTFileManager *_fileManager;
    id<YTMall> _mall;
    UIView *_hotSearchView;
    UILabel *_notLabel;
    UIScrollView *_scrollView;
    UITableView *_searchResultstableView;
    UITableView *_historyTableView;
    NSMutableArray *_results;
    NSArray *_historicalRecord;
    
    NSArray *_popularMerchants;
}
@end
@implementation YTSearchDetailsView
-(id)initWithFrame:(CGRect)frame andDataSourceMall:(id<YTMall>)mall{
    self = [super initWithFrame:frame];
    if (self) {
        _mall = mall;

        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
        _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)+ 10);
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        
        _hotSearchView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.frame), 128)];
        [_hotSearchView addSubview:[self headLabelWithText:@"热门搜索"]];
        
        AVQuery *query = [AVQuery queryWithClassName:@"Merchant"];
        
        query.limit = 6;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            _popularMerchants = [NSArray arrayWithArray:objects];
            
            for (int i = 0 ; i < objects.count; i++) {
                AVObject *object = objects[i];
                id<YTMerchant> merchant = [[YTCloudMerchant alloc]initWithAVObject:object];
                UIButton *hotButton = [[UIButton alloc]initWithFrame:CGRectMake(25  + i % 3 * 95 , 45 + i / 3 * 40, 85, 30)];
                [hotButton setTitle:[merchant shortName] forState:UIControlStateNormal];
                [hotButton setTitleColor:[UIColor colorWithString:@"606060"] forState:UIControlStateNormal];
                [hotButton setBackgroundImage:[UIImage imageNamed:@"search_btn_un"] forState:UIControlStateNormal];
                [hotButton setBackgroundImage:[UIImage imageNamed:@"search_btn_pr"] forState:UIControlStateHighlighted];
                [hotButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
                [hotButton addTarget:self action:@selector(jumpToMerchant:) forControlEvents:UIControlEventTouchUpInside];
                hotButton.tag  = i;
                [_hotSearchView addSubview:hotButton];
            }
        }];
        
        
        
        [_scrollView addSubview:_hotSearchView];
        
        _fileManager = [YTFileManager defaultManager];
        
        _historyTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_hotSearchView.frame), CGRectGetWidth(_scrollView.frame) , _historicalRecord.count * HISTORYTABLECELL_HEIGHT + 35) style:UITableViewStylePlain];
        _historyTableView.backgroundColor = [UIColor clearColor];
        _historyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _historyTableView.delegate = self;
        _historyTableView.dataSource = self;
        _historyTableView.scrollEnabled = NO;
        [_scrollView addSubview:_historyTableView];
        
        _searchResultstableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)) style:UITableViewStylePlain];
        _searchResultstableView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
        _searchResultstableView.delegate = self;
        _searchResultstableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchResultstableView.dataSource = self;
        _searchResultstableView.hidden = YES;
        [self addSubview:_searchResultstableView];
        
        _notLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,100, CGRectGetWidth(_searchResultstableView.frame), 45)];
        _notLabel.font = [UIFont systemFontOfSize:20];
        _notLabel.textColor = [UIColor colorWithString:@"c8c8c8"];
        _notLabel.text = @"无结果";
        _notLabel.textAlignment = 1;
        _notLabel.hidden = YES;
        [_searchResultstableView addSubview:_notLabel];
        self.hidden = YES;
    }
    return self;
    
}
-(void)searchWithKeyword:(NSString *)keyWord{
    if (keyWord.length <= 0) {
        _searchResultstableView.hidden = YES;
        _scrollView.hidden = NO;
        return;
    }
    
    
    //关键字处理
    _scrollView.hidden = YES;
    _searchResultstableView.hidden = NO;
    if (_results != nil) {
        [_results removeAllObjects];
    }
    _results = [NSMutableArray array];
    AVQuery *query = [AVQuery queryWithClassName:@"Merchant"];
    query.limit = 10;
    
    [query includeKey:@"mall,floor.block.mall"];
    if (_mall) {
        AVQuery *mallQuery = [AVQuery queryWithClassName:@"Mall"];
        [mallQuery whereKey:@"name" equalTo:[_mall mallName]];
        [query whereKey:@"mall" equalTo:[mallQuery getFirstObject]];
    }

    [query whereKey:@"name" matchesRegex:keyWord modifiers:@"i"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       
        for (AVObject *merchantObject in objects) {
            YTCloudMerchant *merchant = [[YTCloudMerchant alloc]initWithAVObject:merchantObject];

            [_results addObject:merchant];
        }
        [_searchResultstableView reloadData];
        if (_results.count > 0) {
            _searchResultstableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            _searchResultstableView.separatorColor = [UIColor colorWithString:@"c8c8c8"];
            _notLabel.hidden = YES;
        }else{
            _searchResultstableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            _notLabel.hidden = NO;
        }
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:_historyTableView]) {
        _historicalRecord = [_fileManager readDataWithFileName:@"history"];
        
        CGRect frame = _historyTableView.frame;
        if (_historicalRecord.count > 0) {
            frame.size.height = _historicalRecord.count * HISTORYTABLECELL_HEIGHT + 35;
        }else{
            frame.size.height = 1 * HISTORYTABLECELL_HEIGHT + 35;
        }
        _historyTableView.frame = frame;
        
        if (_historicalRecord.count <= 0) {
            return 1;
        }
        return _historicalRecord.count;
        
    }
    
    return _results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIView *selectedBackgroundView = [[UIView alloc]initWithFrame:CGRectZero];
    selectedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"all_bg_8%black"]];
    
    if ([tableView isEqual:_historyTableView]) {
        UITableViewCell *historycell = [tableView dequeueReusableCellWithIdentifier:@"historyCell"];
        UILabel *label = nil;
        if (!historycell) {
            historycell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"historyCell"];
            label = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, CGRectGetWidth(self.frame) - 25, HISTORYTABLECELL_HEIGHT)];
            historycell.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor colorWithString:@"606060"];
            label.font = [UIFont systemFontOfSize:14];
            historycell.selectedBackgroundView = selectedBackgroundView;
            [historycell addSubview:label];
        }else{
            UIView * view = [historycell.subviews firstObject];
            for (UILabel *textlabel in view.subviews) {
                label = textlabel;
            }
        }
        if (_historicalRecord.count <= 0) {
            label.text = @"暂无历史";
            historycell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else{
            label.text = _historicalRecord[indexPath.row];
        }
        return historycell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        UILabel *label = nil;
        UILabel *subLabel = nil;
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            cell.backgroundColor = [UIColor clearColor];
            
            cell.selectedBackgroundView = selectedBackgroundView;
            label = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, 150, 44)];
            label.textColor = [UIColor colorWithString:@"606060"];
            label.font = [UIFont systemFontOfSize:14];
            label.tag = 0;
            [cell addSubview:label];
            
            subLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label.frame) + 10, CGRectGetMinY(label.frame), CGRectGetWidth(self.frame) - CGRectGetWidth(label.frame), 44)];
            subLabel.textColor = [UIColor colorWithString:@"dcdcdc"];
            subLabel.font = [UIFont systemFontOfSize:12];
            subLabel.textAlignment = 2;
            subLabel.tag = 1;
            [cell addSubview:subLabel];
            
        }else{
            UIView * view = [cell.subviews firstObject];
            for (UIView *tempview in view.subviews) {
                if ([tempview isMemberOfClass:[UILabel class]]) {
                    if (tempview.tag == 0) {
                        label = (UILabel *)tempview;
                    }else if (tempview.tag == 1){
                        subLabel = (UILabel *)tempview;
                    }
                }
            }
        }
        
        id<YTMerchant> merchant = _results[indexPath.row];
        label.text = [merchant merchantName];
        subLabel.text = [NSString stringWithFormat:@"%@ %@ %@",[[merchant floor] floorName],[[[merchant floor] block] blockName],[[merchant mall] mallName]];
        return cell;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:_historyTableView]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UILabel *label = nil;
        UIView * view = [cell.subviews firstObject];
        for (UILabel *textlabel in view.subviews) {
            label = textlabel;
        }
        if ([label.text isEqualToString:@"暂无历史"]) {
            return;
        }
        cell.selected = NO;
        [self.delegate selectSearchResultsWithMerchantnName:label.text];
        
    }else if([tableView isEqual:_searchResultstableView]){
        NSMutableArray *history = [NSMutableArray arrayWithArray:[_fileManager readDataWithFileName:@"history"]];
        
        if (history.count >= 8) {
            [history removeObjectAtIndex:history.count - 1];
        }
        
        if (_results.count > 0) {
            id<YTMerchant> merchant = _results[indexPath.row];
            [history insertObject:[merchant merchantName] atIndex:0];
            [_fileManager saveWithData:history andCreateFileName:@"history"];
            [_historyTableView reloadData];
            _scrollView.hidden = NO;
            _searchResultstableView.hidden = YES;
            [self.delegate selectSearchResultsWithMerchantnName:[merchant merchantName]];
        }
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:_historyTableView]) {
        return HISTORYTABLECELL_HEIGHT;
    }
    return 45;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([tableView isEqual:_historyTableView]) {
        return 35;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ([tableView isEqual:_historyTableView]) {
        UIView *background = [[UIView alloc]init];
        background.backgroundColor = [UIColor clearColor];
        [background addSubview:[self headLabelWithText:@"搜索历史"]];
        return background;
    }
    return nil;
}
-(UIView *)headLabelWithText:(NSString *)text{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, CGRectGetWidth(_scrollView.frame) - 25, 33)];
    label.backgroundColor = [UIColor clearColor];
    
    label.text = text;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor colorWithString:@"e95e37"];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame), CGRectGetWidth(label.frame), 0.5)];
    line.backgroundColor = [UIColor colorWithString:@"e95e37"];
    [label addSubview:line];
    return label;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    [self.delegate cancelSearchInput];
}

-(void)jumpToMerchant:(UIButton *)sender{
    NSInteger index = sender.tag;
    AVObject *tmp = [_popularMerchants objectAtIndex:index];
    NSString *merchantName = tmp[@"name"];
    [self.delegate selectSearchResultsWithMerchantnName:merchantName];
}
@end
