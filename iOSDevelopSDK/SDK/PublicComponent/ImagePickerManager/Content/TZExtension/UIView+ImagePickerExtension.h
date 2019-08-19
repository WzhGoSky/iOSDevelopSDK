//
//  UIView+KDImagePickerExtension.h
//  test
//
//  Created by Hayder on 2018/10/6.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface UIView (ImagePickerExtension)

// hide activity
-(void)hideActivityHUD;
- (MBProgressHUD *)showActivityHUD;
- (void)showTextHUDWithPromptMessage:(NSString*)message andOffset_y:(CGFloat) offset_y andMargin:(CGFloat)margin andDuration:(NSTimeInterval) time;
@end
