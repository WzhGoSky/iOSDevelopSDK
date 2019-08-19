//
//  PickerConfig.h
//  TZImagePickerController
//
//  Created by Hayder on 2018/9/7.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "NSObject+Extension.h"

typedef NS_OPTIONS(NSUInteger, PickerMangerType) {
    PickerMangerTypeAlbum                                                         = 1 << 0,//相册
    PickerMangerTypeTakePhoto                                                          = 1 << 1,//拍照
    PickerMangerTypeShortVideo                                                  = 1 << 2,//短视频拍摄
    PickerMangerTypePreview                                                       = 1 << 3,//图片预览
};


@protocol PickerManagerDelegate <NSObject>

/**
 选择相册事件
 */
-(void)PickerManagerDidClickTakePhoto;

/**
 选择相机事件
 */
-(void)PickerManagerDidClickTakePicker;

/**
 选择短视频
 */
-(void)PickerManagerDidClickTakeShortVideo;

/**
 取消
 */
-(void)PickerManagerDidClickTakeCancel;

@end


