//
//  UIButton+HHExtension.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HHButtonEdgeInsetsStyle) {
    HHButtonEdgeInsetsStyleTop, // image在上，label在下
    HHButtonEdgeInsetsStyleLeft, // image在左，label在右
    HHButtonEdgeInsetsStyleBottom, // image在下，label在上
    HHButtonEdgeInsetsStyleRight // image在右，label在左
};

@interface UIButton (HHExtension)

/**
 *  设置button的titleLabel和imageView的布局样式，及间距
 *
 *  @param style titleLabel和imageView的布局样式
 *  @param space titleLabel和imageView的间距
 */
- (void)layoutButtonWithEdgeInsetsStyle:(HHButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space;

@end


