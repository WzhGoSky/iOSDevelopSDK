//
//  ImageShowHelper.h
//  iOSDevelop
//
//  Created by Hayder on 2018/10/12.
//

#import <UIKit/UIKit.h>

@interface ImageShowHelper : NSObject
+ (void)showWaitingDialogWithMsg:(NSString *)msg container:(UIView *)containerView;

+ (void)dismissWaitingDialogOnContainer:(UIView *)containerView;

+ (void)showMessage:(NSString *)msg container:(UIView *)containerView;
@end
