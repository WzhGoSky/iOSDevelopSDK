//
//  PickerDataManager.m
//  test
//
//  Created by Hayder on 2018/9/9.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "PickerDataManager.h"
#import "TZImageManager.h"
#import "PickerModel.h"
#import "UIImage+Extension.h"
#import <SDWebImage/SDWebImage.h>
#define folderName @"/video"

@implementation PickerDataManager

+(void)handleOneGroupAsyncWithGroup:(dispatch_group_t) group withQueue:(dispatch_queue_t)queue images:(NSMutableDictionary *)images resArray:( NSMutableDictionary *)resArray  result:(void (^) (NSMutableArray <PickerModel *>* modelArr,NSMutableArray *assets, NSMutableArray *photos))result{
    
    dispatch_group_async(group, queue, ^{
        
        NSArray *keysArray = [self getDescendArrayWithDict:images];
        
        NSString *key = keysArray[resArray.allKeys.count];
        UIImage *originImage = [images valueForKey:key];
        
        if ([originImage isKindOfClass:[UIImage class]]) {
            [self getEditPhotoModelWithImage:originImage complete:^(PickerModel *model) {
                [resArray setObject:model forKey:key];
                if (resArray.allKeys.count == images.allKeys.count) {
                    dispatch_group_leave(group);
                    return;
                }else{
                    [self handleOneGroupAsyncWithGroup:group withQueue:queue images:images resArray:resArray result:result];
                }
            }];
        }else if ([originImage isKindOfClass:[NSString class]]){
            [self downLoadPhotoModelWithImgStr:(NSString *)originImage complete:^(PickerModel *model) {
                [resArray setObject:model forKey:key];
                if (resArray.allKeys.count == images.allKeys.count) {
                    dispatch_group_leave(group);
                    return;
                }else{
                    [self handleOneGroupAsyncWithGroup:group withQueue:queue images:images resArray:resArray result:result];
                }
            }];
        }
        
     
    });
}

+(void)savePhotoWithImages:(NSMutableArray *)imgs  result:(void (^) (NSMutableArray <PickerModel *>* modelArr,NSMutableArray *assets, NSMutableArray *photos))result{
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSMutableDictionary *imgArray1 = [NSMutableDictionary dictionary];
    NSMutableDictionary *imgArray2 = [NSMutableDictionary dictionary];
    
    [imgs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx % 2 == 0){
            [imgArray1 setObject:imgs[idx] forKey:[NSString stringWithFormat:@"%ld",idx]];
        }
        if (idx % 2 == 1){
            [imgArray2 setObject:imgs[idx] forKey:[NSString stringWithFormat:@"%ld",idx]];
        }
    }];
    
    __block NSMutableDictionary *resArray1 = [NSMutableDictionary dictionary];
    __block  NSMutableDictionary *resArray2 = [NSMutableDictionary dictionary];
    
    dispatch_group_enter(group);
    [self handleOneGroupAsyncWithGroup:group withQueue:queue images:imgArray1 resArray:resArray1 result:^(NSMutableArray<PickerModel *> *modelArr, NSMutableArray *assets, NSMutableArray *photos) {
        
    }];
    
    if (imgArray2.count > 0) {
        dispatch_group_enter(group);
        [self handleOneGroupAsyncWithGroup:group withQueue:queue images:imgArray2 resArray:resArray2 result:^(NSMutableArray<PickerModel *> *modelArr, NSMutableArray *assets, NSMutableArray *photos) {
            
        }];
    }
    
    //这里开3个线程来上传图片
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        NSMutableDictionary *res = [NSMutableDictionary dictionary];
        [res setValuesForKeysWithDictionary:resArray1];
        [res setValuesForKeysWithDictionary:resArray2];
        
        //排序
//        !complete?:complete([self DescendDataWithDict:res]);
        
        [self descendDataWithDict:res compete:^(NSMutableArray *models, NSMutableArray *assets, NSMutableArray *photos) {
            
            !result?:result(models, assets, photos);
            
        }];
    });
}

