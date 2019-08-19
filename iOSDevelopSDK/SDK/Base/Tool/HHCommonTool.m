//
//  HHCommonTool.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import "HHCommonTool.h"

@implementation HHCommonTool

+ (int)parseInt:(NSObject *)value
{
    if (value == nil || [value isKindOfClass:[NSNull class]])
    {
        return 0;
    }
    return ((NSNumber *)value).intValue;
}

+ (long long)parseLongLong:(NSObject *)value
{
    if (value == nil || [value isKindOfClass:[NSNull class]])
    {
        return 0;
    }
    return ((NSNumber *)value).longLongValue;
}

+ (NSString *)parseString:(NSObject *)value
{
    if (value == nil || [value isKindOfClass:[NSNull class]] || ![value isKindOfClass:[NSString class]])
    {
        return @"";
    }
    return (NSString *)value;
}
+ (NSString *)parseStringToZero:(NSObject *)value
{
    
    if ([[self parseString:value] isEqualToString:@""]) {
        return @"0";
    }
    return (NSString *)value;
}
/** 如果不是string 转换为string */
+ (NSString *)parseAutoConversionString:(NSObject *)value
{
    if (value == nil || [value isKindOfClass:[NSNull class]])
    {
        return @"";
    }
    
    if (![value isKindOfClass:[NSString class]])
    {
        return [NSString stringWithFormat:@"%@", value];
    }
    return (NSString *)value;
}

+ (double)parseDouble:(NSObject *)value
{
    if (value == nil || [value isKindOfClass:[NSNull class]])
    {
        return 0.0;
    }
    return ((NSNumber *)value).doubleValue;
}

