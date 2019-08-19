//
//  DoodleBoardClipConfigModel.h
//  DynamicClipImage
//  主要用于修改截图区域的 上 左 下 右 的位置
//  Created by 夏征宇 on 2019/4/25.
//  Copyright © 2019 yasic. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoodleBoardClipConfigModel : NSObject


@property (nonatomic  , assign)float top;
@property (nonatomic  , assign)float left;
@property (nonatomic  , assign)float bottom;
@property (nonatomic  , assign)float right;

/**
 蒙版背景色
 */
@property (nonatomic, strong) UIColor *layerBgColor;

/**
 是否显示操作栏
 */
@property (nonatomic, assign) BOOL isShowHandle;

/**
 边框主题侧
 */
@property (nonatomic, strong) UIColor *tintColor;


//截图区域显示的范围 距离原图片范围 四个边框对应的距离
-(instancetype)initWithTop:(float)top withLeft:(float)left withBottom:(float)bottom withRight:(float)right;

-(instancetype)initWithTop:(float)top withLeft:(float)left withBottom:(float)bottom withRight:(float)right layerBgColor:(UIColor *)layerBgColor tintColor:(UIColor *)tintColor isShowHandle:(BOOL)isShowHandle;


@end

NS_ASSUME_NONNULL_END
