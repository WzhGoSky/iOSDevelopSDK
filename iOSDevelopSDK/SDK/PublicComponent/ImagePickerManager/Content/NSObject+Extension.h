//
//  NSObject+Extension.h
//  jupiter
//
//  Created by Hayder on 2017/3/6.
//  Copyright © 2017年 dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (Extension)
/**
 * 获取当前显示的控制器
 */
+ (UIViewController *)getCurrentController;

+ (UIViewController *)getPresentController;
@end
