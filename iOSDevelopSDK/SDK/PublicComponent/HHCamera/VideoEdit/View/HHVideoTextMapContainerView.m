//
//  HHVideoTextMapContainerView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/7/30.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHVideoTextMapContainerView.h"
#import "HHVideoEditTopFuncView.h"
#import "UIView+HHAdditions.h"
#import "globalDefine.h"

@interface HHVideoTextMapContainerView ()

// 头部完成，取消按钮
@property (strong, nonatomic) HHVideoEditTopFuncView *topFuncView;

// 中间文字输入框
@property (strong, nonatomic) UITextView *textInputView;

// 底部颜色选择的容器视图
@property (strong, nonatomic) UIView *bottomColorSelectContainerView;

// 当前选中的颜色按钮
@property (strong, nonatomic) UIButton *currentSelectColorBtn;

// 可选的颜色数组
@property (strong, nonatomic) NSArray <UIColor *> *availableColors;



// 传过来的文字贴图界面
@property (strong, nonatomic) HHVideoTextMapShowContainerView *textMapShowView;

@end

@implementation HHVideoTextMapContainerView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.textInputView.height = self.height - self.textInputView.top - self.bottomColorSelectContainerView.height - 10;
    
    self.bottomColorSelectContainerView.top = self.height - self.bottomColorSelectContainerView.height;
}

#pragma mark - event respond
- (void)onColorSelectBtnClick:(UIButton *)btn {
    
    if (self.currentSelectColorBtn != btn) {
        
        self.currentSelectColorBtn.transform = CGAffineTransformIdentity;
        btn.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.currentSelectColorBtn = btn;
        
        NSInteger index = btn.tag - 1000;
        UIColor *color = self.availableColors[index];
        self.textInputView.textColor = color;
    }
}

#pragma mark - public func
- (void)callOutKeyboard {
    
    [self.textInputView becomeFirstResponder];
}

- (void)clearTextView {
    self.textInputView.text = nil;
}

- (void)setText:(NSString *)text textColor:(UIColor *)textColor textMapShowView:(HHVideoTextMapShowContainerView *)textMapShowView{
    
    self.textInputView.text = text;
    self.textInputView.textColor = textColor;
    
    NSInteger index = 0;
    for (NSInteger i = 0; i < self.availableColors.count; i++) {
     
        if ([self isColorTheSame:textColor color2:self.availableColors[i]]) {
            
            index = i;
            break;
        }
    }
    
    UIButton *btn = self.bottomColorSelectContainerView.subviews[index];
    [self onColorSelectBtnClick:btn];
    
    self.textMapShowView = textMapShowView;
    self.isFromTextMapShowView = YES;
}

// 判断两个颜色是否一致
- (BOOL)isColorTheSame:(UIColor *)color1 color2:(UIColor *)color2 {
    
    CGFloat red1,red2,green1,green2,blue1,blue2,alpha1,alpha2;
    //取出color1的背景颜色的RGBA值
    [color1 getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
    //取出color2的背景颜色的RGBA值
    [color2 getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
    
    if ((red1 == red2)&&(green1 == green2)&&(blue1 == blue2)&&(alpha1 == alpha2)) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - private func
- (void)setupUI {
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    
    self.topFuncView = [[HHVideoEditTopFuncView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 44)];
    // 取消按钮
    __weak typeof(self) ws = self;
    self.topFuncView.cancelBlock = ^{
        
        if (ws.cancelBlock) {
            ws.textInputView.text = nil;
            ws.cancelBlock();
        }
    };
    // 完成按钮
    self.topFuncView.completeBlock = ^{
        
        if (ws.isFromTextMapShowView) {
            
            [ws.textMapShowView setText:ws.textInputView.text textColor:ws.textInputView.textColor];
            [ws.textInputView endEditing:YES];
            
        }else {
            if (ws.completeBlock) {
                ws.completeBlock(ws.textInputView);
            }
        }
    };
    [self addSubview:self.topFuncView];
    
    self.textInputView = [[UITextView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.topFuncView.frame) + 10, SCREEN_WIDTH - 2 * 10, 0)];
    self.textInputView.textColor = [UIColor whiteColor];
    self.textInputView.font = [UIFont systemFontOfSize:25];
    self.textInputView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.textInputView];
    
    // 底部颜色按钮容器视图
    self.bottomColorSelectContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    [self addSubview:self.bottomColorSelectContainerView];
    
    // 添加颜色选择按钮
    
    CGFloat colorBtnW = 20;
    CGFloat colorBtnMargin = (SCREEN_WIDTH - 20 * 2 - self.availableColors.count * colorBtnW) / (self.availableColors.count - 1);
    
    for (NSInteger i = 0 ; i < self.availableColors.count; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20 + i * (colorBtnW + colorBtnMargin), 7, colorBtnW, colorBtnW);
        btn.layer.cornerRadius = colorBtnW * 0.5;
        btn.layer.masksToBounds = YES;
        btn.layer.borderColor = ColorHexString(@"FFFFFF").CGColor;
        btn.layer.borderWidth = 2;
        btn.backgroundColor = self.availableColors[i];
        btn.tag = 1000 + i;
        [btn addTarget:self action:@selector(onColorSelectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomColorSelectContainerView addSubview:btn];
        
        if (i == 0) {
            btn.transform = CGAffineTransformMakeScale(1.3, 1.3);
            self.currentSelectColorBtn = btn;
        }
    }
}

#pragma mark - gettter,setter
- (NSArray<UIColor *> *)availableColors {
    
    if (!_availableColors) {
        
        _availableColors = @[[UIColor whiteColor],
                             [UIColor blackColor],
                             [UIColor redColor],
                             [UIColor yellowColor],
                             [UIColor greenColor],
                             [UIColor blueColor],
                             [UIColor purpleColor]];
    }
    return _availableColors;
}
@end
