//
//  ElectronicSignatureManager.m
//  test
//
//  Created by Hayder on 2018/10/24.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "ElectronicSignatureManager.h"
#import "ElectronicSignatureView.h"

@interface ElectronicSignatureManager()
@property (nonatomic, strong) ElectronicSignatureView *mainView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) void(^finifshBlock)(UIImage *img, CGRect frame);
@property (nonatomic, assign) CGRect superViewFrame;
@end

@implementation ElectronicSignatureManager

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backView];
        [self addSubview:self.mainView];
    }
    return self;
}

+(void)showElectronicSignatureViewWithConfig:(ElectronicSignatureConfig *)config complete:(void(^)(UIImage *img, CGRect frame))complete superViewFrame:(CGRect)superViewFrame{
    ElectronicSignatureManager *view = [[ElectronicSignatureManager alloc]initWithFrame:[UIScreen mainScreen].bounds];
    view.finifshBlock = complete;
    view.superViewFrame = superViewFrame;
    view.mainView.config = config;
    [[UIApplication sharedApplication].keyWindow addSubview:view];
}

-(void)didClickback{
    [self removeFromSuperview];
}

-(void)getEditImg:(UIImage *)img{
    
    if (self.finifshBlock) {
        
        CGRect frame = self.mainView.frame;
        frame.size.width = img.size.width * 0.5;
        frame.size.height =  img.size.height * 0.5;
        CGFloat fatherW = self.superViewFrame.size.width;
        CGFloat fatherH = self.superViewFrame.size.height;
        frame.origin.x = (fatherW - frame.size.width) * 0.5;
        frame.origin.y = (fatherH - frame.size.height) * 0.5;
        self.finifshBlock(img, frame);
        [self didClickback];
    }
}

#pragma lazy
-(UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0.6;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickback)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

-(ElectronicSignatureView *)mainView{
    if (!_mainView) {
        _mainView = [[ElectronicSignatureView alloc]initWithFrame:CGRectMake(10, ([UIScreen mainScreen].bounds.size.height - 500) * 0.5, [UIScreen mainScreen].bounds.size.width - 20, 500)];
        _mainView.layer.cornerRadius = 12;
        _mainView.layer.masksToBounds = YES;
        __weak typeof(self)wself = self;
        _mainView.finifshBlock = ^(UIImage *img) {
            [wself getEditImg:img];
        };
    }
    return _mainView;
}


@end
