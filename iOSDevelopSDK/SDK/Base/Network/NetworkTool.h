//
//  NetworkTool.h
//  JYQX
//
//  Created by Hayder on 2018/8/20.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef void(^success)(id _Nullable response);
typedef void(^failure)(NSError * _Nonnull error);

@interface NetworkTool : NSObject
/**
 GET请求方式
 */
+(NSURLSessionDataTask *)GETWithURL:(NSString *)urlString params:(NSDictionary *)params isAutoShowError:(BOOL)isAutoShowError success:(success)success failure:(failure _Nullable )failure;

/**
 POST请求方式
 */
+ (NSURLSessionDataTask *)POSTWithURL:(NSString *)urlString params:(NSDictionary *)params isAutoShowError:(BOOL)isAutoShowError success:(success )success failure:(failure)failure;

/**
 上传多张图片
 @param urlStr 图片url
 @param parameters 参数
 @param images 上传图片数组
 @param compressionQuality 图片压缩质量
 @param progress 进度回调
 @param success 成功
 @param failure 失败
 */
+(NSURLSessionDataTask *)httpUploadWithUlr:(NSString *)urlStr andParameters:(NSDictionary *)parameters andImageArray:(NSArray <UIImage *>*)images compressionQuality:(CGFloat)compressionQuality progress:(void (^)(NSProgress * _Nonnull uploadProgress))progress andBlock:(success)success failure:(failure)failure;


@end
