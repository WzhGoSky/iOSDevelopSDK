//
//  UIView+HHLineExtension.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, HHBorderSideType) {
    HHBorderSideTypeAll  = 0,
    HHBorderSideTypeTop = 1 << 0,
    HHBorderSideTypeBottom = 1 << 1,
    HHBorderSideTypeLeft = 1 << 2,
    HHBorderSideTypeRight = 1 << 3,
};

@interface UIView (HHLineExtension)

- (UIView *)borderForColor:(UIColor *)color borderWidth:(CGFloat)borderWidth borderType:(HHBorderSideType)borderType;

@end
