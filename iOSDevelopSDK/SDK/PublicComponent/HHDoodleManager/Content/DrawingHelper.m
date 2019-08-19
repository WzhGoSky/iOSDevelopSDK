//
//  DrawingHelper.m
//  PublicComponent
//
//  Created by Hayder on 2018/10/19.
//

#import "DrawingHelper.h"
#define folderName @"/gzq_Photo"

#define suffixName @"pic.jpeg"

@implementation DrawingHelper
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
+(UIImage *)readImageWithName:(NSString *)nameStr{
    UIImage *image = [[UIImage alloc]initWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@%@",folderName,nameStr,suffixName]]];
    return image;
}


+ (UIImage *)drawImgWithImg:(UIImage *)img rect:(CGRect)rect
{
    //1.开启上下文
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    //2.绘制图片
    [img drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    //3.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //4.关闭图形上下文
    UIGraphicsEndImageContext();
    return newImage;
}


+ (UIImage *)getMosaicImageWith:(UIImage *)image level:(NSInteger)level{
    CGImageRef imageRef = image.CGImage;
    NSUInteger imageW = CGImageGetWidth(imageRef);
    NSUInteger imageH = CGImageGetHeight(imageRef);
    //创建颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char *)calloc(imageH*imageW*4, sizeof(unsigned char));
    CGContextRef contextRef = CGBitmapContextCreate(rawData, imageW, imageH, 8, imageW*4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, imageW, imageH), imageRef);
    
    unsigned char *bitMapData = CGBitmapContextGetData(contextRef);
    NSUInteger currentIndex,preCurrentIndex;
    NSUInteger sizeLevel = level == 0 ? MIN(imageW, imageH)/20.0 : level;
    //像素点默认是4个通道
    unsigned char *pixels[4] = {0};
    for (int i = 0; i < imageH; i++) {
        for (int j = 0; j < imageW; j++) {
            currentIndex = imageW*i + j;
            NSUInteger red = rawData[currentIndex*4];
            NSUInteger green = rawData[currentIndex*4+1];
            NSUInteger blue = rawData[currentIndex*4+2];
            NSUInteger alpha = rawData[currentIndex*4+3];
            if (red+green+blue == 0 && (alpha/255.0 <= 0.5)) {
                rawData[currentIndex*4] = 255;
                rawData[currentIndex*4+1] = 255;
                rawData[currentIndex*4+2] = 255;
                rawData[currentIndex*4+3] = 0;
                continue;
            }
            /*
             memcpy指的是c和c++使用的内存拷贝函数，memcpy函数的功能是从源src所指的内存地址的起始位置开始拷贝n个字节到目标dest所指的内存地址的起始位置中。
             strcpy和memcpy主要有以下3方面的区别。
             1、复制的内容不同。strcpy只能复制字符串，而memcpy可以复制任意内容，例如字符数组、整型、结构体、类等。
             2、复制的方法不同。strcpy不需要指定长度，它遇到被复制字符的串结束符"\0"才结束，所以容易溢出。memcpy则是根据其第3个参数决定复制的长度。
             3、用途不同。通常在复制字符串时用strcpy，而需要复制其他类型数据时则一般用memcpy
             */
            if (i % sizeLevel == 0) {
                if (j % sizeLevel == 0) {
                    memcpy(pixels, bitMapData+4*currentIndex, 4);
                }else{
                    //将上一个像素点的值赋给第二个
                    memcpy(bitMapData+4*currentIndex, pixels, 4);
                }
            }else{
                preCurrentIndex = (i-1)*imageW+j;
                memcpy(bitMapData+4*currentIndex, bitMapData+4*preCurrentIndex, 4);
            }
        }
    }
    //获取图片数据集合
    NSUInteger size = imageW*imageH*4;
    CGDataProviderRef providerRef = CGDataProviderCreateWithData(NULL, bitMapData, size, NULL);
    //创建马赛克图片，根据变换过的bitMapData像素来创建图片
    CGImageRef mosaicImageRef = CGImageCreate(imageW, imageH, 8, 4*8, imageW*4, colorSpace, kCGBitmapByteOrderDefault, providerRef, NULL, NO, kCGRenderingIntentDefault);//Creates a bitmap image from data supplied by a data provider.
    //创建输出马赛克图片
    CGContextRef outContextRef = CGBitmapContextCreate(bitMapData, imageW, imageH, 8, imageW*4, colorSpace, kCGImageAlphaPremultipliedLast);
    //绘制图片
    CGContextDrawImage(outContextRef, CGRectMake(0, 0, imageW, imageH), mosaicImageRef);
    
    CGImageRef resultImageRef = CGBitmapContextCreateImage(contextRef);
    UIImage *mosaicImage = [UIImage imageWithCGImage:resultImageRef];
    //释放内存
    CGImageRelease(resultImageRef);
    CGImageRelease(mosaicImageRef);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(providerRef);
    CGContextRelease(outContextRef);
    return mosaicImage;
}


+ (UIImage *)getFilterMosaicImageWith:(UIImage *)image{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
    //    NSLog(@"%@",filter.attributes);
    [filter setValue:ciImage forKey:kCIInputImageKey];
    [filter setDefaults];
    //导出图片
    CIImage *outPutImage = [filter valueForKey:kCIOutputImageKey];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outPutImage fromRect:[outPutImage extent]];
    UIImage *showImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return showImage;
}
@end
