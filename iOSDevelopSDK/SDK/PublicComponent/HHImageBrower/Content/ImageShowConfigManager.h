//
//  ImageShowConfigManager.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/9/23.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageShowConfig.h"

@interface ImageShowConfigManager : NSObject

+ (instancetype)shareInstance;

/**
 图片浏览  根据多选枚举值  来获取alert选项
 */
-(NSMutableArray<UIAlertAction *> *)getConfigAlertWithType:(ShowImageMangerType)type delegate:(id<ImageShowViewHandleDelegate>)delegate;

/**
 短视频播放  根据多选枚举值  来配置操作栏选项
 */
-(NSMutableArray *)getShortVideoHandleWithType:(ShowShortVideoMangerType)type delegaate:(id<ShoreVideoHandleDelegate>)delegate;

@end
