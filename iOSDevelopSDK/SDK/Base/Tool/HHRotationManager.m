//
//  HHRotationManager.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import "HHRotationManager.h"

@implementation HHRotationManager

+ (instancetype)manager
{
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HHRotationManager alloc] init];
    });
    return _instance;
}

/**强制横屏*/
+ (void)rotationLandscape
{
    // 竖屏状态下点击
    // 强制变为横屏
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        
        [invocation setSelector:selector];
        
        [invocation setTarget:[UIDevice currentDevice]];
        
        int val = UIInterfaceOrientationLandscapeRight;
        
        [invocation setArgument:&val atIndex:2];
        
        [invocation invoke];
    }
}

/**强制竖屏*/
+ (void)rotationPortrait
{
    // 横屏状态下点击
    // 强制变为竖屏
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        
        SEL selector = NSSelectorFromString(@"setOrientation:");
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        
        [invocation setSelector:selector];
        
        [invocation setTarget:[UIDevice currentDevice]];
        
        int val = UIInterfaceOrientationPortrait;
        
        [invocation setArgument:&val atIndex:2];
        
        [invocation invoke];
    }
}

/**是否是竖屏*/
+ (BOOL)isPortrait
{
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ||
        [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    }else
    {
        return NO;
    }
}


@end
