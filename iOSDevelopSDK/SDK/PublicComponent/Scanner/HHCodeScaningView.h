//
//  ZHScanView.h
//  sasasas
//
//  Created by WZH on 16/3/8.
//  Copyright © 2016年 lyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HHCodeScaningView;
@protocol HHCodeScaningViewDelegate <NSObject>

/**扫描的结果*/
- (void)codeScaningView:(HHCodeScaningView *)codeView DidFinishRefreshingWithResult:(NSString *)result;

@end

@interface HHCodeScaningView : UIView

@property (nonatomic, weak) id<HHCodeScaningViewDelegate> delegate;

//扫描框的位置和大小
- (instancetype)initWithScanFrame:(CGRect)frame;
/**
 * 获取默认大小的scanView(全屏)
 *
 */
+ (instancetype)scanView;

/**
 *  获取指定大小的scanView;
 *
 */
+ (instancetype)scanViewWithFrame:(CGRect)frame;

/**
 *  开始扫描
 */
- (void)startScaning;

/**停止扫描*/
- (void)stopScaning;

@end
