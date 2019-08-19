//
//  UIImage+Extension.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GradientType) {
    
    GradientTypeTopToBottom = 0,//从上到小
    GradientTypeLeftToRight = 1,//从左到右
    GradientTypeUpleftToLowright = 2,//左上到右下
    GradientTypeUprightToLowleft = 3,//右上到左下
    
};

@interface UIImage (HHExtension)

/**
 只对里面的图案作更改颜色操作
 */
- (UIImage *)imageWithTintColor:(UIColor *)tintColor;
- (UIImage *)imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;
- (UIImage *)imageWithGradientTintColor:(UIColor *)tintColor;

/**
 解决拍照上传时照片旋转的问题
 */
- (UIImage *)fixOrientation;

//保持原来的长宽比，生成一个缩略图
+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;

//压缩尺寸
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
//压缩图片小于100kb
+ (NSData *)imageData:(UIImage *)image;

//保存图片到document png
+(NSString *)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName;

//图片转PNG
+(UIImage *)pngImage:(UIImage*)image;

//图片转JEPG
+(UIImage *)JEPGImage:(UIImage*)image;

//图片转base64
+(NSString *)base:(UIImage *)image;

//base64转图片
+(UIImage *)image:(NSString *)base64;

+ (UIImage*)createImageWithColor:(UIColor*)color andHeight:(CGFloat)height;

+(UIImage *)wechatImageView:(NSString *)Url ;

//颜色渐变
+ (UIImage *)gradientColorImageFromColors:(NSArray*)colors gradientType:(GradientType)gradientType imgSize:(CGSize)imgSize;

//图片圆角
- (UIImage *)imageWithCornerRadius:(CGFloat)radius;

//加载gif
+ (UIImage *)imageAnimatedGIFWithData:(NSData *)data;

@end

