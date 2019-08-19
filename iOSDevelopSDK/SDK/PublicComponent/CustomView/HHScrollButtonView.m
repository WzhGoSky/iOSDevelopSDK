//
//  HHScrollButtonView.m
//  HHForAppStore
//
//  Created by Hayder on 2018/3/28.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHScrollButtonView.h"
#import "globalDefine.h"
#import "UIView+HHAdditions.h"

@interface HHScrollButtonView()

/**
 按钮组件的标题数组
 */
@property (nonatomic, strong) NSArray *titles;
/**
 内容数组，与标题数组对应
 */
@property (nonatomic, strong) NSArray<UIView *> *contents;

/**
 滑块
 */
@property (nonatomic, strong) UIView *sliderLine;

/**
 标题View
 */
@property (nonatomic, strong) UIView *titleView;

/**
 上一个点击的按钮
 */
@property (nonatomic, strong) UIButton *lastBtn;

/**
 是否要进行动画
 */
@property (nonatomic, assign) BOOL animated;

@end

@implementation HHScrollButtonView


- (instancetype)initWithFrame:(CGRect)frame Titles:(NSArray <NSString *>*) titles Contents:(NSArray <UIView *>*)contents
{
    if (self = [super initWithFrame:frame]) {
        
        self.titles = titles;
        self.contents = contents;
        
        self.animated = YES;
        
        if (self.titles.count == self.contents.count) {
            [self setUpUI];
            
            UIButton *btn = [self getTitleButtonWithIndex:1];
            [self scrollButtonAction:btn];
        }
    }
    
    return self;
}

/**
 当前按钮所点击的位置
 */
- (NSInteger)currentClickindex
{
    return (NSInteger)(self.contentView.contentOffset.x / SCREEN_WIDTH) + 1;
}

#pragma mark -------------Event Response-------------------
- (void)scrollButtonAction:(UIButton *)button
{
    if (self.lastBtn == button) {
        return;
    }
    
    NSInteger index = button.tag - 1;
    if (self.animated) {
        [self.contentView setContentOffset:CGPointMake(SCREEN_WIDTH * index, 0) animated:YES];
    }else
    {
        [self.contentView setContentOffset:CGPointMake(SCREEN_WIDTH * index, 0) animated:NO];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.sliderLine.left = index * (SCREEN_WIDTH/self.titles.count);
    }];
    
    button.selected = YES;
    self.lastBtn.selected = NO;
    self.lastBtn = button;
    
    if ([self.delegate respondsToSelector:@selector(scrollButtonView:didClickButton:contentView:)]) {
        
        [self.delegate scrollButtonView:self didClickButton:button contentView:self.contentView];
    }
}

- (void)setUpUI
{

    //1.创建标题
    [self createTitleButtonView];
    
    //2.创建contentView
    [self createContentView];
}

- (void)createTitleButtonView
{
    CGFloat titleWidth = SCREEN_WIDTH / self.titles.count;
    
    self.titleView = [[UIView alloc] init];
    self.titleView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    [self addSubview:self.titleView];
    NSInteger index = 1;
    for (NSString *title in self.titles) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:17.f];
        [button setTitle:title forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:kThemeColor forState:UIControlStateSelected];
        [button addTarget:self action:@selector(scrollButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = index;
        button.frame = CGRectMake((index-1)*titleWidth, 0, titleWidth, self.titleView.height);
        [self.titleView addSubview:button];
        index ++;
    }
    self.sliderLine.frame = CGRectMake(0, self.titleView.height-2, titleWidth, 2);
    self.sliderLine.tag = 100;
    [self.titleView addSubview:self.sliderLine];
}

- (void)createContentView
{
    self.contentView.frame = CGRectMake(0, CGRectGetMaxY(self.titleView.frame), SCREEN_WIDTH, self.height - CGRectGetMaxY(self.titleView.frame));
    [self addSubview:self.contentView];
    self.contentView.contentSize = CGSizeMake(self.titles.count * SCREEN_WIDTH, self.contentView.height);
    
    NSInteger index = 1;
    for (UIView *view in self.contents) {
        view.tag = index;
        view.frame = CGRectMake((index-1)*SCREEN_WIDTH, 0, SCREEN_WIDTH, self.contentView.height);
        [self.contentView addSubview:view];
        index++;
    }
}

/**
 设置scrollView滚动到第几个View
 
 @param index 从1开始
 */
- (void)setContentViewScrollViewToIndexView:(NSInteger)index animated:(BOOL) animated
{
    if ([[self.titleView viewWithTag:index] isKindOfClass:[UIButton class]]) {
        self.animated = animated;
        UIButton *button = (UIButton *)[self.titleView viewWithTag:index];
        [self scrollButtonAction:button];
    }
}

- (void)setLineToIndex:(NSInteger)index
{

    [self scrollButtonAction:self.lastBtn];
}

#pragma mark -------------Public Func-------------------
- (UIButton *)getTitleButtonWithIndex:(NSInteger)index
{
    UIButton *button =  (UIButton *)[self.titleView viewWithTag:index];
    return button;
}

#pragma mark -------------setter,getter-------------------
- (void)setButtonBGColor:(UIColor *)buttonBGColor
{
    _buttonBGColor = buttonBGColor;
    
    self.titleView.backgroundColor = buttonBGColor;
    
    for (UIView *view in self.titleView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            view.backgroundColor = buttonBGColor;
        }
    }
}

- (UIView *)sliderLine
{
    if (!_sliderLine) {
        
        _sliderLine = [[UIView alloc] init];
        _sliderLine.backgroundColor = kThemeColor;
    }
    
    return _sliderLine;
}

- (UIScrollView *)contentView
{
    if(!_contentView)
    {
        _contentView = [[UIScrollView alloc] init];
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.scrollEnabled = NO;
    }
    return _contentView;
}

@end
