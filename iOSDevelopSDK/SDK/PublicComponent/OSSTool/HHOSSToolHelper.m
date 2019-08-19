//
//  HHOSSToolHelper.m
//  HHForAppStore
//
//  Created by Hayder on 2018/9/20.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHOSSToolHelper.h"

@implementation HHOSSToolHelper

+ (UIImage *)fixOrientationWithImage:(UIImage *)fixImage {
    
    // No-op if the orientation is already correct
    if (fixImage.imageOrientation == UIImageOrientationUp) return fixImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (fixImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, fixImage.size.width, fixImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, fixImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, fixImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (fixImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, fixImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, fixImage.size.height, 0);
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
    CGContextRef ctx = CGBitmapContextCreate(NULL, fixImage.size.width, fixImage.size.height,
                                             CGImageGetBitsPerComponent(fixImage.CGImage), 0,
                                             CGImageGetColorSpace(fixImage.CGImage),
                                             CGImageGetBitmapInfo(fixImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (fixImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,fixImage.size.height,fixImage.size.width), fixImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,fixImage.size.width,fixImage.size.height), fixImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


//获取对应的时间
+ (NSString *)currentDateStringWithFormat:(NSString *)formatterStr {
    // 获取系统当前时间
    NSDate *currentDate = [NSDate date];
    // 用于格式化NSDate对象
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置格式：yyyy-MM-dd HH:mm:ss
    formatter.dateFormat = formatterStr;
    // 将 NSDate 按 formatter格式 转成 NSString
    NSString *currentDateStr = [formatter stringFromDate:currentDate];
    // 输出currentDateStr
    return currentDateStr;
}

+ (MBProgressHUD *)HH_showProgressWithDescroption:(NSString *)descripotion withView:(UIView *)containView
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:containView];
    [containView addSubview:HUD];
    
    HUD.labelText = descripotion;
    [HUD show:YES];
    HUD.userInteractionEnabled = NO;
    return HUD;
}

+ (void)HH_hideActivityHUDInContainView:(UIView *)containView
{
    [MBProgressHUD hideAllHUDsForView:containView animated:YES];
}
@end
