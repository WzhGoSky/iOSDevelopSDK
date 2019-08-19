//
//  HHVideoTextMapContainerView.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/7/30.
//  Copyright © 2018年 Hayder. All rights reserved.
//  视频编辑界面的文字贴图界面

#import <UIKit/UIKit.h>
#import "HHVideoTextMapShowContainerView.h"

@interface HHVideoTextMapContainerView : UIView

// 取消事件回调
@property (copy, nonatomic) void (^cancelBlock)();
// 完成事件回调
@property (copy, nonatomic) void (^completeBlock)(UITextView *);

// 是否是双击文字贴图过来的
@property (assign, nonatomic) BOOL isFromTextMapShowView;

// 呼出键盘
- (void)callOutKeyboard;

- (void)clearTextView;

/**
 从文字贴图双击进入添加文字贴图界面

 @param text 要传入的文字
 @param textColor 要传入的文字颜色
 @param textMapShowView 文字贴图
 */
- (void)setText:(NSString *)text textColor:(UIColor *)textColor textMapShowView:(HHVideoTextMapShowContainerView *)textMapShowView;

@end
