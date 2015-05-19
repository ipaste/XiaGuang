//
//  YTCategoryResultsTableView.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-22.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTCategoryResultsTableView.h"

@interface YTCategoryResultsTableView ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_categoryView;
    UITableView *_subcategoryView;
    UITableView *_mallView;
    UITableView *_floorView;
    YTSelectCategoryViewCell *_curCategoryCell;
    UITableViewCell *_curSubCategoryCell;
    UITableViewCell *_curMallCell;
    UITableViewCell *_curFloorCell;
    NSMutableArray *_categoryObjects;
    NSMutableArray *_mallObjects;
    NSMutableArray *_floorObjects;
    NSMutableArray *_allMall;
    NSMutableArray *_mallNames;
    NSMutableArray *_floorNames;
    NSArray *_subObjects;
    NSString *_Key;
    id<YTMall> _mall;
}
@end

@implementation YTCategoryResultsTableView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _categoryView = [[UITableView alloc]init];
        _categoryView.showsVerticalScrollIndicator = false;
        _mallView = [[UITableView alloc]init];
        _mallView.showsVerticalScrollIndicator = false;
        _floorView = [[UITableView alloc]init];
        _floorView.showsVerticalScrollIndicator = false;
        
        [self addSubview:_floorView];
        [self addSubview:_mallView];
        [self addSubview:_categoryView];

        
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;
        _allMall = [NSMutableArray array];
        FMDatabase *db = [YTDataManager defaultDataManager].database;
        FMResultSet *result = [db executeQuery:@"select * from Mall"];
        while ([result next]) {
            YTLocalMall *tmpMall = [[YTLocalMall alloc]initWithDBResultSet:result];
            [_allMall addObject:tmpMall];
            
        }
    }
    return self;
}

-(void)layoutSubviews{
    _categoryView.backgroundColor = [UIColor whiteColor];

    self.layer.masksToBounds = YES;
}

