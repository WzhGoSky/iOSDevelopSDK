//
//  UIImage+Extension.m
//  test
//
//  Created by Hayder on 2018/10/3.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "UIImage+Extension.h"

#define folderName @"/gzq_Photo"

#define suffixName @"pic.jpeg"

@implementation UIImage (Extension)

- (UIImage *)fixOrientation
{
    // No-op if the orientation is already correct.
    if (self.imageOrientation == UIImageOrientationUp) {
        return self;
    }
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context.
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}

- (UIImage *)imageByScalingToSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    //   CGSize imageSize = sourceImage.size;
    //   CGFloat width = imageSize.width;
    //   CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    //   CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}

/**
 存图片到本地
 
 @param image 图片
 @return 图片名
 */
+(NSString *)saveImage:(UIImage *)image andName:(NSString *)name{
    
    NSString *imageDir = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject],folderName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //文件名
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000 * 1000;
    NSInteger index = arc4random() % 10000;
    NSString *imageFilePath = [NSString stringWithFormat:@"%@-%zd%f",name,index,interval];
    //保存图片
    @autoreleasepool {
        [UIImageJPEGRepresentation(image, 1) writeToFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@%@",folderName,imageFilePath,suffixName]] atomically:YES];
    }
    return imageFilePath;
}
/**
 从本地取出图片
 
 @param nameStr 图片名
 @return 图片
 */
+(instancetype)readImageWithName:(NSString *)nameStr{
    UIImage *image = [[UIImage alloc]initWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@%@",folderName,nameStr,suffixName]]];
    return image;
}

+(NSString *)getSaveImaDataWithName:(NSString *)nameStr{
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@%@",folderName,nameStr,suffixName]];
}

+(NSString *)saveImageData:(NSData *)imageData andName:(NSString *)name{
    
    NSString *imageDir = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject],folderName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //文件名
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000 * 1000;
    NSInteger index = arc4random() % 10000;
    NSString *imageFilePath = [NSString stringWithFormat:@"%@-%zd%f",name,index,interval];
    //保存图片
    @autoreleasepool {
        [imageData writeToFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@%@",folderName,imageFilePath,suffixName]] atomically:YES];
    }
    return imageFilePath;
}



@end
