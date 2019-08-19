//
//  NSDate+HHExtension.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import "NSDate+HHExtension.h"

@implementation NSDate (HHExtension)

/**1.date根据时间格式转成string*/
- (NSString *)dateToStringWithFormat:(NSString *)format;
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
    return [dateFormatter stringFromDate:self];
}

/**2.字符串根据时间格式转成date*/
+ (NSDate *)stringToDate:(NSString *)timeString dateFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
    return [dateFormatter dateFromString:timeString];
}

/** 3.获取当前的时间 yyyy-MM-dd HH:mm:ss*/
+ (NSString *)currentDateString {
    
    return [self currentDateStringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

/** 4.按指定格式获取当前的时间*/
+ (NSString *)currentDateStringWithFormat:(NSString *)format {
    // 获取系统当前时间
    NSDate *currentDate = [NSDate date];
    // 用于格式化NSDate对象
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置格式：yyyy-MM-dd HH:mm:ss
    formatter.dateFormat = format;
    // 将 NSDate 按 formatter格式 转成 NSString
    NSString *currentDateStr = [formatter stringFromDate:currentDate];
    // 输出currentDateStr
    return currentDateStr;
}

/**5.获取时间串前几秒的时间*/
+ (NSString *)calculateTimeAnySecondsAgo:(double)second WithConvertTimeStr:(NSString *)timeStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *currentDate = [formatter dateFromString:timeStr];
    NSTimeInterval currentT = [currentDate timeIntervalSince1970];
    NSTimeInterval resultT = currentT - second;
    NSDate *resultDate = [NSDate dateWithTimeIntervalSince1970:resultT];
    return [formatter stringFromDate:resultDate];
}

/**6.获取时间串后几秒的时间*/
+ (NSString *)calculateTimeAnySecondsAfter:(double)second WithConvertTimeStr:(NSString *)timeStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *currentDate = [formatter dateFromString:timeStr];
    NSTimeInterval currentT = [currentDate timeIntervalSince1970];
    NSTimeInterval resultT = currentT + second;
    NSDate *resultDate = [NSDate dateWithTimeIntervalSince1970:resultT];
    return [formatter stringFromDate:resultDate];
}

/**7.获取时长:自己判断时间段  刚刚，1分钟前..*/
+ (NSString *)calSubscribeTimeWithTime:(NSString *)time
{
    //把字符串转为NSdate
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *timeDate = [dateFormatter dateFromString:time];
    //得到与当前时间差 s
    NSTimeInterval timeInterval = [timeDate timeIntervalSinceNow];
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    }else if((temp = timeInterval/60) < 60){
        result = [NSString stringWithFormat:@"%ld%@",temp, @"分钟"];
    }else
    {
        NSArray *dateAndTime = [time componentsSeparatedByString:@" "];
        if (dateAndTime.count > 0) {
            result = [NSString stringWithFormat:@"%@ %@",dateAndTime[0], @"开始"];
        }else
        {
            result = @"";
        }
        
    }
    return  result;
}

+ (BOOL)startTime:(NSString *)startTime isEarlyThanEndTime:(NSString *)endTime Format:(NSString *)format
{
    NSString *dateFormat = format?format:@"yyyy-MM-dd HH:mm:ss";
    //按照日期格式创建日期格式句柄
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    //将日期字符串转换成Date类型
    NSDate *startDate = [dateFormatter dateFromString:startTime];
    NSDate *endDate = [dateFormatter dateFromString:endTime];
    //将日期转换成时间戳
    NSTimeInterval start = [startDate timeIntervalSince1970]*1;
    NSTimeInterval end = [endDate timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    
    if (value > 0) {
        return YES;
    }else
    {
        return NO;
    }
}
@end
