//
//  HHVideoClipSliderBlockBtn.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/7/26.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHVideoClipSliderBlockBtn : UIView

// 是左滑块还是右滑块,YES为左
@property (assign, nonatomic) BOOL isLeftSliderBtn;

// 滑块背景图片
@property (strong, nonatomic) UIImage *sliderImage;


@end
