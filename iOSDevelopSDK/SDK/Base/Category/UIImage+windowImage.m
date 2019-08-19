//
//  UIImage+windowImage.m
//  赛事平台
//
//  Created by 喵小仲 on 16/10/19.
//  Copyright © 2016年 ytgame. All rights reserved.
//

#import "UIImage+windowImage.h"

@implementation UIImage (windowImage)

+ (UIImage *)getWindowImage
{
    return [UIImage getViewImageWithView:[[UIApplication sharedApplication] keyWindow] rect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
}

+ (UIImage *)getImageWithImage1:(UIImage *)image1 image2:(UIImage *)image2
{
    CGFloat image2Heihgt = image2.size.height*image1.size.width/image2.size.width;
    CGSize size = CGSizeMake(image1.size.width,image1.size.height+image2Heihgt);
    UIGraphicsBeginImageContext(size);
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    [image2 drawInRect:CGRectMake(0, image1.size.height, image1.size.width, image2Heihgt)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)getViewImageWithView:(UIView *)view rect:(CGRect)rect
{
    UIGraphicsBeginImageContext(view.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIRectClip(rect);
    [view.layer renderInContext:context];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

+ (UIImage *)setImageFromImage:(UIImage *)fromImage toImage:(UIImage *)toImage inRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(toImage.size);
    [toImage drawInRect:CGRectMake(0, 0, toImage.size.width, toImage.size.height)];
    [fromImage drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)createAImageWithColor:(UIColor *)color alpha:(CGFloat)alpha{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetAlpha(context, alpha);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage*)imageFromColors:(NSArray*)colors withSize:(CGSize)size
{
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    
    CGPoint start;
    CGPoint end;
    start = CGPointMake(0.0, size.height/2);
    end = CGPointMake(size.width, size.height/2);
    
    CGContextDrawLinearGradient(context, gradient, start, end,kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)placeholderImageWithSize:(CGSize)size
{
    
    UIColor *backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
    UIImage *image = [UIImage imageNamed:@"Common_placeholderImage_common"];
    CGFloat viewWH = size.width > size.height ? size.height : size.width;
    CGSize logoSize = CGSizeMake(viewWH, viewWH);
    
    UIGraphicsBeginImageContextWithOptions(size,0, [UIScreen mainScreen].scale);
    [backgroundColor set];
    UIRectFill(CGRectMake(0,0, size.width, size.height));
    CGFloat imageX = (size.width / 2) - (logoSize.width / 2);
    CGFloat imageY = (size.height / 2) - (logoSize.height / 2);
    [image drawInRect:CGRectMake(imageX, imageY, logoSize.width, logoSize.height)];
    UIImage *resImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f,0.0f, 1.0f,1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    
    if (!color || size.width <=0 || size.height <=0) return nil;
    
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(rect.size,NO, 0);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextFillRect(context, rect);
    
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}


@end
