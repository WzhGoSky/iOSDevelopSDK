//
//  HHVideoTextMapShowContainerView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/7/31.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHVideoTextMapShowContainerView.h"
#import "HHVideoMapSquareView.h"
#import "UIView+HHAdditions.h"
#import "globalDefine.h"

@interface HHVideoTextMapShowContainerView () <UIGestureRecognizerDelegate>

// 周围边框
@property (strong, nonatomic) HHVideoMapSquareView *squareView;

// 中间显示的文字label
@property (strong, nonatomic) UILabel *showTextLbel;


@end

@implementation HHVideoTextMapShowContainerView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
        
        [self addGestures];
        
    }
    return self;
}

- (void)dealloc {
    
    NSLog(@"1313123");
}

#pragma mark - public func
- (void)setText:(NSString *)text textColor:(UIColor *)textColor {
    
    self.showTextLbel.textColor = textColor;
    self.showTextLbel.text = text;
    
    CGRect textFrame = [text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 5 * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.textView.font} context:nil];
    
    self.width = textFrame.size.width;
    self.height = textFrame.size.height;
    self.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5);
    self.showTextLbel.frame = CGRectMake(5, 5, textFrame.size.width, textFrame.size.height);
    self.squareView.frame = self.bounds;
}

#pragma mark - private func
- (void)setupUI {
    
    self.backgroundColor = [UIColor clearColor];
    
//    self.squareView = [[HHVideoMapSquareView alloc] initWithFrame:self.bounds];
//    self.squareView.squareColor = [UIColor whiteColor];
//    [self addSubview:self.squareView];
    
    self.showTextLbel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.width - 5 * 2, self.height - 5 * 2)];
    self.showTextLbel.numberOfLines = 0;
    self.showTextLbel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.showTextLbel];
}

- (void)addGestures {
    
    // 拖动
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
    // 捏合
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinchGesture:)];
    pinch.delegate = self;
    [self addGestureRecognizer:pinch];
    // 旋转
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(onRotationGesture:)];
    rotation.delegate = self;
    [self addGestureRecognizer:rotation];
    // 长按
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressGesture:)];
    longPress.delegate = self;
    longPress.minimumPressDuration = 1;
    [self addGestureRecognizer:longPress];
    // 点击
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tap];
    
}

- (void)onPanGesture:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint translation = [panGesture translationInView:self.superview];

    self.centerX += translation.x;
    self.centerY += translation.y;

    [panGesture setTranslation:CGPointZero inView:self.superview];
    
}

- (void)onPinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    
    self.transform = CGAffineTransformScale(self.transform, pinchGesture.scale, pinchGesture.scale);
    
    [pinchGesture setScale:1];
}

- (void)onRotationGesture:(UIRotationGestureRecognizer *)rotationGesture {
    
    self.transform = CGAffineTransformRotate(self.transform, rotationGesture.rotation);
    
    [rotationGesture setRotation:0];
}

- (void)onLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture {
    
    if (self.longPressBlock) {
        self.longPressBlock(self);
    }
}

- (void)onTapGesture:(UITapGestureRecognizer *)tapGesture {
    
    if (self.doubleClickBlock) {
        
        self.doubleClickBlock(self, self.showTextLbel.text, self.showTextLbel.textColor);
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}


#pragma mark - getter,setter
- (void)setTextView:(UITextView *)textView {
    
    _textView = textView;
    
    self.showTextLbel.text = textView.text;
    self.showTextLbel.textColor = textView.textColor;
    self.showTextLbel.font = textView.font;
    
    CGRect textFrame = [textView.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 5 * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : textView.font} context:nil];
    
    self.width = textFrame.size.width;
    self.height = textFrame.size.height;
    self.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5);
    self.showTextLbel.frame = CGRectMake(5, 5, textFrame.size.width, textFrame.size.height);
    self.squareView.frame = self.bounds;
    
}

@end
