//
//  UIView+HUD.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;
@interface UIView (HUD)

- (void)toastMessage:(NSString*)message;

- (void)showTextHUDWithPromptMessage:(NSString*)message andOffset_y:(CGFloat) offset_y andMargin:(CGFloat)margin andDuration:(NSTimeInterval) time;

/**请稍等...*/
- (MBProgressHUD *)showActivityHUD;

/**没有描述的Loading.....*/
- (void)showActivityHUDNODescription;

/**自定义描述的Loding....*/
-(MBProgressHUD *)showActivityHUDWithDescription:(NSString *)descripotion;

-(void)hideActivityHUD;

@end

