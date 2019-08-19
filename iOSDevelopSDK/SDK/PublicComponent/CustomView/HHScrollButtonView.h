//
//  HHScrollButtonView.h
//  HHForAppStore
//
//  Created by Hayder on 2018/3/28.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HHScrollButtonView;
@protocol HHScrollButtonViewDelegate <NSObject>

@optional
- (void)scrollButtonView:(HHScrollButtonView *)scrollView didClickButton:(UIButton *)btn contentView:(UIScrollView *)contentView;

@end

@interface HHScrollButtonView : UIView

/**
滚动view
 */
@property (nonatomic, strong) UIScrollView *contentView;

@property (nonatomic, weak) id<HHScrollButtonViewDelegate> delegate;

@property (nonatomic, strong) UIColor *buttonBGColor;
/**
 @param frame 整个空间的Frames
 @param titles  按钮组件的标题数组
 @param contents 内容数组，与标题数组对应
 */
- (instancetype)initWithFrame:(CGRect)frame Titles:(NSArray <NSString *>*) titles Contents:(NSArray <UIView *>*)contents;

/**
 获取标题按钮对象  从1开始
 */
- (UIButton *)getTitleButtonWithIndex:(NSInteger)index;

/**
当前按钮所点击的位置  1开始
 */
- (NSInteger)currentClickindex;

/**
 设置scrollView滚动到第几个View

 @param index 从1开始
 */
- (void)setContentViewScrollViewToIndexView:(NSInteger)index animated:(BOOL) animated;

/**
 设置Slider到固定位置
 */
- (void)setLineToIndex:(NSInteger)index;

@end
