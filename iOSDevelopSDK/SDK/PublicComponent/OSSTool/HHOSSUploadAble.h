//
//  HHOSSUploadAble.h
//  HHForAppStore
//
//  Created by Hayder on 2018/9/20.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HHOSSUploadAble <NSObject>

//如果实现协议，必须实现
@required
/**上传完毕后照片的路径 如果是视频的话，是封面图*/
@property (nonatomic, copy) NSString *imageResourceURL;
/**上传完毕后gif照片的路径 如果是视频的话，是封面图*/
@property (nonatomic, copy) NSString *gifResourceURL;
/**视频上传完毕的URL路径*/
@property (nonatomic, copy) NSString *videoResourceURL;
/**最后上传完毕的URL路径*/
@property (nonatomic, copy) NSString *fileResourceURL;

#pragma mark ---------------------图片-----------------------------------------
/**上传的图片*/
- (UIImage *)getUploadImage;
#pragma mark ---------------------上传的视频-----------------------------------------
/**上传的视频文件*/
- (NSString *)getVideoFilePath;
#pragma mark ---------------------上传的文件-----------------------------------------
/**文件路径*/
- (NSString *)getFilePath;

@optional
#pragma mark ---------------------图片-----------------------------------------
/**上传的图片的类型，默认png*/
- (NSString *)getImageType;
/**上传的图片的压缩尺寸 不实现 默认压缩为 0.1*/
- (CGFloat)getCompressionQuality;
#pragma mark ---------------------上传的视频-----------------------------------------
/**上传的视频文件*/
- (NSString *)getVideoType;
/**视频封面图*/
- (UIImage *)getVideoFaceImage;
/**gif图片路径*/
- (NSString *)gifImagePath;
#pragma mark ---------------------上传的文件-----------------------------------------
/**文件的类型*/
- (NSString *)getFileType;


@end
