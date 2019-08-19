//
//  globalDefine.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#ifndef globalDefine_h
#define globalDefine_h

#import "HHCategoryHeader.h"
#import "HHNetworkAPI.h"

#pragma mark ---------------------打印----------------------------
#ifdef DEBUG // 调试状态, 打开LOG功能
#define NSLog(...) NSLog(__VA_ARGS__)
#else // 发布状态, 关闭LOG功能
#define NSLog(...)
#endif

#pragma mark ---------------------常规定义----------------------------

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
//屏幕宽高
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

//判断是否是ipad
#define kIsPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !kIsPad : NO)
//判断iPHoneXr
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !kIsPad : NO)
//判断iPhoneXs
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !kIsPad : NO)
//判断iPhoneXs Max
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !kIsPad : NO)

//是否是全面屏
#define KIsFullPhone ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES)?YES:NO)

//iPhoneX系列
#define StatusBar_Height (KIsFullPhone? 44.0 : 20.0)
#define NavBar_Height (KIsFullPhone? 88.0 : 64.0)
#define TabBar_Height (KIsFullPhone? 83.0 : 49.0)

#define KPhonexSafeBottomHeight (KIsFullPhone?30:0);

#define Font(size) [UIFont systemFontOfSize:size]
#define BoldFont(size) [UIFont boldSystemFontOfSize:size]

#pragma mark ---------------------颜色----------------------------

#define kThemeColor ColorHexString(@"FF8800")

#define kThemeImage(name) [[UIImage imageNamed:name] imageWithTintColor:kThemeColor]

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define ColorHexString(colorString) [UIColor colorWithHexString:colorString]

// 51灰
#define kGray_51 [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0]
// 68灰
#define kGray_68 [UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0]
// 85灰
#define kGray_85 [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]
// 105灰
#define kGray_105 [UIColor colorWithRed:105.0/255.0 green:105.0/255.0 blue:105.0/255.0 alpha:1.0]
// 150灰
#define kGray_150 [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0]
// 182灰
#define kGray_182 [UIColor colorWithRed:182.0/255.0 green:182.0/255.0 blue:182.0/255.0 alpha:1.0]
// 230灰
#define kGray_230 [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]


#pragma mark ---------------------系统信息----------------------------

#define iOSVersion  [[UIDevice currentDevice].systemVersion doubleValue]

// 是否为iOS9
#define kisiOS9 (iOSVersion >= 9.0)

// 是否为iOS10
#define kisiOS10 (iOSVersion >= 10.0)
// 是否为iOS11
#define kisiOS11 (iOSVersion >= 11.0)

#endif
