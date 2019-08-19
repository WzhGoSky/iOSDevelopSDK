//
//  HHVideoEditService.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/7/27.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHVideoEditService.h"
#import "globalDefine.h"

@implementation HHVideoEditService

+ (void)clipVideoWithVideoAssest:(AVAsset *)videoAsset startTime:(CGFloat)startTime endTime:(CGFloat)endTime completion:(void (^)(NSURL* outputPath, NSError *error))completion {

    // 设置裁剪时间
    CMTime start = CMTimeMakeWithSeconds(startTime, videoAsset.duration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(endTime - startTime, videoAsset.duration.timescale);
    CMTimeRange timeRange = CMTimeRangeMake(start, duration);
    
    AVMutableVideoComposition *videoComposition = [self fixVideoOrientationWithAsset:videoAsset];
    
    [self exportVideoWithVideoAsset:videoAsset videoComposition:videoComposition timeRange:timeRange completion:^(NSURL *outputPath, NSError *error) {
    
        if (completion) {
            completion(outputPath,error);
        }
    }];
    
}

+ (void)addWaterMaskToVideoAssest:(AVAsset *)videoAssest waterMaskImage:(UIImage *)waterMask completion:(void (^)(NSURL *outputPath, NSError *error))completion {
    
    AVMutableVideoComposition *videoComposition = [self fixVideoOrientationWithAsset:videoAssest];
    
    //创建水印图层Layer并设置frame和水印的位置，并将水印加入视频组合器中
    // 总的layer,----承载layer
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoComposition.renderSize.width, videoComposition.renderSize.height); // 视频的尺寸
    // 视频的layer----
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(0, 0, videoComposition.renderSize.width, videoComposition.renderSize.height);
    [parentLayer addSublayer:videoLayer];
    // 水印层+
    CALayer *watermarkLayer = [CALayer layer];
    watermarkLayer.contents = (id) waterMask.CGImage;
    // 控制当视频预览界面拉伸时，添加水印不会偏移
    watermarkLayer.bounds = CGRectMake(0, 0, waterMask.size.width * videoComposition.renderSize.height / waterMask.size.height, videoComposition.renderSize.height);
    watermarkLayer.position = CGPointMake(videoComposition.renderSize.width * 0.5, videoComposition.renderSize.height * 0.5);
    [parentLayer addSublayer:watermarkLayer];
    
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    [self exportVideoWithVideoAsset:videoAssest videoComposition:videoComposition timeRange:CMTimeRangeMake(kCMTimeZero, videoAssest.duration) completion:^(NSURL *outputPath, NSError *error) {
       
        if (completion) {
            completion(outputPath,error);
        }
    }];
}

// 修正视频方向
+ (AVMutableVideoComposition *)fixVideoOrientationWithAsset:(AVAsset *)videoAsset {
    
    //1,可以用来对视频进行操作,用来生成video的组合指令，包含多段instruction
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
    AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    // 视频转向
    int degrees = [self degressFromVideoFileWithAsset:videoAsset];
    
    CGAffineTransform translateToCenter;
    CGAffineTransform mixedTransform;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    videoComposition.renderSize = videoTrack.naturalSize;
    
    // 一个指令，决定一个timeRange内每个轨道的状态，包含多个layerInstruction
    AVMutableVideoCompositionInstruction *roateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
    
    // 在一个指令的时间范围内，某个轨道的状态
    AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    if (degrees == 90) // UIImageOrientationRight
    {
        // 顺时针旋转90°
        NSLog(@"%f--%f",videoTrack.naturalSize.width,videoTrack.naturalSize.height);
        translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
        mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI_2);
        videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
        [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
    }
    else if (degrees == 180) // UIImageOrientationDown
    {
        // 顺时针旋转180°
        translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
        mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI);
        videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
        [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
    }
    else if (degrees == 270) // UIImageOrientationLeft
    {
        // 顺时针旋转270°
        translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
        mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI_2 * 3.0);
        videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
        [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
    }
    // 方向是 0 不做处理
    
    roateInstruction.layerInstructions = @[roateLayerInstruction];
    videoComposition.instructions = @[roateInstruction]; // 加入视频方向信息
    
    return videoComposition;
}

