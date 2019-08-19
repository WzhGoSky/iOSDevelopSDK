//
//  HHCommonTool.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHCommonTool : NSObject

/** 是不是上架审核的状态 */
+(BOOL)isAppStroePublich;

+ (int)parseInt:(NSObject *)value;

+ (long long)parseLongLong:(NSObject *)value;

+ (NSString *)parseString:(NSObject *)value;
/** 空字符串 转换为0 */
+ (NSString *)parseStringToZero:(NSObject *)value;
/** 如果不是string 转换为string */
+ (NSString *)parseAutoConversionString:(NSObject *)value;

+ (double)parseDouble:(NSObject *)value;

+ (NSArray *)parseArray:(NSObject *)value;

+ (NSArray *)parseInitArray:(NSObject *)value;

+ (NSDictionary *)parseDictionary:(NSObject *)value;

+ (NSDictionary *)parseInitDictionary:(NSObject *)value;

/** 是否是空字符串 */
+ (BOOL)isNullString:(NSString *)string;

+ (BOOL)isNullArray:(NSArray *)stringArray;

+ (BOOL)isDic:(id)obj;

+ (BOOL)isEqulImage:(UIImage *)img1 Image:(UIImage *)img2;

/**是否是手机号*/
+ (BOOL)isMobile:(NSString *)mobile;

/**是否是邮编*/
+ (BOOL)isPostcode:(NSString *)code;

#pragma mark - 过滤空数据
/** 过滤空数据数组 */
+ (NSArray *)getFilterNilDataWithArray:(NSArray *)dataArray;

/** 过滤空字符串数组 */
+ (NSArray *)getFilterNilStringWithArray:(NSArray *)stringArray;

/** 过滤指定类型空数据数组 */
+ (NSArray *)getFilterNilClassWithArray:(NSArray *)sourceArray objectClass:(Class)aClass;

/** 手机号 显示 XXX****XXXX */
+ (NSString *)getPhoneNumberEncryptStringWithPhoneNumberString:(NSString *)phoneNumber;

// encoding
+ (NSString *)getEncodingStringFromString:(NSString *)string;

+ (NSString *)getJsonStringFromDictionary:(NSDictionary *)dictionary;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSString *)getStringWithNowDateTimeInterval;

/** 分隔字符串 以英文逗号分隔 */
+ (NSArray *)getStringArrayWithString:(NSString *)string;

/** 分隔字符串 以英文|分隔 */
+ (NSArray *)getStringArrayVerticalLineSeparatorWithString:(NSString *)string;

/** 把字符串数组合并为一个字符串，以英文逗号分隔 */
+ (NSString *)getStringWithStringArray:(NSArray *)stringArray;

/** 字符串数组合并为字符串 以 | 作为字符串分隔 */
+ (NSString *)getStringVerticalLineSeparatorWithStringArray:(NSArray *)stringArray;


// 去掉前后空格
+ (NSString *)getFiltrateSapceString:(NSString *)sourceString;


/** 返回区间字符串 */
+ (NSString *)getInterzoneStringWithStartNumber:(int)startNumber
                                     stopNumber:(int)stopNumber
                                           unit:(NSString *)unit;

+ (NSDictionary *)getNetworkHeadClientInfo;

+ (NSString *)getSpecialShowTimeWithTimeInterval:(NSTimeInterval)timeInterval;

+ (NSString *)getSpecialShowTimeWithDate:(NSDate *)createDate;

+ (NSString *)getSpecialNumber:(NSInteger)number;

+ (NSString *)getWeekWithInterval:(NSInteger)interval;

/**是否在某个时间段内*/
+ (BOOL)isIntimeWithBeginTimeInterval:(NSTimeInterval)begin endTimeInterval:(NSTimeInterval)end;

/**是否在某个时间之前*/
+ (BOOL)isEarlierTimeInterval:(NSTimeInterval)interval;

/** 打开 app 设置 */
+ (void)openAppSetting;


@end
