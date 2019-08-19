//
//  MicroPlayBottomView.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/6/7.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MicroPlayBottomView;
@protocol MicroPlayBottomViewDelegate<NSObject>

/**
 slider滑动代理
 */
- (void)bottomBarSliderTouchDown:(MicroPlayBottomView *)bottomBar;

/**
 slider滑动代理
 */
- (void)bottomBarSliderTouchUpInside:(MicroPlayBottomView *)bottomBar;
/**
 slider滑动代理
 */
- (void)bottomBar:(MicroPlayBottomView *)bottomBar sliderChanged:(float) value;

/**
 状态栏点击了开关按钮
 */
- (void)bottomBarDidClickSwitchButton:(UIButton *)button;

@end

@interface MicroPlayBottomView : UIView

@property (strong, nonatomic) UILabel *currentTime;

@property (strong, nonatomic) UILabel *totalTime;

@property (strong, nonatomic) UISlider *seekProgress;

@property (strong, nonatomic) UIButton *startButton;

@property (assign, nonatomic) NSTimeInterval duration;

@property (nonatomic, weak) id<MicroPlayBottomViewDelegate> delegate;

+ (instancetype) bottomView;

@end
