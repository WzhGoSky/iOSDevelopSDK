//
//  MBProgressHUD+Extension.h
//  
//
//  Created by Hayder on 2018/5/7.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (HHExtension)
/**
 *  显示成功信息 有图片
 */
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showSuccess:(NSString *)success;
/**
 *  显示提示信息，无图片
 */
+ (void)showPrompt:(NSString *)message;
/**
 *  显示错误信息 有图片
 */
+ (void)showError:(NSString *)error toView:(UIView *)view;
+ (void)showError:(NSString *)error;
/**
 *  显示纯文本 加一个转圈
 */
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;
+ (MBProgressHUD *)showMessage:(NSString *)message;


/**
 *只显示一个加载框
 *view=nil 默认加到keyWindow上
 *禁用右导航button
 */
+ (void)showHUDLoading;
+ (void)showHUDLoadingToView:(UIView *)view;
+ (void)showHUDLoadingToView:(UIView *)view andDisabledButton:(UIButton *)button;

/**
 *  隐藏加载框
 */
+ (void)hideHUD;
+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUDForView:(UIView *)view andDisabledButton:(UIButton *)button;

@end