+(void)downLoadPhotoModelWithImgStr:(NSString *)imgUrl complete:(void(^)(PickerModel *model))complete{
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imgUrl] options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (image) {
            [self getEditPhotoModelWithImage:image complete:^(PickerModel *model) {
                !complete?:complete(model);
            }];
        }else{
            !complete?:complete([NSNull null]);
        }
        
    }];
}

+(void)getEditPhotoModelWithImage:(UIImage *)image complete:(void(^)(PickerModel *model))complete{
    
    [[TZImageManager manager] savePhotoWithImage:image completion:^(PHAsset *asset, NSError *error) {
        
        [self createImageModelWithPHAsset:asset complete:^(PickerModel *model) {
            !complete?:complete(model);
        }];
        
    }];
}

+ (void)getPhotoModelArrWithAssets:(NSMutableArray *)assets imageArr:(NSMutableArray <UIImage *>*)imgArr result:(void (^) (NSMutableArray <PickerModel *>* modelArr,NSMutableArray *assets, NSMutableArray *photos))result{
    
    [self handlePhotoModelArrWithAssets:assets imageArr:imgArr result:result];
    
    return;
}

+ (void)handlePhotoModelArrWithAssets:(NSMutableArray *)assets imageArr:(NSMutableArray <UIImage *>*)imgArr  result:(void (^) (NSMutableArray <PickerModel *>* modelArr,NSMutableArray *assets, NSMutableArray *photos))result{
    
    if (assets.count == 0 && imgArr.count == 0) {
        !result?:result([NSMutableArray array], [NSMutableArray array], [NSMutableArray array]);
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSMutableDictionary *assetArray1 = [NSMutableDictionary dictionary];
    NSMutableDictionary *assetArray2 = [NSMutableDictionary dictionary];
    NSMutableDictionary *assetArray3 = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *imgArray1 = [NSMutableDictionary dictionary];
    NSMutableDictionary *imgArray2 = [NSMutableDictionary dictionary];
    NSMutableDictionary *imgArray3 = [NSMutableDictionary dictionary];
    
    [assets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx % 3 == 0){
            [assetArray1 setObject:obj forKey:[NSString stringWithFormat:@"%ld",idx]];
            [imgArray1 setObject:imgArr[idx] forKey:[NSString stringWithFormat:@"%ld",idx]];
        }
        if (idx % 3 == 1){
            [assetArray2 setObject:obj forKey:[NSString stringWithFormat:@"%ld",idx]];
            [imgArray2 setObject:imgArr[idx] forKey:[NSString stringWithFormat:@"%ld",idx]];
        }
        if (idx % 3 == 2){
            [assetArray3 setObject:obj forKey:[NSString stringWithFormat:@"%ld",idx]];
            [imgArray3 setObject:imgArr[idx] forKey:[NSString stringWithFormat:@"%ld",idx]];
        }
    }];
    
    __block NSMutableDictionary *resArray1 = [NSMutableDictionary dictionary];
    __block  NSMutableDictionary *resArray2 = [NSMutableDictionary dictionary];
    __block NSMutableDictionary *resArray3 = [NSMutableDictionary dictionary];
    
    dispatch_group_enter(group);
    [self handleOneGroupAsyncWithGroup:group withQueue:queue Assets:assetArray1 imageArr:imgArray1 resArray:resArray1 complete:^{}];
    
    if (assetArray2.count > 0) {
        dispatch_group_enter(group);
        [self handleOneGroupAsyncWithGroup:group withQueue:queue Assets:assetArray2 imageArr:imgArray2 resArray:resArray2 complete:^{}];
    }
    
    if (assetArray3.count > 0) {
        dispatch_group_enter(group);
        [self handleOneGroupAsyncWithGroup:group withQueue:queue Assets:assetArray3 imageArr:imgArray3 resArray:resArray3 complete:^{}];
    }
    
    //这里开3个线程来上传图片
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        NSMutableDictionary *res = [NSMutableDictionary dictionary];
        [res setValuesForKeysWithDictionary:resArray1];
        [res setValuesForKeysWithDictionary:resArray2];
        [res setValuesForKeysWithDictionary:resArray3];
        
        
