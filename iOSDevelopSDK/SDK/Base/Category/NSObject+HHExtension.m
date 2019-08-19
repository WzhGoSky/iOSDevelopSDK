//
//  NSObject+HHExtension.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/27.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import "NSObject+HHExtension.h"
#import "globalDefine.h"

@implementation NSObject (HHExtension)

//导航栏高度
- (CGFloat)navBarHeight
{
    return NavBar_Height;
}

//tabbar高度
- (CGFloat)tabBarHeight
{
    return TabBar_Height;
}

/**安全高度: 刘海屏 30 非刘海屏 0*/
- (CGFloat)safeHeight
{
    return KPhonexSafeBottomHeight;
}
@end