/// 获取视频角度
+ (int)degressFromVideoFileWithAsset:(AVAsset *)asset
{
    int degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo]; //获取轨道资源
    if ([tracks count] > 0)
    {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform; // 处理形变的类型
        if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
        {
            //     x = -y / y = x  逆时针旋转 90 度
            degress = 90; //UIImageOrientationRight
        }
        else if (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)
        {
            //     x = y / y = -x    逆时针旋转 270 度
            degress = 270; // UIImageOrientationLeft
        }
        else if (t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
        {
            //   x = y / y = y         向右 ------ 旋转0度
            degress = 0; //UIImageOrientationUp
        }
        else if (t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
        {
            // LandscapeLeft     x = -x / y = -y   逆时针旋转180
            degress = 180; //UIImageOrientationDown
        }
    }
    return degress;
    /*
     [a b   0]
     [c d    0]
     [tx ty   1]
     x = ax + cy + tx
     y = bx + dy + ty
     其中tx---x轴方向--平移,ty---y轴方向平移;a--x轴方向缩放,d--y轴缩放;abcd共同控制旋转
     */
}

// 导出视频
+ (void)exportVideoWithVideoAsset:(AVAsset *)videoAsset videoComposition:(AVVideoComposition *)videoComposition timeRange:(CMTimeRange)timeRange completion:(void (^)(NSURL *outputPath, NSError *error))completion {
    
    // 创建输出的路径
    NSURL *outputURL = [self getExportVideoPathForType:@"mp4"];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality])
    {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                               initWithAsset:videoAsset
                                               presetName:AVAssetExportPresetHighestQuality]; //AVAssetExportPresetPassthrough可能返回没有处理过的视频
        //截取时间
        exportSession.timeRange = timeRange;
        
//        if (videoComposition.renderSize.width) {
            // 注意方向是 0 不要做处理否则会导出失败
            exportSession.videoComposition = videoComposition; // 修正视频转向
//        }
        
        exportSession.outputURL = outputURL;             // 输出URL
        exportSession.shouldOptimizeForNetworkUse = YES; // 优化网络
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        NSArray *supportedTypeArray = exportSession.supportedFileTypes; //支持的格式
        if ([supportedTypeArray containsObject:AVFileTypeMPEG4])        //MP4
        {
            exportSession.outputFileType = AVFileTypeMPEG4;
        }
        else if (supportedTypeArray.count == 0)
        {
            NSError *error = [NSError errorWithDomain:@"视频类型不支持导出" code:0 userInfo:nil];
            if (completion)
            {
                completion(nil, error);
            }
            return;
        }
        else
        {
            exportSession.outputFileType = [supportedTypeArray objectAtIndex:0];
        }
        
        // 开始异步导出视频
        __block NSError *error;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (exportSession.status)
                {
                    case AVAssetExportSessionStatusUnknown:
                    {
                        error = [NSError errorWithDomain:@"AVAssetExportSessionStatusUnknown" code:0 userInfo:nil];
                        if (completion)
                        {
                            completion(nil, error);
                        }
                        break;
                    }
                    case AVAssetExportSessionStatusWaiting:
                    {
                        error = [NSError errorWithDomain:@"AVAssetExportSessionStatusWaiting" code:0 userInfo:nil];
                        if (completion)
                        {
                            completion(nil, error);
                        }
                        break;
                    }
                    case AVAssetExportSessionStatusExporting:
                    {
                        error = [NSError errorWithDomain:@"AVAssetExportSessionStatusExporting" code:0 userInfo:nil];
                        if (completion)
                        {
                            completion(nil, error);
                        }
                        break;
                    }
                    case AVAssetExportSessionStatusCompleted:
                    {
                        if (completion)
                        {
                            completion(outputURL, nil);
                        }
                        break;
                    }
                    case AVAssetExportSessionStatusFailed:
                    {
                        error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@:%@",@"导出失败",exportSession.error] code:0 userInfo:nil];
                        if (completion)
                        {
                            completion(nil, error);
                        }
                        break;
                    }
                    default:
                        break;
                }
            });
        }];
    }
}

// 创建视频路径，type: mp4等
+ (NSURL *)getExportVideoPathForType:(NSString *)type {
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *fileName = [NSString stringWithFormat:@"videoEditOutput%@.%@",[formater stringFromDate:[NSDate date]],type];
    NSURL *outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    
    return outputURL;
}

@end
