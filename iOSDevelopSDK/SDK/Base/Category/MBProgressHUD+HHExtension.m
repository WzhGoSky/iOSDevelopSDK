//
//  MBProgressHUD+SF.m
//
//
//  Created by Hayder on 2018/5/7.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "MBProgressHUD+HHExtension.h"

@implementation MBProgressHUD (HHExtension)
#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil){
        view = [UIApplication sharedApplication].keyWindow;
    }
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    if (icon != nil)
    {
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
        hud.mode = MBProgressHUDModeCustomView;
        [hud hide:YES afterDelay:0.7];
    }
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"common_error.png" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"common_success.png" view:view];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
     if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.7];
    if (message.length < 10)
    {
        hud.labelText = message;
    }else
    {
        hud.detailsLabelText = message;
    }
    return hud;
}

+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil];
}

+ (void)showPrompt:(NSString *)message
{
    UIView *view = [UIApplication sharedApplication].keyWindow;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (message.length < 10)
    {
        hud.labelText = message;
    }else
    {
        hud.detailsLabelText = message;
    }
    hud.removeFromSuperViewOnHide = YES;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    hud.mode = MBProgressHUDModeCustomView;
    [hud hide:YES afterDelay:0.7];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}

+ (MBProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:nil];
}

+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD
{
    [self hideHUDForView:nil];
}

+ (void)showHUDLoading {
   
    [self show:nil icon:nil view:nil];
}

+ (void)showHUDLoadingToView:(UIView *)view {

    [self show:nil icon:nil view:view];
}

+ (void)showHUDLoadingToView:(UIView *)view andDisabledButton:(UIButton *)button {
    button.userInteractionEnabled = NO;
    [self show:nil icon:nil view:view];
}
+ (void)hideHUDForView:(UIView *)view andDisabledButton:(UIButton *)button {
   
    button.userInteractionEnabled = YES;
    if (view == nil){
        view = [UIApplication sharedApplication].keyWindow;
    }
    [MBProgressHUD hideHUDForView:view animated:YES];
}
@end
