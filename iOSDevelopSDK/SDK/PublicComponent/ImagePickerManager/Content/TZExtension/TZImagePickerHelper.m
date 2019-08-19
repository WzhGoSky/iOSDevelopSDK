//
//  TZImagePickerHelper.m
//  PublicComponent
//
//  Created by Hayder on 2018/10/11.
//

#import "TZImagePickerHelper.h"
#import "TZAssetModel.h"
#import "TZImageManager.h"
#import "TZImagePickerController.h"
#import "PickerModel.h"
#import "UIView+ImagePickerExtension.h"
#import "NSObject+Extension.h"
#import "HHVideoCameraHelper.h"
#import "globalDefine.h"
@implementation TZImagePickerHelper

+(void)photoPickerHandleModels:(NSMutableArray<TZAssetModel *> *)models photoWidth:(CGFloat)photoWidth complete:(void(^)(NSArray<PickerModel *> *))complete{
  
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSMutableDictionary *array1 = [NSMutableDictionary dictionary];
    NSMutableDictionary *array2 = [NSMutableDictionary dictionary];
    NSMutableDictionary *array3 = [NSMutableDictionary dictionary];
    
    [models enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx % 3 == 0){
            [array1 setObject:obj forKey:[NSString stringWithFormat:@"%lu",(unsigned long)idx]];
        }
        if (idx % 3 == 1){
            [array2 setObject:obj forKey:[NSString stringWithFormat:@"%lu",(unsigned long)idx]];
        }
        if (idx % 3 == 2){
            [array3 setObject:obj forKey:[NSString stringWithFormat:@"%lu",(unsigned long)idx]];
        }
    }];
    
    __block NSMutableDictionary *resArray1 = [NSMutableDictionary dictionary];
    __block  NSMutableDictionary *resArray2 = [NSMutableDictionary dictionary];
    __block NSMutableDictionary *resArray3 = [NSMutableDictionary dictionary];
    
    
    dispatch_group_enter(group);
    [self handleOneGroupAsyncWithGroup:group withQueue:queue models:array1 resDict:resArray1 photoWidth:photoWidth complete:^{}];
    
    if (array2.count > 0) {
        dispatch_group_enter(group);
        [self handleOneGroupAsyncWithGroup:group withQueue:queue models:array2 resDict:resArray2 photoWidth:photoWidth complete:^{}];
    }
    
    if (array3.count > 0) {
        dispatch_group_enter(group);
        [self handleOneGroupAsyncWithGroup:group withQueue:queue models:array3 resDict:resArray3 photoWidth:photoWidth complete:^{}];
    }
    
    //这里开3个线程来上传图片
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
       
//        [[TZImagePickerHelper getCurrentController].view _hideActivityHUD];
        NSMutableDictionary *modelDict = [NSMutableDictionary dictionary];
        [modelDict setValuesForKeysWithDictionary:resArray1];
        [modelDict setValuesForKeysWithDictionary:resArray2];
        [modelDict setValuesForKeysWithDictionary:resArray3];

        [self DescendDataWithDict:modelDict complete:^(NSArray *datas, NSString *errorCount) {
            
            NSInteger errorC = models.count - datas.count;
            if (errorC > 0) {
                [[UIApplication sharedApplication].keyWindow.rootViewController.view showTextHUDWithPromptMessage:[NSString stringWithFormat:@"视频导出失败:%@!",errorC] andOffset_y:0 andMargin:10 andDuration:1.5];
            }
            
            !complete?:complete(datas);
            
        }];
    });
    
}

+(void)handleOneGroupAsyncWithGroup:(dispatch_group_t) group withQueue:(dispatch_queue_t)queue models:(NSMutableDictionary *)models resDict:( NSMutableDictionary *)resDict photoWidth:(CGFloat)photoWidth complete:(void(^)(void))complete{
    //    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        
        NSArray *keysArray = [self getDescendArrayWithDict:models];
        
        NSString *key = keysArray[resDict.allKeys.count];
        
        TZAssetModel *model = [models valueForKey:key];
        
        PHAsset *phast = model.asset;
        if (phast.mediaType == PHAssetMediaTypeVideo) {
            
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc]init];
            options.version = PHVideoRequestOptionsVersionOriginal;
            
            [self createAVAssetModelWithPHAsset:phast option:options complete:^(PickerModel *model) {
                
                [resDict setObject:model forKey:key];
                if (resDict.allKeys.count == models.allKeys.count) {
                    dispatch_group_leave(group);
                    return;
                }else{
                    [self handleOneGroupAsyncWithGroup:group withQueue:queue models:models resDict:resDict photoWidth:photoWidth complete:complete];
                }
            }];
        }else{
            
            [self createImageModelWithPHAsset:phast complete:^(PickerModel *model) {
                
               [resDict setObject:model forKey:key];
                
                if (resDict.allKeys.count == models.allKeys.count) {
                    dispatch_group_leave(group);
                    return;
                }else{
                    [self handleOneGroupAsyncWithGroup:group withQueue:queue models:models resDict:resDict photoWidth:photoWidth complete:complete];
                }
            }];
        }
    });
    
}

