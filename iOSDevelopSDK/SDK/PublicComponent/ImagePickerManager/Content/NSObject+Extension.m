//
//  NSObject+Extension.m
//  jupiter
//
//  Created by Hayder on 2017/3/6.
//  Copyright © 2017年 dev. All rights reserved.
//

#import "NSObject+Extension.h"

@implementation NSObject (Extension)
+ (UIViewController *)getCurrentController {
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    if (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    if (topVC) {
        return topVC;
    }else{
        UIViewController *result = nil;
        
        
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        if (window.windowLevel != UIWindowLevelNormal)
        {
            NSArray *windows = [[UIApplication sharedApplication] windows];
            for(UIWindow * tmpWin in windows)
            {
                if (tmpWin.windowLevel == UIWindowLevelNormal)
                {
                    window = tmpWin;
                    break;
                }
            }
        }
        
        UIView *frontView = [[window subviews] objectAtIndex:0];
        id nextResponder = [frontView nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
            result = nextResponder;
        else
            result = window.rootViewController;
        
        return result;
    }
    
}

+ (UIViewController *)getPresentController {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *hostVC = rootVC;
    while (hostVC.presentedViewController) {
        hostVC = hostVC.presentedViewController;
    }
    hostVC = hostVC ?: rootVC;
    return hostVC;
}
@end
