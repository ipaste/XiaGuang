//
//  YTFloorView.m
//  High逛
//
//  Created by Ke ZhuoPeng on 14-8-14.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTFloorView.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#define CELLIDENTIFIER @"FloorCell"
@interface YTFloorView()<UITableViewDelegate,UITableViewDataSource>{
    id<YTMall> _relevantMall;
    NSMutableArray *_items;
    CGFloat _width_height;
    UIButton *_currentButton;
    NSMutableArray *_buttons;
}
@end
@implementation YTFloorView
-(id)initWithFrame:(CGRect)frame andItem:(NSArray *)item{
    _items = [NSMutableArray arrayWithArray:item];
    _buttons = [NSMutableArray array];
    _width_height = frame.size.width;
    
    return [self initWithFrame:frame style:UITableViewStylePlain];
}

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        //self.backgroundColor = [UIColor colorWithString:@"444547"];
        self.backgroundColor = [UIColor clearColor];
        self.showsVerticalScrollIndicator = NO;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}
-(void)setFrame:(CGRect)frame{
    if (frame.size.height != 0) {
        if (_items.count > 3) {
            frame.size.height = (_width_height * 3) + _width_height;
        }else{
            frame.size.height = _width_height * _items.count;
        }
    }
    frame.size.height -= 10;
    [super setFrame:frame];
    
}
-(void)setCurFloor:(id<YTFloor>)curFloor{
    if (_buttons.count > 0) {
        for (UIButton *button in _buttons) {
            if ([button.titleLabel.text isEqualToString:[curFloor floorName]]) {
                [self setCurButton:button];
            }
        }
    }
    _curFloor = curFloor;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFIER];
    UIButton *button = nil;
    if (cell == nil ) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELLIDENTIFIER];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _width_height, _width_height)];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button addTarget:self action:@selector(floorButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
        [_buttons addObject:button];
    }else{
        UIView *view = [cell.subviews firstObject];
        for (UIView *buttonView in view.subviews) {
            if ([buttonView isMemberOfClass:[UIButton class]]) {
                button = (UIButton *)buttonView;
            }
        }
    }
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    id <YTFloor> floor = _items[indexPath.row] ;
    [button setTitle:[floor floorName] forState:UIControlStateNormal];
    if ([button.titleLabel.text isEqualToString:[self.curFloor floorName]]) {
        [self setCurButton:button];
    }
    return cell;
}

-(void)floorButtonClick:(UIButton *)sender{
    [self setCurButton:sender];
    for (id <YTFloor> floor in _items) {
        if ([[floor floorName] isEqualToString:sender.titleLabel.text]) {
            [self.floorDelegate floorView:self clickButtonAtFloor:floor];
        }
    }
}
-(void)setCurButton:(UIButton *)sender{
    [_currentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    _currentButton = sender;
}
@end