-(void)setShowStyle:(YTCategoryResultsStyle)style malllocalId:(NSString *)localId key:(NSString *)key{
    self.hidden = NO;
    __block CGRect frame = self.frame;
    frame.size.height = 0;
    self.frame = frame;
    
    _style = style;
    _Key = key;
    __block CGFloat height = 0;
    if (style == YTCategoryResultsStyleAllCategory) {
        _mallView.hidden = YES;
        _floorView.hidden = YES;
        _categoryView.hidden = NO;
        _categoryView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame) / 2,8 * 44);
        height = CGRectGetHeight(_categoryView.frame);
        _categoryView.delegate = self;
        _categoryView.dataSource = self;
        _mallView.delegate = nil;
        _mallView.dataSource = nil;
        _categoryObjects = [NSMutableArray arrayWithArray:[YTCategory newAllCategorys]];
        [_categoryView reloadData];
    }else if (style == YTCategoryResultsStyleAllFloor){
        _categoryView.hidden = YES;
        _floorView.hidden = NO;
        _subcategoryView.hidden = YES;
        _mallView.hidden = YES;
        _mallView.delegate = nil;
        _mallView.dataSource = nil;
        _categoryView.delegate = nil;
        _categoryView.dataSource = nil;
        _floorView.delegate = self;
        _floorView.dataSource = self;
        _subcategoryView.delegate = nil;
        _subcategoryView.dataSource = nil;
        _floorObjects = [NSMutableArray array];
        _floorNames = [NSMutableArray array];
        [_floorNames addObject:@"全部楼层"];
        [_floorObjects addObject:[NSNull null]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.identifier == %@",localId];
        id<YTMall> mall =  [_allMall filteredArrayUsingPredicate:predicate].firstObject;
        
        [[mall blocks] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            for (id<YTFloor> floor in [obj floors]) {
                [_floorNames addObject:[floor floorName]];
                [_floorObjects addObject:floor];
            }
            if (idx == [mall blocks].count - 1){
                height = 44 * _floorObjects.count >  5 * 44 + 22 ?  5 * 44 + 22:44 * _floorObjects.count;
                _floorView.frame = CGRectMake(CGRectGetWidth(self.bounds) / 2, 0, CGRectGetWidth(self.bounds) / 2, height);
                [_floorView reloadData];
            }
        }];
    
    }else if (style == YTCategoryResultsStyleAllMall){
        _mallView.hidden = NO;
        _floorView.hidden = YES;
        _categoryView.hidden = YES;
        _categoryView.delegate = nil;
        _categoryView.dataSource = nil;
        _mallView.delegate = self;
        _mallView.dataSource = self;
        _floorView.delegate = nil;
        _floorView.dataSource = nil;
        _mallObjects = [NSMutableArray array];
        _mallNames = [NSMutableArray array];
        for (id <YTMall> mall in _allMall) {
            [_mallNames addObject:[mall mallName]];
            [_mallObjects addObject:mall];
        }
        [_mallNames insertObject:@"全部商圈" atIndex:0];
        [_mallObjects insertObject:[NSNull null] atIndex:0];
        height = 44 * _mallObjects.count >  5 * 44 + 22 ?  5 * 44 + 22:44 * _mallObjects.count;
        _mallView.frame = CGRectMake(CGRectGetWidth(self.bounds) / 2, 0, CGRectGetWidth(self.bounds) / 2, height);
        [_mallView reloadData];
    }
    [UIView animateWithDuration:.5 animations:^{
        frame.size.height = height;
        self.frame = frame;
    }];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:_categoryView]) {
        return _categoryObjects.count;
    }
    if ([tableView isEqual:_mallView]) {
        return _mallObjects.count;
    }
    return _floorObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:_categoryView]) {
        YTSelectCategoryViewCell *cell = [[YTSelectCategoryViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CategoryCell"];
        cell.category = _categoryObjects[indexPath.row];
        cell.isSelect = NO;
        NSString *categoryKey = _Key;
        if ([cell.category.text isEqualToString:categoryKey]) {
            cell.isSelect = YES;
            _curCategoryCell = cell;
        }
        return cell;
    }
    
    if ([tableView isEqual:_mallView]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MallCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MallCell"];
            cell.textLabel.textColor = [UIColor colorWithString:@"404040"];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textAlignment = 1;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        
        cell.textLabel.text = _mallNames[indexPath.row];
        if ([cell.textLabel.text isEqualToString:_Key]) {
            cell.textLabel.textColor = [UIColor colorWithString:@"e95e37"];
            _curMallCell = cell;
            
        }
        return cell;
    }
    if ([tableView isEqual:_floorView]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FloorCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FloorCell"];
            cell.textLabel.textColor = [UIColor colorWithString:@"404040"];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textAlignment = 1;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        
        cell.textLabel.text = _floorNames[indexPath.row];
        if ([cell.textLabel.text isEqualToString:_Key]) {
            cell.textLabel.textColor = [UIColor colorWithString:@"e95e37"];
            _curFloorCell = cell;
        }
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:_categoryView]) {
        _curCategoryCell.isSelect = NO;
        YTSelectCategoryViewCell *cell = (YTSelectCategoryViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.isSelect = YES;
        _curCategoryCell = cell;
        YTCategory *category = _categoryObjects[indexPath.row];
        [self.delegate selectKey:category.text];
    }
    
    if ([tableView isEqual:_mallView]) {
        _curMallCell.textLabel.textColor = [UIColor colorWithString:@"404040"];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.textColor = [UIColor colorWithString:@"e95e37"];
        _curMallCell = cell;
        
        NSString *localDBId = nil;
        id<YTMall> tmpMall = _mallObjects[indexPath.row];
        if (![tmpMall isMemberOfClass:[NSNull class]]) {
            localDBId = [tmpMall identifier];
        }
        [self.delegate selectKey:localDBId];
    }
    
    if ([tableView isEqual:_floorView]) {
        _curFloorCell.textLabel.textColor = [UIColor colorWithString:@"404040"];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.textColor = [UIColor colorWithString:@"e95e37"];
        _curFloorCell = cell;
        NSString *floorUniId = nil;
        id<YTFloor> tmpFloor = _floorObjects[indexPath.row];
        if (![tmpFloor isMemberOfClass:[NSNull class]]) {
            floorUniId = [tmpFloor uniId];
        }
        [self.delegate selectKey:floorUniId];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
@end
