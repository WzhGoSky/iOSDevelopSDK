//
//  HHCameraHelper.m
//  HHCamera
//
//  Created by Hayder on 2018/10/5.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHCameraHelper.h"
#define MASK_TAG 56000
#define WAIT_CONTENT_TAG 56001
#define WAITING_TAG 56002
@implementation HHCameraHelper

+ (UIImage *)image:(UIImage *)image WithTintColor:(UIColor *)tintColor
{
    return [self image:image WithTintColor:tintColor blendMode:kCGBlendModeDestinationIn];
}

+ (UIImage *)image:(UIImage *)image WithGradientTintColor:(UIColor *)tintColor
{
    return [self image:image WithTintColor:tintColor blendMode:kCGBlendModeOverlay];
}

+ (UIImage *)image:(UIImage *)image WithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode
{
    if (!tintColor) {
        return image;
    }
    
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [image drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn)
    {
        [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

//转码
+ (void)convertToMP4:(QualityLevel)qualityLevel avAsset:(AVURLAsset*)avAsset videoPath:(NSString*)videoPath succ:(void (^)(NSString *resultPath))succ fail:(void (^)(void))fail
{
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    NSString *Level = AVAssetExportPresetMediumQuality;
    if (qualityLevel == QualityLevelHigh) {
        Level = AVAssetExportPresetHighestQuality;
    }else if (qualityLevel == QualityLevelLow)
    {
        Level = AVAssetExportPresetLowQuality;
    }
    if ([compatiblePresets containsObject:Level])
    {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:Level];
        exportSession.outputURL = [NSURL fileURLWithPath:videoPath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        CMTime start = CMTimeMakeWithSeconds(0, avAsset.duration.timescale);
        CMTime duration = avAsset.duration;
        CMTimeRange range = CMTimeRangeMake(start, duration);
        exportSession.timeRange = range;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status])
            {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                    if (fail)
                    {
                        fail();
                    }
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    if (fail)
                    {
                        fail();
                    }
                    break;
                default:
                    if (succ)
                    {
                        succ(videoPath);
                    }
                    break;
            }
        }];
    }
}


/**
 生成文件内容的名称
 */
+ (NSString *)gengerateFileName
{
    NSInteger salt = arc4random()%10000000;
    NSString *fileName = [NSString stringWithFormat:@"%@%ld.jpg",[self currentDateStringWithFormat:@"yyyyMMddHHmmss"],salt];
    return fileName;
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

//将图片存储到cache中
+ (void)saveImageToFile:(UIImage *)image
{
    @autoreleasepool{
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString *folderPath = [cachePath stringByAppendingPathComponent:@"cameraCache"];
        NSString *filePath = [folderPath stringByAppendingPathComponent:[self gengerateFileName]];
        NSData *data = UIImageJPEGRepresentation(image, 1);
        BOOL isSuccessed = [data writeToFile:filePath atomically:YES];
        if (isSuccessed) {
            image = [UIImage imageWithContentsOfFile:filePath];
        }
    };
}

+ (void)deleteCacheImages
{
    //删除上次缓存的文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *folderPath = [cachePath stringByAppendingPathComponent:@"cameraCache"];
    if ([fileManager fileExistsAtPath:folderPath]) {
        [fileManager removeItemAtPath:folderPath error:&error];
    }
}

+ (void)createCacheFloder
{
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *folderPath = [cachePath stringByAppendingPathComponent:@"cameraCache"];
    //删除上次缓存的文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if (![fileManager fileExistsAtPath:folderPath]) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
}

+ (void)showWaitingDialogWithMsg:(NSString *)msg container:(UIView *)containerView
{
    CGFloat contentWidth = 120;
    
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, contentWidth)];
    content.center = containerView.center;
    content.tag = WAIT_CONTENT_TAG;
    content.backgroundColor = [UIColor blackColor];
    content.alpha = 0.8f;
    content.layer.cornerRadius = 8;
    [containerView addSubview:content];
    
    CGFloat width = contentWidth;
    CGFloat height = 70;
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 10, width, height)];
    activityView.color = [UIColor whiteColor];
    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activityView.tag = WAITING_TAG;
    [content addSubview:activityView];
    [activityView startAnimating];
    
    UILabel *Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, contentWidth, 20)];
    Label.font = [UIFont systemFontOfSize:17];
    Label.textColor = [UIColor whiteColor];
    Label.textAlignment = NSTextAlignmentCenter;
    Label.text = msg;
    [content addSubview:Label];
}

+ (void)dismissWaitingDialogOnContainer:(UIView *)containerView
{
    UIView *mask = [containerView viewWithTag:MASK_TAG];
    UIView *content = [containerView viewWithTag:WAIT_CONTENT_TAG];
    UIView *waitingView = [containerView viewWithTag:WAITING_TAG];
    
    if (mask) {
        [mask removeFromSuperview];
    }
    
    if (content) {
        [content removeFromSuperview];
    }
    
    if (waitingView) {
        [waitingView removeFromSuperview];
    }
}

+ (void)showMessage:(NSString *)msg container:(UIView *)containerView
{
    UILabel *label = [[UILabel alloc] init];
    label.text = msg;
    label.font = [UIFont systemFontOfSize:15.f];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    
    label.layer.cornerRadius = 3.f;
    label.layer.masksToBounds = YES;
    
    CGSize size = [msg boundingRectWithSize:CGSizeMake(200.0f,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : label.font} context:nil].size;
    
    CGFloat width = size.width + 10 * 2;
    CGFloat height = size.height + 20;
    
    label.frame = CGRectMake((CGRectGetWidth(containerView.frame) - width) / 2, (CGRectGetHeight(containerView.frame) - height)/2, width, height);
    [containerView addSubview:label];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:1.0f animations:^{
            label.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    });
    
}
@end
