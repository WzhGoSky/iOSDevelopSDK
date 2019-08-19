//
//  UIImage+SignatureExtension.h
//  test
//
//  Created by Hayder on 2018/10/24.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SignatureExtension)
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
- (UIImage *)imageWithTintColor:(UIColor *)tintColor;
@end