+(void)createImageModelWithPHAsset:(PHAsset *)asset complete:(void(^)(PickerModel *model))complete{
    
    [[PHImageManager defaultManager]requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        PickerModel *model = [PickerModel modelWithAsset:asset originImageData:imageData originalFileName:@"netWork2" lowImageFileName:@"netWork"];
        !complete?:complete(model);
        
    }];
}

+(void)cteateAgainAVAssetModelWithPHAsset:(PHAsset *)preAsset option:(PHVideoRequestOptions *)options complete:(void(^)(PickerModel *model))complete{
    [[TZImageManager manager] getVideoOutputPathWithAsset:preAsset success:^(NSString *outputPath) {
        
        if (outputPath.length) {
            [[TZImageManager manager] getPhotoWithAsset:preAsset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                if (!isDegraded) {
                    [[PHImageManager defaultManager]requestAVAssetForVideo:preAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        
                        PickerModel *model = [PickerModel modelWithAsset:preAsset originImageData:UIImageJPEGRepresentation(photo, 0) originalFileName:@"netWork2" lowImageFileName:@"netWork"];
                        model.isVideo = YES;
                        model.hadOriginal = NO;
                        model.videoPath = outputPath;
                        model.videoDuration = CMTimeGetSeconds(asset.duration);
                        model.videoAsset = asset;
                        !complete?:complete(model);
                        
//                        [[VideoCameraHelper getHelper] generateImagesInAsset:asset Completion:^(BOOL isSuccessed, NSString *imageURL) {
//                            model.gifPath = imageURL;
//                            !complete?:complete(model);
//                        }];
                    }];
                };
            }];
        }else{
            !complete?:complete([NSNull null]);
        }
    } failure:^(NSString *errorMessage, NSError *error) {
        !complete?:complete([NSNull null]);
    }];
}

+(void)createAVAssetModelWithPHAsset:(PHAsset *)preAsset option:(PHVideoRequestOptions *)options complete:(void(^)(PickerModel *model))complete{
    [[TZImageManager manager] getVideoOutputPathWithAsset:preAsset success:^(NSString *outputPath) {
        
        if (outputPath.length) {
            [[TZImageManager manager] getPhotoWithAsset:preAsset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                if (!isDegraded) {
                    [[PHImageManager defaultManager]requestAVAssetForVideo:preAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        
                        
                        PickerModel *model = [PickerModel modelWithAsset:preAsset originImageData:UIImageJPEGRepresentation(photo, 0) originalFileName:@"netWork2" lowImageFileName:@"netWork"];
                        
                        model.isVideo = YES;
                        model.hadOriginal = NO;
                        model.videoPath = outputPath;
                        model.videoDuration = CMTimeGetSeconds(asset.duration);
                        model.videoAsset = asset;
                        !complete?:complete(model);
                        
//                        [[VideoCameraHelper getHelper] generateImagesInAsset:asset Completion:^(BOOL isSuccessed, NSString *imageURL) {
//                            model.gifPath = imageURL;
//                            !complete?:complete(model);
//                        }];
                        
                    }];
                };
            }];
        }else{
            [self cteateAgainAVAssetModelWithPHAsset:preAsset option:options complete:complete];
        }
    } failure:^(NSString *errorMessage, NSError *error) {
        
        [self cteateAgainAVAssetModelWithPHAsset:preAsset option:options complete:complete];
    }];
}


+(void)DescendDataWithDict:(NSMutableDictionary *)dict complete:(void(^)(NSArray *datas, NSString *errorCount))complete{
    
    NSArray *keys = [self getDescendArrayWithDict:dict];
    NSString *errorCount = @"0";
    NSMutableArray *temp = [NSMutableArray array];
    for (NSString *obj in keys) {
        id model = [dict valueForKey:obj];
        if (![model isKindOfClass:[NSNull class]] && model) {
            [temp addObject:model];
        }else{
            errorCount = [NSString stringWithFormat:@"%ld", [errorCount integerValue] + 1];
        }
    }
    !complete?:complete(temp, errorCount);
}

+(NSArray *)DescendDataWithDict:(NSMutableDictionary *)dict{
    
    NSArray *keys = [self getDescendArrayWithDict:dict];
    
    NSMutableArray *temp = [NSMutableArray array];
    for (NSString *obj in keys) {
        [temp addObject:[dict valueForKey:obj]];
    }
    return temp;
}

+(NSArray *)getDescendArrayWithDict:(NSMutableDictionary *)dict{
    NSArray *keys = [dict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        int value1 = [obj1 intValue];
        int value2 = [obj2 intValue];
        if (value1 > value2) {
            return NSOrderedDescending;
        }else if (value1 == value2){
            return NSOrderedSame;
        }else{
            return NSOrderedAscending;
        }
    }];
    return keys;
}

