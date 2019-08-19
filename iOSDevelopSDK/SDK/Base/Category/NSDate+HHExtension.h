//
//  NSDate+HHExtension.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMinuteTimeInterval (60)
#define kHourTimeInterval   (60 * kMinuteTimeInterval)
#define kDayTimeInterval    (24 * kHourTimeInterval)
#define kWeekTimeInterval   (7  * kDayTimeInterval)
#define kMonthTimeInterval  (30 * kDayTimeInterval)
#define kYearTimeInterval   (12 * kMonthTimeInterval)

@interface NSDate (HHExtension)

/** 1.date根据时间格式转成string*/
- (NSString *)dateToStringWithFormat:(NSString *)format;

/** 2.字符串根据时间格式转成date*/
+ (NSDate *)stringToDate:(NSString *)timeString dateFormat:(NSString *)format;

/** 3.获取当前的时间 yyyy-MM-dd HH:mm:ss*/
+ (NSString *)currentDateString;

/** 4.按指定格式获取当前的时间*/
+ (NSString *)currentDateStringWithFormat:(NSString *)format;

/**5.获取时间串前几秒的时间*/
+ (NSString *)calculateTimeAnySecondsAgo:(double)second WithConvertTimeStr:(NSString *)timeStr;

/**6.获取时间串后几秒的时间*/
+ (NSString *)calculateTimeAnySecondsAfter:(double)second WithConvertTimeStr:(NSString *)timeStr;

/**7.获取时长:自己判断时间段  刚刚，1分钟前..*/
+ (NSString *)calSubscribeTimeWithTime:(NSString *)time;

/**8.开始时间与结束时间比较*/
+ (BOOL)startTime:(NSString *)startTime isEarlyThanEndTime:(NSString *)endTime Format:(NSString *)format;

@end

