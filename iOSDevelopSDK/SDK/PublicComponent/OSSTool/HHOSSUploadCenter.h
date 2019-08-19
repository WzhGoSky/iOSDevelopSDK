//
//  HHOSSUploadCenter.h
//  HHForAppStore
//
//  Created by Hayder on 2018/9/10.
//  Copyright © 2018年 Hayder. All rights reserved.
//  图片上传中心

#import <Foundation/Foundation.h>
#import "HHOSSUploadModel.h"
#import "HHOSSUploadAble.h"
#import <AliyunOSSiOS/AliyunOSSiOS.h>

@interface HHOSSUploadCenter : NSObject


+ (instancetype)sharedInstance;

/**
 适用于只有照片，图片，的url
 上传图片,视频,文件到OSS服务器 
 @param models 需要上传的对象数组
 @param completion 完成
 @param view 进度放置的View  传nil默认全屏
 */
- (void)uploadResourceInArray:(NSArray <HHOSSUploadModel *>*)models HUDInView:(UIView *)view Completion:(void (^)(BOOL isSuccessed,NSArray <HHOSSUploadModel *> *totalList,NSArray <HHOSSUploadModel *> *failedList)) completion;


/**
 自身已有对象，想做资源上传但不想创建对象
 上传图片,视频,文件到OSS服务器
 @param models 需要上传的对象数组
 @param completion 完成
 @param view 进度放置的View  传nil默认全屏
 */
- (void)uploadResources:(NSArray <id<HHOSSUploadAble>>*)models HUDInView:(UIView *)view Completion:(void (^)(BOOL isSuccessed,NSArray <id<HHOSSUploadAble>> *totalList,NSArray <id<HHOSSUploadAble>> *failedList)) completion;


- (void)addUploadRequest:(OSSPutObjectRequest *)request ToTaskPoolWithKey:(NSString *)string;
- (void)removeUploadRequestWithKey:(NSString *)string;

@end