+ (void)createCacheFloder
{
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *folderPath = [cachePath stringByAppendingPathComponent:@"TZPhotoCache"];
    //删除上次缓存的文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if (![fileManager fileExistsAtPath:folderPath]) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
}

+ (void)deleteCacheImages
{
    //删除上次缓存的文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *folderPath = [cachePath stringByAppendingPathComponent:@"TZPhotoCache"];
    if ([fileManager fileExistsAtPath:folderPath]) {
        [fileManager removeItemAtPath:folderPath error:&error];
    }
}

/**
 处理视屏 合成gif图片
 */
+(void)handlePickerDatas:(NSMutableArray<PickerModel *> *)modelDatas complete:(void(^)(NSMutableArray *datas))complete{
    
    if (modelDatas.count == 0) {
        !complete?:complete([NSMutableArray array]);
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSMutableDictionary *array1 = [NSMutableDictionary dictionary];
    NSMutableDictionary *array2 = [NSMutableDictionary dictionary];
    NSMutableDictionary *array3 = [NSMutableDictionary dictionary];
    
    [modelDatas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx % 3 == 0){
            [array1 setObject:obj forKey:[NSString stringWithFormat:@"%lu",(unsigned long)idx]];
        }
        if (idx % 3 == 1){
            [array2 setObject:obj forKey:[NSString stringWithFormat:@"%lu",(unsigned long)idx]];
        }
        if (idx % 3 == 2){
            [array3 setObject:obj forKey:[NSString stringWithFormat:@"%lu",(unsigned long)idx]];
        }
    }];
    
    __block NSMutableDictionary *resArray1 = [NSMutableDictionary dictionary];
    __block  NSMutableDictionary *resArray2 = [NSMutableDictionary dictionary];
    __block NSMutableDictionary *resArray3 = [NSMutableDictionary dictionary];
    
    
    dispatch_group_enter(group);
    [self handleOneGifGroupAsyncWithGroup:group withQueue:queue models:array1 resDict:resArray1 complete:^{}];
    
    if (array2.count > 0) {
        dispatch_group_enter(group);
        [self handleOneGifGroupAsyncWithGroup:group withQueue:queue models:array2 resDict:resArray2 complete:^{}];
    }
    
    if (array3.count > 0) {
        dispatch_group_enter(group);
        [self handleOneGifGroupAsyncWithGroup:group withQueue:queue models:array3 resDict:resArray3 complete:^{}];
    }
    
    //这里开3个线程来上传图片
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        NSMutableDictionary *modelDict = [NSMutableDictionary dictionary];
        [modelDict setValuesForKeysWithDictionary:resArray1];
        [modelDict setValuesForKeysWithDictionary:resArray2];
        [modelDict setValuesForKeysWithDictionary:resArray3];
        
        [self DescendDataWithDict:modelDict complete:^(NSArray *datas, NSString *errorCount) {
            
            NSInteger errorC = modelDatas.count - datas.count;
            if (errorC > 0) {
                [[UIApplication sharedApplication].keyWindow.rootViewController.view showTextHUDWithPromptMessage:[NSString stringWithFormat:@"%@%@",@"视频导出失败",errorC] andOffset_y:0 andMargin:10 andDuration:1.5];
            }
            
            !complete?:complete(datas);
            
        }];
    });
}


+(void)handleOneGifGroupAsyncWithGroup:(dispatch_group_t) group withQueue:(dispatch_queue_t)queue models:(NSMutableDictionary *)models resDict:( NSMutableDictionary *)resDict complete:(void(^)(void))complete{
    
    dispatch_group_async(group, queue, ^{
        
        NSArray *keysArray = [self getDescendArrayWithDict:models];
        
        NSString *key = keysArray[resDict.allKeys.count];
        
        PickerModel *model = [models valueForKey:key];
        
        if (model.isVideo) {
            [[HHVideoCameraHelper getHelper] generateImagesInAsset:model.videoAsset Completion:^(BOOL isSuccessed, NSString *imageURL) {
                model.gifPath = imageURL;
                [resDict setObject:model forKey:key];
                if (resDict.allKeys.count == models.allKeys.count) {
                    dispatch_group_leave(group);
                    return;
                }else{
                    [self handleOneGifGroupAsyncWithGroup:group withQueue:queue models:models resDict:resDict complete:complete];
                }
                
            }];
        }else{
            [resDict setObject:model forKey:key];
            
            if (resDict.allKeys.count == models.allKeys.count) {
                dispatch_group_leave(group);
                return;
            }else{
                [self handleOneGifGroupAsyncWithGroup:group withQueue:queue models:models resDict:resDict complete:complete];
            }
        }
    });
}

@end