//        NSArray *result = [self DescendDataWithDict:res];
        
        //排序
//        !result?:result([self DescendDataWithDict:res]);
        
        [self descendDataWithDict:res compete:^(NSMutableArray *models, NSMutableArray *assets, NSMutableArray *photos) {
            
            !result?:result(models, assets, photos);
            
        }];
        
    });
    
}

+(void)descendDataWithDict:(NSMutableDictionary *)dict compete:(void(^)(NSMutableArray *models, NSMutableArray *assets, NSMutableArray *photos))complete{
    NSArray *keys = [self getDescendArrayWithDict:dict];
    
    NSMutableArray *temp = [NSMutableArray array];
    for (NSString *obj in keys) {
        [temp addObject:[dict valueForKey:obj]];
    }
    
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *photots = [NSMutableArray array];
    
    for (PickerModel *model in temp) {
        if (model.asset) {
            [assets addObject:model.asset];
        }
        
        if (model.image) {
            [photots addObject:model.image];
        }
    }
    !complete?:complete(temp, assets, photots);
    
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

+(void)handleOneGroupAsyncWithGroup:(dispatch_group_t) group withQueue:(dispatch_queue_t)queue Assets:(NSMutableDictionary *)assets imageArr:(NSMutableDictionary *)imgArr resArray:( NSMutableDictionary *)resArray complete:(void(^)())complete{
    //    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        
        NSArray *keysArray = [self getDescendArrayWithDict:assets];
        
        NSString *key = keysArray[resArray.allKeys.count];
        
        PHAsset *phast = [assets valueForKey:key];
        UIImage *originImage = [imgArr valueForKey:key];
        
        if (![originImage isKindOfClass:[UIImage class]] || ![phast isKindOfClass:[PHAsset class]]) {dispatch_group_leave(group); return;}
        if (phast.mediaType == PHAssetMediaTypeVideo) {
            
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc]init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        
            [self createAVAssetModelWithPHAsset:phast option:options image:originImage complete:^(PickerModel *model) {
                [resArray setObject:model forKey:key];
                
                if (resArray.allKeys.count == assets.allKeys.count) {
                    dispatch_group_leave(group);
                    return;
                }else{
                    [self handleOneGroupAsyncWithGroup:group withQueue:queue Assets:assets imageArr:imgArr resArray:resArray complete:complete];
                }
            }];
        }else{
            
            [self createImageModelWithPHAsset:phast complete:^(PickerModel *model) {
                
                [resArray setObject:model forKey:key];
                
                if (resArray.allKeys.count == assets.allKeys.count) {
                    dispatch_group_leave(group);
                    return;
                }else{
                    [self handleOneGroupAsyncWithGroup:group withQueue:queue Assets:assets imageArr:imgArr resArray:resArray complete:complete];
                }
            }];
        }
        
    });
}

+(void)createAVAssetModelWithPHAsset:(PHAsset *)preAsset option:(PHVideoRequestOptions *)options image:(UIImage *)originImage complete:(void(^)(PickerModel *model))complete{
    
    [[PHImageManager defaultManager]requestAVAssetForVideo:preAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        
        [[TZImageManager manager] getVideoOutputPathWithAsset:preAsset success:^(NSString *outputPath) {
            PickerModel *model = [[PickerModel alloc]init];
            model.asset = preAsset;
            model.image = originImage;
            model.isVideo = YES;
            model.hadOriginal = NO;
            model.videoPath = outputPath;
            model.videoAsset = asset;
            model.videoDuration = CMTimeGetSeconds(asset.duration);
            !complete?:complete(model);
        } failure:^(NSString *errorMessage, NSError *error) {
            
        }];
    }];
}

+(void)createImageModelWithPHAsset:(PHAsset *)asset complete:(void(^)(PickerModel *model))complete{
    
    [[PHImageManager defaultManager]requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        PickerModel *model = [PickerModel modelWithAsset:asset originImageData:imageData originalFileName:@"netWork2" lowImageFileName:@"netWork"];
        !complete?:complete(model);
        
    }];
}



@end
