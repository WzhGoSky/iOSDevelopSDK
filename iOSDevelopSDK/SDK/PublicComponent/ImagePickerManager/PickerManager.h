//
//  PickerManger.h
//  TZImagePickerController
//
//  Created by Hayder on 2018/9/7.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PickerConfig.h"
#import "PickerManagerConfig.h"

@class PickerModel,PickerManagerConfig;

@interface PickerManager : NSObject

/**
 图片选择
 根据配置来显示选择 相册 、拍照、小视频
 type：
 PickerMangerTypeAlbum                                                         = 1 << 0,//相册
 PickerMangerTypeTakePhoto                                                          = 1 << 1,//拍照
 PickerMangerTypeShortVideo                                                  = 1 << 2,//短视频拍摄
 取消永远存在
 
 delegate: 代理自定义事件
 config: 配置
 selectArray: 选中数组
 complete：完成回调
 */
+(void)showPickerWithdelegate:(id<PickerManagerDelegate>)delegate config:(PickerManagerConfig *)config selectArray:(NSMutableArray<PickerModel *> *)modelArray containView:(UIView *)view complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete;

/**
 图片选择 无需代理
 config: 配置
 selectArray: 选中数组
 complete：完成回调
 */
+(void)showPickerWithConfig:(PickerManagerConfig *)config selectArray:(NSMutableArray<PickerModel *> *)modelArray containView:(UIView *)view complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete;

/**
 直接相册
 config: 配置
 selectArray: 选中数组
 complete：完成回调
 */
+(void)onlyShowAlbumWithSelectArray:(NSMutableArray<PickerModel *> *)modelArray complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete;
/**
 直接拍照
 config: 配置
 selectArray: 选中数组
 complete：完成回调
 */
+(void)onlyShowTakePhotoWithSelectArray:(NSMutableArray<PickerModel *> *)modelArray complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete;
/**
 直接短视频
 config: 配置
 selectArray: 选中数组
 complete：完成回调
 */
+(void)onlyShowShortVideoWithSelectArray:(NSMutableArray<PickerModel *> *)modelArray complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete;

/**
 直接跳转     相册/拍照/短视频，需要自己配置
 config: 配置
 selectArray: 选中数组
 complete：完成回调
 */
+(void)onlyShowWithConfig:(PickerManagerConfig *)config selectArray:(NSMutableArray<PickerModel *> *)modelArray complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete;

/**
 图片预览
 index： 当前展示索引
 canEdit： 是否可以编辑
 */
+(void)onlyShowPreviewWithSelectArray:(NSMutableArray<PickerModel *> *)modelArray index:(NSInteger)index canEdit:(BOOL)canEdit  complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete;

/**
 图片预览
 selectAssets：选中数据源（PHAsset类型）
 selectPhotos: 选中数据源（img）
 index： 当前展示索引
 canEdit： 是否可以编辑
 */
+(void)onlyShowPreviewWithSelectArray:(NSMutableArray *)selectAssets selectPhotos:(NSMutableArray *)selectPhotos index:(NSInteger)index canEdit:(BOOL)canEdit complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete;

@end
