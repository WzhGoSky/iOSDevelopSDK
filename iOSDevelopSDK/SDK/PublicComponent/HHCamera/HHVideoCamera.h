//
//  HHVideoCamera.h
//  HHCamera
//
//  Created by Hayder on 2018/10/5.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHAVKitManagerView.h"
#import "HHCircleProgressView.h"

@protocol HHVideoCameraDelegate<NSObject>

//保存地址带视频截图
- (void)microVideoPath:(NSString *)savePath thumbImage:(UIImage *)image;

//保存地址带视频截图和生成的gif图片
- (void)microVideoPath:(NSString *)savePath thumbImage:(UIImage *)image gifFaceURL:(NSString *)imagePath;

@end

@interface HHVideoCamera : HHAVKitManagerView

//录制按钮
@property (nonatomic, strong) UIButton *recordBtn;
//取消按钮
@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, weak) id<HHVideoCameraDelegate> delegate;

@end
