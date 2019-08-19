//
//  HHCircleProgress.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2017/5/30.
//  Copyright © 2017年 Hayder. All rights reserved.
//

#import "HHCircleProgressView.h"

@interface HHCircleProgressView ()
{
    /** 原点 */
    CGPoint _origin;
    /** 半径 */
    CGFloat _radius;
    /** 起始 */
    CGFloat _startAngle;
    /** 结束 */
    CGFloat _endAngle;
}


/** 底层显示层 */
@property (nonatomic, strong) CAShapeLayer *bottomLayer;
/** 顶层显示层 */
@property (nonatomic, strong) CAShapeLayer *topLayer;
/** 宽度 */
@property (nonatomic, assign) CGFloat progressWidth;
@end

@implementation HHCircleProgressView

- (instancetype)initWithFrame:(CGRect)frame progress:(CGFloat)progress progressWidth:(CGFloat)progressWidth{
    if (self) {
        self = [super initWithFrame:frame];
        self.backgroundColor = [UIColor clearColor];
        self.progressWidth = progressWidth;
        self.topLayer.lineWidth = progressWidth;
        self.bottomLayer.lineWidth = progressWidth;
        [self setUI];
        self.progress = progress;
    }
    return self;
}

#pragma mark - 初始化页面
- (void)setUI {

    [self.layer addSublayer:self.bottomLayer];
    [self.layer addSublayer:self.topLayer];
    [self addSubview:self.progressLabel];
    self.layer.cornerRadius = 25.f;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    _origin = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    _radius = self.bounds.size.width / 2;
    
    UIBezierPath *bottomPath = [UIBezierPath bezierPathWithArcCenter:_origin radius:_radius+self.progressWidth/2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    _bottomLayer.path = bottomPath.CGPath;
    
    //添加点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickProgressView:)];
    [self.progressLabel addGestureRecognizer:tap];
}

- (void)didClickProgressView:(UITapGestureRecognizer *)tap
{
    if (self.clickEvent) {
        self.clickEvent();
    }
}

#pragma mark - 懒加载
- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, self.bounds.size.height)];
        _progressLabel.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.userInteractionEnabled = YES;
        _progressLabel.textColor = [UIColor whiteColor];
        _progressLabel.font = [UIFont systemFontOfSize:16.f];
    }
    return _progressLabel;
}

- (CAShapeLayer *)bottomLayer {
    if (!_bottomLayer) {
        _bottomLayer = [CAShapeLayer layer];
        _bottomLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _bottomLayer;
}

- (CAShapeLayer *)topLayer {
    if (!_topLayer) {
        _topLayer = [CAShapeLayer layer];
        _topLayer.lineCap = kCALineCapRound;
        _topLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _topLayer;
}

#pragma mark - setMethod
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    _startAngle = - M_PI_2;
    _endAngle = _startAngle + _progress * M_PI * 2;
    
    UIBezierPath *topPath = [UIBezierPath bezierPathWithArcCenter:_origin radius:_radius+self.progressWidth/2 startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    _topLayer.path = topPath.CGPath;
}

- (void)setBottomColor:(UIColor *)bottomColor {
    _bottomColor = bottomColor;
    _bottomLayer.strokeColor = _bottomColor.CGColor;
}

- (void)setTopColor:(UIColor *)topColor {
    _topColor = topColor;
    _topLayer.strokeColor = _topColor.CGColor;
}

- (void)setProgressWidth:(CGFloat)progressWidth {
    
    _progressWidth = progressWidth;
    _topLayer.lineWidth = progressWidth;
    _bottomLayer.lineWidth = progressWidth;
}

@end
