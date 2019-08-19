//
//  HHVideoEditBottomFuncView.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/7/25.
//  Copyright © 2018年 Hayder. All rights reserved.
//  视频编辑界面底部功能容器视图（画笔，贴图，文字，裁剪）,高度最小84

#import <UIKit/UIKit.h>
#import "HHPaintView.h"

@interface HHVideoEditBottomFuncView : UIView

// 是否展示颜色选择视图,默认不显示
@property (assign, nonatomic) BOOL isShowColorAndEraseView;

// 涂鸦事件回调
@property (copy, nonatomic) void (^doodleBlock)(BOOL isSelected);
// 涂鸦颜色选择回调
@property (copy, nonatomic) void (^doodleColorSelectBlock)(UIColor *selectColor);
// 涂鸦模式选择回调
@property (copy, nonatomic) void (^doodleDrawModeSelectBlock)(DrawingMode drawingMode);

// 裁剪事件回调
@property (copy, nonatomic) void (^clipBlock)();

// 文字贴图事件回调
@property (copy, nonatomic) void (^textMapBlock)();

@end
