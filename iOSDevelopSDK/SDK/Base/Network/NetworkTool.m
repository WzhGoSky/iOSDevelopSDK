//
//  NetworkTool.m
//  JYQX
//
//  Created by Hayder on 2018/8/20.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "NetworkTool.h"
#import "MBProgressHUD+HHExtension.h"

@implementation NetworkTool

/**
 GET请求方式
 */
+(NSURLSessionDataTask *)GETWithURL:(NSString *)urlString  params:(NSDictionary *)params isAutoShowError:(BOOL)isAutoShowError success:(success)success failure:(failure _Nullable )failure
{
   return [self requestMethodIsPost:NO URL:urlString params:params isAutoShowError:isAutoShowError success:success failure:failure];
}

+ (NSURLSessionDataTask *)POSTWithURL:(NSString *_Nullable)urlString params:(NSDictionary *_Nullable)params isAutoShowError:(BOOL)isAutoShowError success:(success _Nullable )success failure:(failure _Nullable )failure
{
   return [self requestMethodIsPost:YES URL:urlString params:params isAutoShowError:isAutoShowError success:success failure:failure];
}


+ (NSURLSessionDataTask *)requestMethodIsPost:(BOOL)isPost URL:(NSString *_Nullable)urlString params:(NSDictionary *_Nullable)params isAutoShowError:(BOOL)isAutoShowError success:(success _Nullable )success failure:(failure _Nullable )failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSNumber *timeoutIntervalNum = params[@"timeoutInterval"];
    if (timeoutIntervalNum) {
        
        manager.requestSerializer.timeoutInterval = timeoutIntervalNum.floatValue;
    }else
    {
        // 设置超时时间
        manager.requestSerializer.timeoutInterval = 15;
    }
    // 声明返回的结果是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // 如果接收类型不一致，替换一致或其他
    manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",@"text/plain", nil];
    
//    //如果已登录，添加token
//    if ([MainCache cache].user.token) {
//        NSString *token = [NSString stringWithFormat:@"Bearer %@",[MainCache cache].user.token];
//        [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
//    }

//    // 2.设置请求头
//    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
//    [manager.requestSerializer setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"appVersion"];
//    [manager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"platform"];
    
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // 声明请求的数据是json类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSURLSessionDataTask *operation = nil;
    if (isPost) {
      operation = [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          NSLog(@"POST请求 \n 请求地址 %@ \n 请求参数 %@ \n 请求结果 %@ ",urlString,params,responseObject);
            if (success) {
                success(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"POST请求 \n 请求地址 %@ \n 请求参数 %@ 错误信息 %@",urlString,params,[error description]);
            if (failure) {
                failure(error);
            }
            if (isAutoShowError) {
                [MBProgressHUD showPrompt:error.localizedDescription];
            }
        }];
    }else{
      operation =  [manager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          NSLog(@"GET请求 \n 请求地址 %@ \n 请求参数 %@ \n 请求结果 %@ ",urlString,params,responseObject);
            if (success) {
                success(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"GET请求 \n 请求地址 %@ \n 请求参数 %@ 错误信息 %@",urlString,params,[error description]);
            if (failure) {
                failure(error);
            }
            if (isAutoShowError) {
                [MBProgressHUD showPrompt:error.localizedDescription];
            }
        }];
    }
    
    return operation;
}

+(NSURLSessionDataTask *)httpUploadWithUlr:(NSString *)urlStr andParameters:(NSDictionary *)parameters andImageArray:(NSArray <UIImage *>*)images compressionQuality:(CGFloat)compressionQuality progress:(void (^)(NSProgress * _Nonnull uploadProgress))progress andBlock:(success)success failure:(failure)failure
{
    //处理当前的图片数组
    NSMutableArray <NSData *>*handleList = [NSMutableArray array];
    for (int i=0; i<images.count; i++) {
        UIImage *image = images[i];
        NSData *data = UIImageJPEGRepresentation(image, compressionQuality);
        [handleList addObject:data];
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 120;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
    NSURLSessionDataTask *operation = [manager POST:urlStr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSInteger imgCount = 0;
        for (NSData *imageData in handleList)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmssSSS";
            NSString *fileName = [NSString stringWithFormat:@"%@%@.png",[formatter stringFromDate:[NSDate date]],@(imgCount)];
            [formData appendPartWithFileData:imageData name:@"temps" fileName:fileName mimeType:@"image/png"];
            imgCount ++;
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    return operation;
}

+ (void)HttpbodyJsonRequest:(NSString *)urlString params:(NSDictionary *)params isAutoShowError:(BOOL)isAutoShowError success:(success)success failure:(failure)failure
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 2.设置请求头
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"appVersion"];
    [request setValue:@"iOS" forHTTPHeaderField:@"platform"];
    // 3.设置请求体
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = data;
    //4.发送请求
    [[[AFHTTPSessionManager manager] dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) { //请求成功
            if (success) {
                success(responseObject);
            }
        }else
        {
            if (failure) {
                failure(error);
            }
        }
    }] resume];
}

@end
