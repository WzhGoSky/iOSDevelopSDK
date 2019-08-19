//
//  UIView+HUD.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import "UIView+HUD.h"
#import "MBProgressHUD.h"

#define HUDHidenTime 15 //最长时间15s
@implementation UIView (HUD)

- (void)toastMessage:(NSString*)message
{
    [self showTextHUDWithPromptMessage:message andOffset_y:0 andMargin:10 andDuration:1.5];
}

- (void)showTextHUDWithPromptMessage:(NSString *)message andOffset_y:(CGFloat)offset_y andMargin:(CGFloat)margin andDuration:(NSTimeInterval)time
{
    if ([message isEqualToString:@""]|| message == nil) {
        return;
    }
    //只显示文字
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText =message;
    hud.margin = margin;
    hud.yOffset = offset_y;
    hud.removeFromSuperViewOnHide = YES;
    hud.dimBackground = NO;
    [hud hide:YES afterDelay:time];
    
    hud.userInteractionEnabled = NO;
}
- (MBProgressHUD *)showActivityHUD
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:NO];
    hud.labelText = @"请稍等";
    hud.removeFromSuperViewOnHide = YES;
    //防止主线程卡死 15s后自动隐藏
    [hud hide:YES afterDelay:HUDHidenTime];
    hud.userInteractionEnabled = NO;
    
    return hud;
}

-(MBProgressHUD *)showActivityHUDWithDescription:(NSString *)descripotion
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.labelText = descripotion;
    hud.removeFromSuperViewOnHide = YES;
    
    hud.userInteractionEnabled = NO;
    //防止主线程卡死 15s后自动隐藏
    [hud hide:YES afterDelay:HUDHidenTime];
    return hud;
}

- (void)hideActivityHUD
{
    [MBProgressHUD hideAllHUDsForView:self animated:YES];
}

/**
 没有描述的activity
 */
- (void)showActivityHUDNODescription
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.userInteractionEnabled = NO;
    
    //防止主线程卡死 15s后自动隐藏
    [hud hide:YES afterDelay:HUDHidenTime];
}


@end
