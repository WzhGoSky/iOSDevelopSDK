//
//  ImageShowToolManager.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/9/23.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "ImageShowToolManager.h"
#import "ImageShowConfig.h"
#import "ImageShowHelper.h"
#import <YYImage/YYImage.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "globaldefine.h"
#import <SDWebImage/SDWebImage.h>
#import "DrawingManager.h"
@implementation ImageShowToolManager

#pragma mark -----------------                       图片下载                     -----------------

+(void)ImageShowDownLoadImgWithUrl:(NSString *)imgUrl img:(UIImage *)img originalImgUrl:(NSString *)originalUrl isOriginal:(BOOL)isOriginal savedFinfish:(SEL)savedFinfish target:(id)completionTarget{
    
//    if (img) {
//        [self saveImageToPhotos:img savedFinfish:savedFinfish target:completionTarget];
//    }else{
        if (isOriginal) {//存在原图，下载原图
//            UIImage *originalImg = [[UIImage alloc]initWithContentsOfFile:image_path(originalUrl)];
//
//            if (originalImg) {
//                [self saveImageToPhotos:originalImg savedFinfish:savedFinfish target:completionTarget];
//            }else{
            [self downImageWithUrl:[NSURL URLWithString:originalUrl] savedFinfish:savedFinfish target:completionTarget];
//            }
        }else{//不存在原图，下载缩略图
//            UIImage *small = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey: imgUrl];
//            if (small) {
//                [self saveImageToPhotos:small savedFinfish:savedFinfish target:completionTarget];
//            }else{
            
            if (imgUrl.length) {
                [self downImageWithUrl:[NSURL URLWithString: imgUrl] savedFinfish:savedFinfish  target:completionTarget];
            }else{
                [self saveImageToPhotos:img savedFinfish:savedFinfish target:completionTarget];
            }
//            }
        }
//    }
}

+(void)saveImageToPhotos:(UIImage*)savedImage savedFinfish:(SEL)savedFinfish target:(id)completionTarget
{
    UIImageWriteToSavedPhotosAlbum(savedImage, completionTarget, savedFinfish, NULL);
}

+(void)downImageWithUrl:(NSURL *)url savedFinfish:(SEL)savedFinfish target:(id)completionTarget{
    [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:url options:SDWebImageDownloaderProgressiveLoad progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                
                [ImageShowHelper showMessage:@"保存到相册失败" container:[self getCurrentController].view];
            }else{
                if (finished && image) {
                    
                    if ([url.absoluteString containsString:@".gif"] ) {
                        ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
                        NSDictionary *metadata = @{@"UTI": (__bridge NSString *)kUTTypeGIF};
                        [library writeImageDataToSavedPhotosAlbum:data metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
                            if (error) {
                                [ImageShowHelper showMessage:@"保存到相册失败" container:[UIApplication sharedApplication].keyWindow];
                            }else{
                                
                                [ImageShowHelper showMessage:@"保存到相册成功" container:[UIApplication sharedApplication].keyWindow];
                            }
                        }];
                    }else{
                        [self saveImageToPhotos:image savedFinfish:savedFinfish target:completionTarget];
                    }
                    
                }
            }
        });
    }];
}

+(void)ImageShowOriginalImg:(NSString *)originalUrl complete:(void(^)(UIImage *originalImg))complete porgress:(void(^)(NSString *stateTitle))progress{
    
    if (!originalUrl.length) {return;}
    
    __block NSString *stateTitle = @"加载原图中";
    
    UIImage *image = [[UIImage alloc]initWithContentsOfFile:image_path(originalUrl)];
    if (image) {//如果下载过原图
        stateTitle = @"已完成";
        
        !progress?:progress(stateTitle);
        !complete?:complete(image);
        
    }else{
        stateTitle = @"加载原图中";
        !progress?:progress(stateTitle);
        
        NSString *imageDir = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject],folderName];
        BOOL isDir = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
        if ( !(isDir == YES && existed == YES) )
        {
            [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:originalUrl] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            stateTitle = [NSString stringWithFormat:@"%zd%%",receivedSize  * 100/expectedSize];
            
            !progress?:progress(stateTitle);
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (error) {
                stateTitle = @"加载失败";
                !progress?:progress(stateTitle);
            }else{
                
                if (finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (error) {
                            stateTitle = @"加载失败";
                            !progress?:progress(stateTitle);
                        }else{
                            
                            stateTitle = @"加载成功";
                            [data writeToFile:image_path(originalUrl) atomically:YES];
                            
                            UIImage *newImg = nil;
                            if ([originalUrl containsString:@".gif"]) {
                                newImg = [YYImage imageWithData:data];
                            }else{
                                newImg = [[UIImage alloc]initWithContentsOfFile:image_path(originalUrl)];
                            }
                            
                            !progress?:progress(stateTitle);
                            !complete?:complete(newImg);
                        }
                    });
                }
            }
        }];
    }

}


#pragma mark -----------------                       短视频下载                     -----------------
+(void)ImageShowDownLoadVideoWithUrl:(NSString *)videoUrl HUDInView:(UIView *)view savedFinfish:(SEL)savedFinfish target:(id)completionTarget{
    
//    OSSDownloadModel *model = [[OSSDownloadModel alloc]init];
//    model.fileURL = videoUrl;
//
//    [[OSSDownloadCenter instance] downloadWithModelFiles:@[model] HUDInView:view Completion:^(BOOL isSuccessed, NSArray<OSSDownloadModel *> *fileModels) {
//
//        if (isSuccessed) {
//
//            OSSDownloadModel *saveModel = fileModels.lastObject;
//            NSURL *url = [NSURL URLWithString:saveModel.fileLocalpath];
//            BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([url path]);
//            if (compatible)
//            {
//                //保存相册核心代码
//                UISaveVideoAtPathToSavedPhotosAlbum([url path], completionTarget, savedFinfish, NULL);
//            }
//        }else{
//            [ImageShowHelper showMessage:LocalizedString(@"shipingxiazaishibai", nil) container:[UIApplication sharedApplication].keyWindow];
//        }
//
//    }];
    
}


#pragma mark -----------------                       图片编辑                      -----------------
/**
 编辑图片
 */
+(void)ImageShowEidtImage:(UIImage *)img savedFinfish:(SEL)savedFinfish target:(id)completionTarget{
       
    [DrawingManager showSingleDrawing:img type:(DoodleBoardHandleEidt | DoodleBoardHandleSignature | DoodleBoardHandleTailoring | DoodleBoardHandleCode) cancelBlock:^{
        
    } completeBlock:^(UIImage *editImage) {
        if (editImage) {
            [self saveImageToPhotos:editImage savedFinfish:savedFinfish target:completionTarget];
        }
    }];
    
}

+ (UIViewController *)getCurrentController {
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    if (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    if (topVC) {
        return topVC;
    }else{
        UIViewController *result = nil;
        
        
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        if (window.windowLevel != UIWindowLevelNormal)
        {
            NSArray *windows = [[UIApplication sharedApplication] windows];
            for(UIWindow * tmpWin in windows)
            {
                if (tmpWin.windowLevel == UIWindowLevelNormal)
                {
                    window = tmpWin;
                    break;
                }
            }
        }
        
        UIView *frontView = [[window subviews] objectAtIndex:0];
        id nextResponder = [frontView nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
            result = nextResponder;
        else
            result = window.rootViewController;
        
        return result;
    }
    
}

+ (UIViewController *)getPresentController {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *hostVC = rootVC;
    while (hostVC.presentedViewController) {
        hostVC = hostVC.presentedViewController;
    }
    hostVC = hostVC ?: rootVC;
    return hostVC;
}

@end
