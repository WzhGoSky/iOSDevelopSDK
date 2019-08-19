//
//  TZPickerImageConfig.m
//  AFNetworking
//
//  Created by Hayder on 2018/11/6.
//

#import "TZPickerImageConfig.h"

@interface TZPickerImageConfig()

@end


@implementation TZPickerImageConfig

static TZPickerImageConfig *config = nil;

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[TZPickerImageConfig alloc] init];
    });
    return config;
}
@end
