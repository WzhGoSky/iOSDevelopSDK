//
//  UIImage+Extension.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import "UIImage+HHExtension.h"

@implementation UIImage (Extension)

- (UIImage *)imageWithTintColor:(UIColor *)tintColor
{
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeDestinationIn];
}

- (UIImage *)imageWithGradientTintColor:(UIColor *)tintColor
{
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeOverlay];
}

- (UIImage *)imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode
{
    if (!tintColor) {
        return self;
    }
    
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn)
    {
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
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
        default:
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
        default:
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
        // Grr...
        CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
        break;
        
        default:
        CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
        break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


//等比压缩图片
+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

//压缩尺寸
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
//压缩小于100kb
+ (NSData *)imageData:(UIImage *)image {
    
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 200*1024;
    
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation (image, compression);
    }
    
    
    return imageData;
}

//图片本地保存 PNG
+(NSString *)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName {
    
    NSData* imageData = UIImagePNGRepresentation(tempImage);
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    [imageData writeToFile:fullPathToFile atomically:NO];
    
    return fullPathToFile;
}
//图片转PNG
+(UIImage *)pngImage:(UIImage*)image {
    
    NSData *mydata=UIImagePNGRepresentation(image);
    
    return [UIImage imageWithData:mydata];
}

//图片转JEPG
+(UIImage *)JEPGImage:(UIImage*)image {
    
    NSData *mydata= UIImageJPEGRepresentation(image, 0.4);
    
    return [UIImage imageWithData:mydata];
}
//图片转base64
+(NSString *)base:(UIImage *)image  {
    
    NSData *mydata=UIImagePNGRepresentation(image);
    
    NSString *picString=[mydata base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    return picString;
}
//base64转图片
+(UIImage *)image:(NSString *)base64 {
    
    NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *decodedImage      = [UIImage imageWithData:decodedImageData];
    
    return decodedImage;
}

//颜色装换成图片
// 画指定高度和颜色的图片
+ (UIImage*)createImageWithColor:(UIColor*)color andHeight:(CGFloat)height {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, height); //宽高 1.0只要有值就够了
    UIGraphicsBeginImageContext(rect.size); //在这个范围内开启一段上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);//在这段上下文中获取到颜色UIColor
    CGContextFillRect(context, rect);//用这个颜色填充这个上下文
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();//从这段上下文中获取Image属性,,,结束
    UIGraphicsEndImageContext();
    
    return image;
}

+(UIImage *)wechatImageView:(NSString *)Url{
    
    //创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //过滤器恢复默认
    [filter setDefaults];
    
    //给过滤器添加数据
    NSString *string = Url;
    
    //将NSString格式转化成NSData格式
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    [filter setValue:data forKeyPath:@"inputMessage"];
    
    //获取二维码过滤器生成的二维码
    CIImage *image = [filter outputImage];
    
    //将获取到的二维码添加到imageview上
    return  [UIImage imageWithCIImage:image];
    
    
}


+ (UIImage *)gradientColorImageFromColors:(NSArray*)colors gradientType:(GradientType)gradientType imgSize:(CGSize)imgSize {
    
    NSMutableArray *ar = [NSMutableArray array];
    
    for(UIColor *c in colors) {
        
        [ar addObject:(id)c.CGColor];
        
    }
    
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, 1);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    
    CGPoint start;
    
    CGPoint end;
    
    switch (gradientType) {
            
        case GradientTypeTopToBottom:
            
            start = CGPointMake(0.0, 0.0);
            
            end = CGPointMake(0.0, imgSize.height);
            
            break;
            
        case GradientTypeLeftToRight:
            
            start = CGPointMake(0.0, 0.0);
            
            end = CGPointMake(imgSize.width, 0.0);
            
            break;
            
        case GradientTypeUpleftToLowright:
            
            start = CGPointMake(0.0, 0.0);
            
            end = CGPointMake(imgSize.width, imgSize.height);
            
            break;
            
        case GradientTypeUprightToLowleft:
            
            start = CGPointMake(imgSize.width, 0.0);
            
            end = CGPointMake(0.0, imgSize.height);
            
            break;
            
        default:
            
            break;
            
    }
    
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    
    CGContextRestoreGState(context);
    
    CGColorSpaceRelease(colorSpace);
    
    UIGraphicsEndImageContext();
    
    return image;
    
}


- (UIImage *)imageWithCornerRadius:(CGFloat)radius {
    CGRect rect = (CGRect){0.f, 0.f, self.size};
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, UIScreen.mainScreen.scale);
    CGContextAddPath(UIGraphicsGetCurrentContext(),
                     [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius].CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    
    [self drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


+ (UIImage *)imageAnimatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!image) {
                continue;
            }
            
            duration += [self sd_frameDurationAtIndex:i source:source];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

+ (float)sd_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}


@end
