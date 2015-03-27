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
        _subcategoryView = [[UITableView alloc]init];
        _mallView = [[UITableView alloc]init];
        _floorView = [[UITableView alloc]init];
        
        [self addSubview:_floorView];
        [self addSubview:_mallView];
        [self addSubview:_categoryView];
        [self addSubview:_subcategoryView];
        
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;
        _allMall = [NSMutableArray array];
        FMDatabase *db = [YTStaticResourceManager sharedManager].db;
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
    _subcategoryView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"type_img_rightlist"]];
    self.layer.masksToBounds = YES;
}

-(void)setShowStyle:(YTCategoryResultsStyle)style mallName:(NSString *)mallName key:(NSString *)key{
    self.hidden = NO;
   __block CGRect frame = self.frame;
    frame.size.height = 0;
    self.frame = frame;
    
    _style = style;
    _Key = key;
    CGFloat height = 0;
    if (style == YTCategoryResultsStyleAllCategory) {
        _mallView.hidden = YES;
        _floorView.hidden = YES;
        _categoryView.hidden = NO;
        _subcategoryView.hidden = NO;
        _subcategoryView.delegate = self;
        _subcategoryView.dataSource = self;
        _categoryView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame) / 2, 5 * 44 + 22);
        height = CGRectGetHeight(_categoryView.frame);
        _categoryView.delegate = self;
        _categoryView.dataSource = self;
        _mallView.delegate = nil;
        _mallView.dataSource = nil;
        _subcategoryView.frame = CGRectMake(CGRectGetMaxX(_categoryView.frame), 0, CGRectGetWidth(_categoryView.frame), CGRectGetHeight(_categoryView.frame));
        _subcategoryView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _categoryObjects = [NSMutableArray arrayWithArray:[YTCategory allCategorys]];
        [_categoryObjects insertObject:[YTCategory moreCategory] atIndex:0];
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
        for (id<YTMall> mall in _allMall) {
            
            if ([[mall mallName] isEqualToString:mallName]) {
                
                for(id<YTBlock> block in [mall blocks]){
                    
                    for (id<YTFloor> floor in [block floors]) {
                        [_floorNames addObject:[floor floorName]];
                        [_floorObjects addObject:floor];
                    }
                }

            }
             
            
            
        }
        height = 44 * _floorObjects.count >  5 * 44 + 22 ?  5 * 44 + 22:44 * _floorObjects.count;
        _floorView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), height);
        [_floorView reloadData];

    }else if (style == YTCategoryResultsStyleAllMall){
        _mallView.hidden = NO;
        _floorView.hidden = YES;
        _categoryView.hidden = YES;
        _subcategoryView.hidden = YES;
        
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
        _mallView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), height);
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
    if ([tableView isEqual:_subcategoryView]) {
        return _subObjects.count;
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
        NSString *categoryKey = [[_Key componentsSeparatedByString:@"-"] lastObject];
        if ([cell.category.text isEqualToString:categoryKey]) {
            cell.isSelect = YES;
            _curCategoryCell = cell;
            if(![categoryKey isEqualToString:@"全部分类"]){
                _subObjects = cell.category.subText;
            
            }else{
                _subObjects = nil;
            }
            [_subcategoryView reloadData];
        }
        return cell;
    }
    
    if ([tableView isEqual:_subcategoryView]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SubCell"];
            
            cell.textLabel.textColor = [UIColor colorWithString:@"404040"];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        cell.textLabel.text = _subObjects[indexPath.row];
        NSString *category = [[_Key componentsSeparatedByString:@"-"] lastObject];
        NSString *subCategory = [[_Key componentsSeparatedByString:@"-"] firstObject];
        if ([cell.textLabel.text isEqualToString:subCategory]) {
            if ([category isEqualToString:_curCategoryCell.category.text]) {
                cell.textLabel.textColor = [UIColor colorWithString:@"e95e37"];
                _curSubCategoryCell = cell;
            }
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
    if ([tableView isEqual:_categoryView] && indexPath.row != 0) {
        _curSubCategoryCell.textLabel.textColor = [UIColor colorWithString:@"404040"];
        _curCategoryCell.isSelect = NO;
        YTSelectCategoryViewCell *cell = (YTSelectCategoryViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.isSelect = YES;
        _curCategoryCell = cell;
        _subObjects = cell.category.subText;
        [_subcategoryView reloadData];
    }else if ([tableView isEqual:_categoryView] && indexPath.row == 0){
        _curSubCategoryCell.textLabel.textColor = [UIColor colorWithString:@"404040"];
        _curCategoryCell.isSelect = NO;
        YTSelectCategoryViewCell *cell = (YTSelectCategoryViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.isSelect = YES;
        _curCategoryCell = cell;

        [self.delegate selectKey:cell.category.text];
    }
    
    if ([tableView isEqual:_subcategoryView]) {
        _curSubCategoryCell.textLabel.textColor = [UIColor colorWithString:@"404040"];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.textColor = [UIColor colorWithString:@"e95e37"];
        _curSubCategoryCell = cell;
        NSString *key = [NSString stringWithFormat:@"%@-%@",cell.textLabel.text,_curCategoryCell.category.text];
        
        [self.delegate selectKey:key];
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
