//
//  HHVideoEditTopFuncView.m
//  Test
//
//  Created by Hayder on 2018/7/25.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHVideoEditTopFuncView.h"
#import "UIView+HHAdditions.h"
#import "globalDefine.h"

@interface HHVideoEditTopFuncView ()
// 容器视图
@property (strong, nonatomic) UIView *containerView;

// 取消按钮
@property (strong, nonatomic) UIButton *cancelBtn;

// 完成按钮
@property (strong, nonatomic) UIButton *completeBtn;

@end

@implementation HHVideoEditTopFuncView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
    }
    
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.containerView.frame = self.bounds;
    
    self.cancelBtn.frame = CGRectMake(10, 0, 70, 44);
    
    self.completeBtn.frame = CGRectMake(self.containerView.width - 10 - 70, 0, 70, 44);
}

#pragma mark - private func
- (void)setupUI {
    
    // 容器视图
    self.containerView = [[UIView alloc] init];
    [self addSubview:self.containerView];
    
    // 取消按钮
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(onCancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.cancelBtn];
    
    // 完成按钮
    self.completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.completeBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.completeBtn addTarget:self action:@selector(onCompleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.completeBtn];
}

#pragma mark - event respond
- (void)onCancelBtnClick {
    
    if (self.cancelBlock) {
        
        self.cancelBlock();
    }
}

- (void)onCompleteBtnClick {
    
    if (self.completeBlock) {
        
        self.completeBlock();
    }
}

@end
