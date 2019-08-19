//
//  UIImage+Extension.h
//  test
//
//  Created by Hayder on 2018/10/3.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (Extension)

- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
/**
 从本地取出图片
 
 @param nameStr 图片名
 @return 图片
 */
+(instancetype)readImageWithName:(NSString *)nameStr;
/**
 存图片到本地
 
 @param image 图片
 @return 图片名
 */
+(NSString *)saveImage:(UIImage *)image andName:(NSString *)name;
/**
 保存图片到本地
 @param image 图片
 @param path 图片Url
 @return 是否保存成功
 */
+(NSString *)saveImageData:(NSData *)imageData andName:(NSString *)name;

+(NSString *)getSaveImaDataWithName:(NSString *)nameStr;

- (UIImage *)fixOrientation;
@end
