//
//  HHVideoTextMapShowContainerView.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/7/31.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHVideoTextMapShowContainerView : UIView

// 长按事件回调
@property (copy, nonatomic) void (^longPressBlock)(HHVideoTextMapShowContainerView *textMapShowContainerView);

// 双击事件回调
@property (copy, nonatomic) void (^doubleClickBlock)(HHVideoTextMapShowContainerView *textMapShowView, NSString *text, UIColor *textColor);

@property (strong, nonatomic) UITextView *textView;

- (void)setText:(NSString *)text textColor:(UIColor *)textColor;

@end
