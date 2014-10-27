//
//  YTFeedBackViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-28.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTFeedBackViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
@interface YTFeedBackViewController ()<UITextViewDelegate>{
    UITextView *_textView;
}
@end

@implementation YTFeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_1"]];
    self.navigationItem.title = @"意见反馈";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(sender)];
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.view.frame), 160)];
    _textView.textColor = [UIColor colorWithString:@"909090"];
    _textView.layer.borderWidth = 0.5;
    _textView.layer.borderColor = [UIColor colorWithString:@"dcdcdc"].CGColor;
    _textView.font = [UIFont systemFontOfSize:14];
    _textView.text = @"写写您使用感受和建议...";
    _textView.delegate = self;
    _textView.textContainerInset = UIEdgeInsetsMake(15, 15, 0, 15);
    [self.view addSubview:_textView];
    self.automaticallyAdjustsScrollViewInsets = NO;
   
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSRange range;
    range.location = 0;
    range.length = 0;
    _textView.selectedRange = range;
     [_textView becomeFirstResponder];

}

- (void)sender{
    
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    if ([textView.text rangeOfString:@"写写您使用感受和建议..."].length > 0) {
        textView.text = @"";
        _textView.textColor = [UIColor colorWithString:@"202020"];
    }
//    if(textView.text.length <= 0 && text.length <= 0 ){
//        textView.text = @"写写您使用感受和建议...";
//        _textView.textColor = [UIColor colorWithString:@"909090"];
//    }
    
    return YES;
}
@end
