//
//  LLZHelper.m
//  JPUSH
//
//  Created by 柳麟喆 on 2017/12/24.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "LLZHelper.h"

@implementation LLZHelper

/**
 字符串转日期

 @param string 字符串
 @param formatter 格式
 @return 日期
 */
+ (NSDate *)LLZDateFromString:(NSString *)string Formatter:(NSString *)formatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    NSDate *date = [dateFormatter dateFromString:string];
    return date;
}

/**
 日期转字符串

 @param date 日期
 @param formatter 格式
 @return 字符串
 */
+ (NSString *)LLZStringFromDate: (NSDate *)date Formatter:(NSString *)formatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    NSString *string = [dateFormatter stringFromDate:date];
    return string;
}


/**
  (dateA)与(当前时刻)比大小

 @param dateA 比较的时间
 @return 1(当前时刻小) or -1（当前时刻大）
 */
+ (int)LLZCompareCurrentTime:(NSDate *)dateA
{
    NSTimeInterval timeInterval = [dateA timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp=0;
    if((temp = timeInterval) >0){
        return 1;
    }
    return -1;
}
@end
