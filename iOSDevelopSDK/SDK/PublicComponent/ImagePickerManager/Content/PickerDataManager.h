//
//  PickerDataManager.h
//  test
//
//  Created by Hayder on 2018/9/9.
//  Copyright © 2018年 Hayder. All rights reserved.
//    数据相关处理类

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@class PickerModel;
@interface PickerDataManager : NSObject

/**
 根据编辑图片生成模型
 */
+(void)getEditPhotoModelWithImage:(UIImage *)image complete:(void(^)(PickerModel *model))complete;

/**
 异步处理图片
 */
+ (void)getPhotoModelArrWithAssets:(NSMutableArray *)assets imageArr:(NSMutableArray <UIImage *>*)imgArr result:(void (^) (NSMutableArray <PickerModel *>* modelArr,NSMutableArray *assets, NSMutableArray *photos))result;

+(void)savePhotoWithImages:(NSMutableArray *)imgs  result:(void (^) (NSMutableArray <PickerModel *>* modelArr,NSMutableArray *assets, NSMutableArray *photos))result;

/**
 根据图片PHAsset 创建模型
 */
+(void)createImageModelWithPHAsset:(PHAsset *)asset complete:(void(^)(PickerModel *model))complete;

/**
 根据视屏 PHAsset 创建模型
 */
+(void)createAVAssetModelWithPHAsset:(PHAsset *)asset option:(PHVideoRequestOptions *)options image:(UIImage *)originImage complete:(void(^)(PickerModel *model))complete;



@end
