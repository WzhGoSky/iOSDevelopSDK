//
//  ElectronicSignatureConfig.m
//  BaseKit
//
//  Created by Hayder on 2018/10/24.
//

#import "ElectronicSignatureConfig.h"

@implementation ElectronicSignatureConfig
    
+(instancetype)defaultConfig{
    ElectronicSignatureConfig *config = [[ElectronicSignatureConfig alloc]init];
    config.titleStr = @"签名";
    config.topLeftTitle = @"清除";
    config.topRightTitle =  @"完成";
    config.lineTintColor = @"B5B5B5";
    config.topHandeColor = @"2F79FD";
    config.topHandleFont = 16;
    config.topTitleFont = 18;
    return config;
}
@end
