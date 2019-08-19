//
//  HHVideoEditBottomFuncView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/7/25.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHVideoEditBottomFuncView.h"
#import "UIColor+YYAdd.h"
#import "UIView+HHAdditions.h"
#import "globalDefine.h"
#import "HHAVKitConfig.h"

@interface HHVideoEditBottomFuncView ()

// 画笔
@property (strong, nonatomic) UIButton *doodleBrushBtn;
// 贴图
@property (strong, nonatomic) UIButton *attachBtn;
// 文字
@property (strong, nonatomic) UIButton *textBtn;
// 裁剪
@property (strong, nonatomic) UIButton *clipBtn;

// 按钮数组
@property (strong, nonatomic) NSArray <UIButton *> *bottomBtns;

// 顶部颜色选择和橡皮容器视图
@property (strong, nonatomic) UIView *colorAndErasContainerView;

// 当前选中的颜色按钮
@property (strong, nonatomic) UIButton *currentSelectColorBtn;

// 可选的颜色数组
@property (strong, nonatomic) NSArray <UIColor *> *availableColors;

@end

@implementation HHVideoEditBottomFuncView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSInteger btnCount = self.bottomBtns.count;
    
    CGFloat btnW = 44;
    CGFloat btnMargin = (self.width - btnCount * btnW) / (btnCount + 1);
    for (NSInteger i = 0; i < btnCount; i++) {
        
        UIButton *btn = self.bottomBtns[i];
        btn.frame = CGRectMake(btnMargin + i * (btnW + btnMargin), 44, btnW, btnW);
    }
}

#pragma mark - private func
- (void)setupUI {
    
    self.doodleBrushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.attachBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.textBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.clipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.bottomBtns = @[self.doodleBrushBtn,self.textBtn,self.clipBtn];
    
    NSArray *bottomBtnImages = @[@"annotate",@"text",@"clip",@"attach"];
    NSArray *bottomBtnSelectors = @[@"onDoodleBrushBtnClick:",@"onTextBtnClick:",@"onClipBtnClick:",@"onAttachBtnClick:"];
    
    NSInteger btnCount = self.bottomBtns.count;
    
    for (NSInteger i = 0; i < btnCount; i++) {
        
        UIButton *btn = self.bottomBtns[i];
        NSString *imageName = bottomBtnImages[i];
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        if (i == 0) {
            NSString *selectedName = [NSString stringWithFormat:@"%@_selected",imageName];
            [btn setImage:[UIImage imageNamed:selectedName] forState:UIControlStateSelected];
        }
        [btn addTarget:self action:NSSelectorFromString(bottomBtnSelectors[i]) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}

#pragma mark - event respond
- (void)onDoodleBrushBtnClick:(UIButton *)btn {
    
    btn.selected = !btn.selected;
    
    self.isShowColorAndEraseView = btn.selected;
    
    if (self.doodleBlock) {
        self.doodleBlock(btn.selected);
    }
}

- (void)onAttachBtnClick:(UIButton *)btn {
    
}

- (void)onTextBtnClick:(UIButton *)btn {
    
    if (self.textMapBlock) {
        self.textMapBlock();
    }
}

- (void)onClipBtnClick:(UIButton *)btn {
    
    if (self.clipBlock) {
        self.clipBlock();
    }
}
- (void)onColorSelectBtnClick:(UIButton *)btn {
    
    if (self.currentSelectColorBtn != btn) {
        
        if (btn.tag == 1000 + self.availableColors.count) {
            
            self.currentSelectColorBtn.transform = CGAffineTransformIdentity;
            btn.selected = YES;
            
            if (self.doodleDrawModeSelectBlock) {
                self.doodleDrawModeSelectBlock(DrawingModeErase);
            }
            
        }else {
            
            if (self.currentSelectColorBtn.tag == 1000 + self.availableColors.count) {
                
                self.currentSelectColorBtn.selected = NO;
                
            }else {
                self.currentSelectColorBtn.transform = CGAffineTransformIdentity;
                
            }
            btn.transform = CGAffineTransformMakeScale(1.3, 1.3);
            
            NSInteger index = btn.tag - 1000;
            UIColor *color = self.availableColors[index];
            
            if (self.doodleColorSelectBlock) {
                self.doodleColorSelectBlock(color);
            }
        }
        
        self.currentSelectColorBtn = btn;
        
    }
}

#pragma mark - getter,setter
- (UIView *)colorAndErasContainerView {
    
    if (!_colorAndErasContainerView) {
     
        _colorAndErasContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        
        _colorAndErasContainerView.backgroundColor = [UIColor clearColor];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 44 - 1, SCREEN_WIDTH, 1)];
        separatorView.backgroundColor = [UIColorHex(#FFFFFF) colorWithAlphaComponent:0.4];
        [_colorAndErasContainerView addSubview:separatorView];
        
        // 添加颜色选择按钮
        
        CGFloat colorBtnW = 20;
        CGFloat colorBtnMargin = (SCREEN_WIDTH - 20 * 2 - (self.availableColors.count + 1) * colorBtnW) / (self.availableColors.count);
        
        for (NSInteger i = 0 ; i < self.availableColors.count + 1; i++) {
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(20 + i * (colorBtnW + colorBtnMargin), 7, colorBtnW, colorBtnW);
            btn.tag = 1000 + i;
            [btn addTarget:self action:@selector(onColorSelectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [_colorAndErasContainerView addSubview:btn];
            
            if (i == self.availableColors.count) {
                
                [btn setImage:[UIImage imageNamed:@"doodle_eraser_normal"] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"doodle_eraser_selected"] forState:UIControlStateSelected];
                
            }else {
                
                btn.layer.cornerRadius = colorBtnW * 0.5;
                btn.layer.masksToBounds = YES;
                btn.layer.borderColor = UIColorHex(#FFFFFF).CGColor;
                btn.layer.borderWidth = 2;
                btn.backgroundColor = self.availableColors[i];
                
                if (i == 2) {
                    btn.transform = CGAffineTransformMakeScale(1.3, 1.3);
                    self.currentSelectColorBtn = btn;
                }
            }
            
        }
    }
    
    return _colorAndErasContainerView;
}

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

- (void)setIsShowColorAndEraseView:(BOOL)isShowColorAndEraseView {
    
    _isShowColorAndEraseView = isShowColorAndEraseView;
    
    if (isShowColorAndEraseView) {
        
        if (_colorAndErasContainerView) {
            _colorAndErasContainerView.hidden = NO;
        }else {
            [self addSubview:self.colorAndErasContainerView];
        }
        
    }else {

        _colorAndErasContainerView.hidden = YES;
//        [_colorAndErasContainerView removeFromSuperview];
//
//        _colorAndErasContainerView = nil;
    }
}
@end
