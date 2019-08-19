//
//  HHOSSNetWorkTool.h
//  HHForAppStore
//
//  Created by  ovopark_iOS1 on 2018/6/20.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunOSSiOS/OSSService.h>

@interface HHOSSNetWorkTool : NSObject

@property (nonatomic, strong) OSSClient *client;

+ (instancetype)sharedInstance;

/**
 获取OSS的服务对象
 */
- (void)loadOSSClient;

/**
 阿里云上传接口
 @param objectKey 文件名
 @param uploadingData 文件
 @param progress 进度
 @param success 成功
 @param error 失败
 */
+ (OSSPutObjectRequest *)OSSPushDataWithName:(NSString *)objectKey uploadingData:(NSData *)uploadingData progress:(void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progress success:(void (^)(OSSTask *task , NSString *fileUrl))success error:(void (^)(OSSTask *task ,NSError *error))error;

/**
 阿里云下载接口
 @param objectKey 文件名
 @param progress 每个进度
 @param success 成功
 @param error 错误
 */
+ (OSSGetObjectRequest *)OSSDownLoadDataWithName:(NSString *)objectKey progress:(void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progress success:(void (^)(OSSTask *task ,NSData * downloadedData))success error:(void (^)(OSSTask *task ,NSError *error))error;

@end
