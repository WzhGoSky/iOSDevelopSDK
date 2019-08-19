//
//  HHAVKitOption.m
//  HHCamera
//
//  Created by Hayder on 2018/10/4.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHAVKitOption.h"

@implementation HHAVKitOption

+ (instancetype)defaultOption
{
    HHAVKitOption *option = [[HHAVKitOption alloc] init];
    return option;
}
//相机的拍摄照片的清晰度 和 最大照片数
- (instancetype)initOnPhotoModeWithSessionPreset:(SessionPreset)preset
{
    if (self = [super init]) {
        _type = SessionTypePhoto;
        _preset = preset;
        _maxPhotoCount = 1;
    }
    return self;
}

//相机的拍摄照片的清晰度 和 最大照片数
- (instancetype)initOnPhotoModeWithSessionPreset:(SessionPreset)preset MaxPhotoCount:(NSInteger)count
{
    if (self = [super init]) {
        _type = SessionTypePhoto;
        _preset = preset;
        if (count<1) {
            count = 1;
        }
        _maxPhotoCount = count;
    }
    return self;
}

//摄像机拍摄的清晰度 和 最长时间
- (instancetype)initOnVideoModeWithQualityLevel:(QualityLevel) qualityLevel MaxSecond:(NSInteger)maxSecond
{
    if (self = [super init]) {
        _type = SessionTypeVideo;
        _qualityLevel = qualityLevel;
        if (maxSecond<15) {
            maxSecond = 15;
        }
        _showEditButtonTime = 60;
        _recordMaxTime = maxSecond;
    }
    return self;
}

- (void)setRecordMaxTime:(NSInteger)recordMaxTime
{
    _recordMaxTime = recordMaxTime;
    
    if (recordMaxTime <= 20) {//小于30秒
        _qualityLevel = QualityLevelHigh;
    }
}
@end