+ (NSArray *)parseArray:(NSObject *)value
{
    if (value == nil || [value isKindOfClass:[NSNull class]] || ![value isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    return (NSArray *)value;
}

+ (NSArray *)parseInitArray:(NSObject *)value
{
    NSArray *array = [self parseArray:value];
    if (!array)
    {
        return @[];
    }
    return array;
}

+ (NSDictionary *)parseDictionary:(NSObject *)value
{
    if (value == nil || [value isKindOfClass:[NSNull class]] || ![value isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }
    return (NSDictionary *)value;
}

+ (NSDictionary *)parseInitDictionary:(NSObject *)value
{
    NSDictionary *dict = [self parseDictionary:value];
    if (!dict)
    {
        return @{};
    }
    return dict;
}

/** 是否是空字符串 */
+ (BOOL)isNullString:(NSString *)string
{
    return [[HHCommonTool parseString:string] isEqualToString:@""];
}

/** 是否是空数组 */
+ (BOOL)isNullArray:(NSArray *)stringArray
{
    return [HHCommonTool parseArray:stringArray].count == 0;
}

+ (BOOL)isDic:(id)obj{
    return (obj && [obj isKindOfClass:[NSDictionary class]]);
}

+ (BOOL)isEqulImage:(UIImage *)img1 Image:(UIImage *)img2{
    
    if ([UIImagePNGRepresentation(img1) isEqual:UIImagePNGRepresentation(img2)]) {
        return YES;
    }
    return NO;
    
}

/**是否是手机号*/
+ (BOOL)isMobile:(NSString *)mobile{
    NSString *MOBILE = @"^((1[3-9])|(92)|(98))\\d{9}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    return [regextestmobile evaluateWithObject:mobile];
}

/**是否是邮编*/
+ (BOOL)isPostcode:(NSString *)code{
    if (code.length == 6) {
        return YES;
    }
    return NO;
}

#pragma mark - 过滤空数据
/** 过滤空数据数组 */
+ (NSArray *)getFilterNilDataWithArray:(NSArray *)dataArray
{
    return [HHCommonTool getFilterNilClassWithArray:dataArray objectClass:[NSObject class]];
}

/** 过滤空字符串数组 */
+ (NSArray *)getFilterNilStringWithArray:(NSArray *)stringArray
{
    return [HHCommonTool getFilterNilClassWithArray:stringArray objectClass:[NSString class]];
}

/** 过滤指定类型空数据数组 */
+ (NSArray *)getFilterNilClassWithArray:(NSArray *)sourceArray objectClass:(Class)aClass
{
    NSMutableArray *filterArray = [NSMutableArray array];
    NSArray *parseArray = [HHCommonTool parseArray:sourceArray];
    if (!parseArray || parseArray.count == 0)
    {
        return filterArray;
    }
    
    for (int i = 0; i < parseArray.count; i++)
    {
        NSObject *iObject = parseArray[i];
        if (iObject == nil || [iObject isKindOfClass:[NSNull class]] || ![iObject isKindOfClass:aClass])
        {
            continue;
        }
        [filterArray addObject:iObject];
    }
    return filterArray;
}



/** 手机号 显示 XXX****XXXX */
+ (NSString *)getPhoneNumberEncryptStringWithPhoneNumberString:(NSString *)phoneNumber
{
    if ([HHCommonTool isNullString:phoneNumber] || phoneNumber.length != 11)
    {
        return [HHCommonTool parseString:phoneNumber];
    }
    
    return [[HHCommonTool parseString:phoneNumber] stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
}

// encoding
+ (NSString *)getEncodingStringFromString:(NSString *)string
{
    return [[HHCommonTool parseString:string] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

+ (NSString *)getJsonStringFromDictionary:(NSDictionary *)dictionary
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    
    if (!jsonData)
    {
        
        return @"{}";
    }
    else
    {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


+ (NSString *)getStringWithNowDateTimeInterval
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
    long long int date = (long long int)time;
    return [NSString stringWithFormat:@"%lld", date];
}

+ (NSString *)getSpecialShowTimeWithTimeInterval:(NSTimeInterval)timeInterval{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return [self getSpecialShowTimeWithDate:date];
}

+ (NSString *)getSpecialShowTimeWithDate:(NSDate *)createDate
{
    NSTimeInterval createDateInterval = [createDate timeIntervalSince1970];
    
    //获取视频发布日期的月日
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSMonthCalendarUnit|NSDayCalendarUnit fromDate:createDate];
    NSInteger videoMonth = [components month];
    NSInteger videoDay = [components day];
    
    NSDate *currentDate;
    currentDate = [NSDate date];
    
    NSTimeInterval currentInterval = [currentDate timeIntervalSince1970];
    NSInteger releaseTimeStr = currentInterval - createDateInterval;
    //    NSInteger seconds =releaseTimeStr % 60;
    NSInteger mimutes =(releaseTimeStr / 60) % 60;
    NSInteger hours =releaseTimeStr / 3600;
    NSInteger days =hours / 24;
    NSString *newTime;
    if (days > 0) {
        newTime = [NSString stringWithFormat:@"%ld月%ld日", (long)videoMonth, (long)videoDay];
    } else if (hours > 0) {
        newTime = [NSString stringWithFormat:@"%ld小时前", (long)hours];
    } else if (mimutes > 1) {
        newTime = [NSString stringWithFormat:@"%ld分钟前", (long)mimutes];
    } else {
        newTime = [NSString stringWithFormat:@"刚刚"];
    }
    
    return newTime;
}

+ (NSString *)getSpecialNumber:(NSInteger)number
{
    NSString *specialNmuber;
    if (number < 1e4) {
        specialNmuber = [NSString stringWithFormat:@"%ld",(long)number];
    } else if (number < 1e8) {
        specialNmuber = [NSString stringWithFormat:@"%.1f万",(number / 10000.0)];
    } else{
        specialNmuber = [NSString stringWithFormat:@"%.1f亿",(number / 100000000.0)];
    }
    return specialNmuber;
}


/**是否在某个时间段内*/
+ (BOOL)isIntimeWithBeginTimeInterval:(NSTimeInterval)begin endTimeInterval:(NSTimeInterval)end{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now >= begin && now <= end) {
        return YES;
    }
    return NO;
}

+ (BOOL)isEarlierTimeInterval:(NSTimeInterval)interval{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now <= interval) {
        return YES;
    }
    return NO;
}

+ (NSString *)getWeekWithInterval:(NSInteger)interval{
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    
    [calendar setTimeZone:timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:date];
    
    return [weekdays objectAtIndex:theComponents.weekday];
    
}

#pragma mark -
/** 分隔字符串 以英文逗号分隔 */
+ (NSArray *)getStringArrayWithString:(NSString *)string
{
    return [HHCommonTool getStringArrayrWithString:string separator:@","];
}

/** 分隔字符串 以英文|分隔 */
+ (NSArray *)getStringArrayVerticalLineSeparatorWithString:(NSString *)string
{
    return [HHCommonTool getStringArrayrWithString:string separator:@"|"];
}

/** 分隔字符串 以英文|分隔 */
+ (NSArray *)getStringArrayrWithString:(NSString *)string
                             separator:(NSString *)separatorString
{
    NSString *sourceString = [HHCommonTool parseAutoConversionString:string];
    if ([HHCommonTool isNullString:sourceString])
    {
        return @[];
    }
    
    if ([HHCommonTool isNullString:separatorString])
    {
        return @[string];
    }
    return [sourceString componentsSeparatedByString:separatorString];
}

// 拼接字符串
+ (NSString *)getStringWithStringArray:(NSArray *)stringArray
{
    return [HHCommonTool getStringWithStringArray:stringArray
                                        separator:@","];
}

// 拼接字符串
+ (NSString *)getStringVerticalLineSeparatorWithStringArray:(NSArray *)stringArray
{
    return [HHCommonTool getStringWithStringArray:stringArray
                                        separator:@"|"];
}

// 指定分隔符
+ (NSString *)getStringWithStringArray:(NSArray *)stringArray
                             separator:(NSString *)separatorString
{
    NSArray *sourceArray = [HHCommonTool getFilterNilStringWithArray:stringArray];
    
    if (![HHCommonTool parseArray:sourceArray] || sourceArray.count == 0)
    {
        return @"";
    }
    
    if (stringArray.count == 1)
    {
        return [sourceArray firstObject];
    }
    
    NSMutableString *jointString = [NSMutableString stringWithString:sourceArray[0]];
    for (int i = 1; i < sourceArray.count; i++)
    {
        [jointString appendString:[NSString stringWithFormat:@"%@%@", separatorString, sourceArray[i]]];
    }
    return jointString;
}


// 去掉前后空格和换行符
+ (NSString *)getFiltrateSapceString:(NSString *)sourceString
{
    return [[HHCommonTool parseString:sourceString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


/** 返回区间字符串 */
+ (NSString *)getInterzoneStringWithStartNumber:(int)startNumber
                                     stopNumber:(int)stopNumber
                                           unit:(NSString *)unit
{
    if (startNumber >= stopNumber || stopNumber <= 0)
    {
        return [NSString stringWithFormat:@"%d%@", startNumber, unit];
    }
    return [NSString stringWithFormat:@"%d-%d%@", startNumber, stopNumber, unit];
}


#pragma mark - 文本格式


/** 设置文本样式、行间距等 */
+ (NSMutableParagraphStyle *)getTextAttribtueParagraphLineSpacing:(float)lineSpacing
{
    /* 文本样式 */
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    /* 设置行间距 */
    paragraphStyle.lineSpacing = lineSpacing;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    return paragraphStyle;
}


#pragma mark - network head


/** 添加网络请求前缀的key */
+ (NSString *)getNetworkHeadPrefixKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%@", key];
}

#pragma mark -
/** 打开 app 设置 */
+ (void)openAppSetting
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}



@end
