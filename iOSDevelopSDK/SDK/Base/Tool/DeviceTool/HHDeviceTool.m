//
//  HHDeviceTool.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import "HHDeviceTool.h"
#import <sys/sysctl.h>
#import <sys/utsname.h>
#import "HHCommonTool.h"

@implementation HHDeviceTool

/** appstore download url */
+ (NSString *)getAppStoreUrl
{
    return [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@",@"111"];
}

/** 客户端类型 */
+ (NSString *)getClientType
{
    return @"iOS";
}

/** 设备名 */
+ (NSString *)getDeviceName
{
    return [[UIDevice currentDevice] name];
}

/** 设备类型 */
+ (NSString *)getDeviceType
{
    int mib[] = {CTL_HW, HW_MACHINE};
    size_t len;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    char *machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    NSString *deviceType = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return deviceType;
}

/** 获取应用名 */
+ (NSString *)getAppName
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSString *appName = infoDictionary[@"CFBundleDisplayName"];
    if ([HHCommonTool isNullString:appName])
    {
        appName = infoDictionary[@"CFBundleName"];
    }
    return appName;
}

/** 获取安装的version，包含buildId */
+ (NSString *)getInstallIncludeBuildVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
    NSString *build = infoDictionary[(NSString *)kCFBundleVersionKey];
    return [NSString stringWithFormat:@"%@.%@", version, build];
}

/** 获取安装的version，不包含buildId */
+ (NSString *)getInstallVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
    return version;
}

/** 设备系统类型 */
+ (NSString *)getDeviceOSType
{
    return @"ios";
}

/** 设备系统版本号 */
+ (NSString *)getDeviceOSVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

/** 渠道 */
+ (NSString *)getAppSourceChannel
{
    NSString *type = @"";
#if (SFDEBUG == 1)
    type = @"dev";
#else
    type = @"AppStore";
#endif
    return type;
}

/** build Identifier */
+ (NSString *)getBoundleId
{
    NSString* boundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    return boundleID;
}


@end
