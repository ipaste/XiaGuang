//
//  YTFeedBackViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-28.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTFeedBackViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"

#define STRING_VALUE @"有什么想说的，尽管来吐槽吧~"
@interface YTFeedBackViewController ()<UITextViewDelegate>{
    UITextView *_textView;
    BOOL _isSend;
}
@end

@implementation YTFeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
    backgroundView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
    [self.view addSubview:backgroundView];
    self.navigationItem.title = @"意见反馈";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(sender)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButton]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithString:@"e65e37"] forKey:NSForegroundColorAttributeName]];
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame) + 10, CGRectGetWidth(self.view.frame), 160)];
    _textView.textColor = [UIColor colorWithString:@"909090"];
    _textView.layer.borderWidth = 0.5;
    _textView.userInteractionEnabled = NO;
    _textView.layer.borderColor = [UIColor colorWithString:@"dcdcdc"].CGColor;
    _textView.font = [UIFont systemFontOfSize:14];
    _textView.text = STRING_VALUE;
    _textView.delegate = self;
    _textView.textContainerInset = UIEdgeInsetsMake(15, 15, 0, 15);
    [self.view addSubview:_textView];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)sender{
    if (!_isSend) {
        return;
    }
    AVObject *feedBack = [[AVObject alloc] initWithClassName:@"Feedback"];
    [feedBack setObject:_textView.text forKey:@"feedBack"];
    [feedBack saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            NSLog(@"error uploading feedback");
        }
        else{
            NSLog(@"successfully uploaded feedback");
        }
    }];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *tmpTouch = [touches anyObject];
    CGPoint clickToPoint = [tmpTouch locationInView:self.view];
    if (CGRectContainsPoint(_textView.frame, clickToPoint) && !_textView.isFirstResponder) {
        NSRange tmpRange;
        tmpRange.length = 0;
        tmpRange.location = 0;
        _textView.selectedRange = tmpRange;
        [_textView becomeFirstResponder];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    _textView.userInteractionEnabled = YES;
    if ([textView.text rangeOfString:STRING_VALUE].length > 0) {
        _isSend = YES;
        textView.text = @"";
        _textView.textColor = [UIColor colorWithString:@"202020"];
    }
    
    return YES;
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
    _textView.delegate = nil;
    [_textView resignFirstResponder];
    [_textView removeFromSuperview];
    
    NSLog(@"feedBack dealloc");
}
@end
