//
//  HHCircleProgress.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2017/5/30.
//  Copyright © 2017年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^didClickProgress)(void);

@interface HHCircleProgressView : UIView
/** 进度 */
@property (nonatomic, assign) CGFloat progress;
/** 底层颜色 */
@property (nonatomic, strong) UIColor *bottomColor;
/** 顶层颜色 */
@property (nonatomic, strong) UIColor *topColor;
/** 进度显示 */
@property (nonatomic, strong) UILabel *progressLabel;
/**点击事件回调*/
@property (nonatomic, copy) didClickProgress clickEvent;

/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame progress:(CGFloat)progress progressWidth:(CGFloat)progressWidth;

@end
