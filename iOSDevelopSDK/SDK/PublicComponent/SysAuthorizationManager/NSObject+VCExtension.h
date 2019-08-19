//
//  NSObject+VCExtension.h
//  test
//
//  Created by Hayder on 2018/9/29.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (VCExtension)
/**
 * 获取当前显示的控制器
 */
+ (UIViewController *)getCurrentController;

+ (UIViewController *)getPresentController;
@end
