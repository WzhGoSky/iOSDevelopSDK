//
//  HHTitleScrollController.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/4/26.
//  Copyright © 2019 iOSDevelopSDK. All rights reserved.
//

#import "HHTitleScrollController.h"
#import "globalDefine.h"
#import "UIView+HHAdditions.h"

@interface HHTitleScrollController ()

@end

@implementation HHTitleScrollController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.titleView];
    [self.view addSubview:self.contentView];
    
    self.automaticallyAdjustsScrollViewInsets = false;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSUInteger index = scrollView.contentOffset.x/SCREEN_WIDTH;
    NSUInteger tag = index+1;
    
    UIButton *button = [self.titleView viewWithTag:tag];
    [self clickButton:button];
    
    [self.titleView setContentOffset:CGPointMake(index*SCREEN_WIDTH/6, 0) animated:YES];
    
    [self.view endEditing:YES];
}

- (void)clickButton:(UIButton *)button
{
    if (self.lastBtn == button) {
        return;
    }
    NSInteger index = button.tag-1;
    CGFloat x = (SCREEN_WIDTH/4-30)/2;
    self.line.left = x+index*(SCREEN_WIDTH/4);
    [self.contentView setContentOffset:CGPointMake(SCREEN_WIDTH*index, 0) animated:YES];
    
    button.selected = YES;
    self.lastBtn.selected = NO;
    self.lastBtn = button;
}

- (void)setTitleSource:(NSArray *)titleSource
{
    _titleSource = titleSource;
    
    CGFloat w = SCREEN_WIDTH/4;
    for (int i=0; i<self.titleSource.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:self.titleSource[i] forState:UIControlStateNormal];
        button.tag = i+1;
        
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:ColorHexString(@"999999") forState:UIControlStateNormal];
        [button setTitleColor:kThemeColor forState:UIControlStateSelected];
        button.frame = CGRectMake(i*w, 0, w, 40);
        [_titleView addSubview:button];
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i==0) {
            button.selected = YES;
            self.lastBtn = button;
        }
    }
    
    _titleView.contentSize = CGSizeMake(w*self.titleSource.count, 0);
    _contentView.contentSize = CGSizeMake(SCREEN_WIDTH*self.titleSource.count, 0);
}

- (UIScrollView *)titleView
{
    if (!_titleView) {
        
        _titleView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.navBarHeight, SCREEN_WIDTH, 40)];
        _titleView.showsHorizontalScrollIndicator = NO;
        [_titleView addSubview:self.line];
    }
    
    return _titleView;
}


- (UIScrollView *)contentView
{
    if (!_contentView) {
        
        CGFloat safeHeight = KIsFullPhone?30:0;
        _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.titleView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT - self.titleView.bottom-safeHeight)];
        _contentView.pagingEnabled = YES;
        _contentView.delegate = self;
        _contentView.bounces = NO;
        _contentView.showsHorizontalScrollIndicator = NO;
    }
    return _contentView;
}

- (UIView *)line
{
    if (!_line) {
        
        CGFloat x = (SCREEN_WIDTH/4-30)/2;
        _line = [[UIView alloc] initWithFrame:CGRectMake(x, 37, 30, 3)];
        _line.backgroundColor = kThemeColor;
    }
    
    return _line;
}



@end
