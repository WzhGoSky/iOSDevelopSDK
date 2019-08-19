//
//  UIView+ImagePickerExtension.m
//  test
//
//  Created by Hayder on 2018/10/6.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "UIView+ImagePickerExtension.h"

@implementation UIView (ImagePickerExtension)

- (void)hideActivityHUD
{
    [MBProgressHUD hideHUDForView:self animated:YES];
}
- (MBProgressHUD *)showActivityHUD
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    //    hud.labelText = LocalizedString(@"qingsaodeng...", nil);
    hud.removeFromSuperViewOnHide = YES;
    
    hud.userInteractionEnabled = NO;
    
    return hud;
}
- (void)showTextHUDWithPromptMessage:(NSString *)message andOffset_y:(CGFloat)offset_y andMargin:(CGFloat)margin andDuration:(NSTimeInterval)time
{
    if ([message isEqualToString:@""]|| message == nil) {
        return;
    }
    //只显示文字
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = message;
    hud.margin = margin;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:time];
    
    hud.userInteractionEnabled = NO;
}

@end
