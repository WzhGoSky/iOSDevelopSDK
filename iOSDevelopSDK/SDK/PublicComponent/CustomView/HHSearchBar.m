//
//  HHSearchBar.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/3/28.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHSearchBar.h"
#import "UIView+HHAdditions.h"

@interface HHSearchBar()
/**
 发送搜索数据的定时器
 */
@property (nonatomic, strong) NSTimer *sendEditingTextTimer;

@end

@implementation HHSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 设置背景
        self.backgroundColor = [UIColor whiteColor];
        
        // 设置内容 -- 垂直居中
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        // 设置左边显示一个放大镜
        UIImageView *leftView = [[UIImageView alloc] init];
        leftView.image = [UIImage imageNamed:@"ico_search"];
        leftView.width = leftView.image.size.width + 10;
        leftView.height = leftView.image.size.height+5;
        // 设置leftView的内容居中
        leftView.contentMode = UIViewContentModeCenter;
        self.leftView = leftView;
        self.font = [UIFont systemFontOfSize:15.f];
        // 设置左边的view永远显示
        self.leftViewMode = UITextFieldViewModeAlways;
        
        // 设置右边永远显示清除按钮
        self.clearButtonMode = UITextFieldViewModeAlways;
        
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
        [self addTarget:self action:@selector(editingEvent:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

//开始输入
- (void)editingEvent:(id)sender
{
    if ([self.nDelegate respondsToSelector:@selector(searchBar:didEndEditingNoDealy:)]) {
        [self.nDelegate searchBar:self didEndEditingNoDealy:self.text];
    }
    
    [self removeTimer];
    [self addTimer];
}

- (void)sendEditingText:(NSTimer *)timer
{
    if ([self.nDelegate respondsToSelector:@selector(searchBar:didEndEditing:)]) {
        
        [self.nDelegate searchBar:self didEndEditing:self.text];
    }
    [self removeTimer];
}


#pragma mark ---------------------timer-----------------------------------------
- (void)addTimer
{
    self.sendEditingTextTimer = [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(sendEditingText:) userInfo:nil repeats:YES];
    
}
- (void)removeTimer
{
    [self.sendEditingTextTimer invalidate];
    self.sendEditingTextTimer = nil;
}

+ (instancetype)searchBar
{
    return [[self alloc] init];
}

- (void)dealloc
{
    [self removeTimer];
}

@end
