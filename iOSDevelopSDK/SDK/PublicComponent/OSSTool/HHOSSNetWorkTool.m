//
//  HHOSSNetWorkTool.m
//  HHForAppStore
//
//  Created by  ovopark_iOS1 on 2018/6/20.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHOSSNetWorkTool.h"
#import "HHOSSToolHelper.h"
#import "NetworkTool.h"
#import "globalDefine.h"

@implementation HHOSSNetWorkTool

+ (instancetype)sharedInstance
{
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HHOSSNetWorkTool alloc] init];
    });
    return _instance;
}

/**
 获取OSS的服务对象
 */
- (void)loadOSSClient
{
    [NetworkTool POSTWithURL:@"" params:@{} isAutoShowError:NO success:^(id  _Nullable response) {
        NSNumber *isError = [response objectForKey:@"isError"];
        if (isError && !isError.integerValue && [[response objectForKey:@"result"]isEqualToString:@"ok"]){
            NSDictionary *data = [response objectForKey:@"data"];
            NSDictionary *dict = [data objectForKey:@"data"];
            NSDictionary *credentials = [dict objectForKey:@"credentials"];
            NSString *endpoint = @"https://oss-cn-hangzhou.aliyuncs.com";
            NSString *accessKeySecret = [credentials objectForKey:@"accessKeySecret"];
            NSString *accessKeyId = [credentials objectForKey:@"accessKeyId"];
            NSString *securityToken = [credentials objectForKey:@"securityToken"];
            id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:accessKeyId secretKeyId:accessKeySecret securityToken:securityToken];
            OSSClientConfiguration * conf = [OSSClientConfiguration new];
            conf.maxRetryCount = 3; // 网络请求遇到异常失败后的重试次数
            conf.timeoutIntervalForRequest = 30; // 网络请求的超时时间
            conf.timeoutIntervalForResource = 24 * 60 * 60; // 允许资源传输的最长时间
            self.client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential clientConfiguration:conf];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

+ (OSSPutObjectRequest *)OSSPushDataWithName:(NSString *)objectKey uploadingData:(NSData *)uploadingData progress:(void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progress success:(void (^)(OSSTask *task , NSString *fileUrl))success error:(void (^)(OSSTask *task ,NSError *error))error{
    OSSClient *client = [HHOSSNetWorkTool sharedInstance].client;
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName = @"ovopark";
    put.objectKey = objectKey;
    put.uploadingData = uploadingData;
    put.uploadProgress = progress;
    
    OSSTask * putTask = [client putObject:put];
    [putTask continueWithBlock:^id(OSSTask *task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!task.error) {
                NSString *fileUrl = [NSString stringWithFormat:@"%@%@",@"http://ovopark.oss-cn-hangzhou.aliyuncs.com/",objectKey];
                success (task,fileUrl);
            } else {
                error (task,task.error);
                [[HHOSSNetWorkTool sharedInstance] loadOSSClient];
            }
        });
        return task;
    }];
    return put;
}

+ (OSSGetObjectRequest *)OSSDownLoadDataWithName:(NSString *)objectKey progress:(void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progress success:(void (^)(OSSTask *task ,NSData * downloadedData))success error:(void (^)(OSSTask *task ,NSError *error))error{
    OSSClient *client = [HHOSSNetWorkTool sharedInstance].client;
    
    OSSGetObjectRequest * request = [OSSGetObjectRequest new];
    request.bucketName = @"ovopark";
    request.objectKey = objectKey;
    request.downloadProgress = progress;
    
    OSSTask * getTask = [client getObject:request];
    [getTask continueWithBlock:^id(OSSTask *task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!task.error) {
                OSSGetObjectResult * getResult = task.result;
                success (task,getResult.downloadedData);
            } else {
                error (task,task.error);
                [[HHOSSNetWorkTool sharedInstance] loadOSSClient];
            }
        });
        return task;
    }];
    return request;
}

@end
