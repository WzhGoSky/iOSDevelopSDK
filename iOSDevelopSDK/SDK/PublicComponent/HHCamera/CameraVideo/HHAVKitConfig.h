//
//  HHAVKitConfig.h
//  HHCamera
//
//  Created by Hayder on 2018/10/5.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#ifndef HHAVKitConfig_h
#define HHAVKitConfig_h

#define kRGBA(r,g,b,a)       [UIColor colorWithRed:(r)/255.f \
green:(g)/255.f \
blue:(b)/255.f \
alpha:(a)]

//主题色
#define kCameraThemeColor kRGBA(255, 153, 0, 1)

//录制最长时间 用来区分录制样式
#define kRecordMaxTime 10
//进度条刷新频率
#define kRefreshRate 30.0


#endif
