//
//  MSCalendarUtility.m
//
//  Created by Shuvo on 2/17/15.
//  Copyright (c) 2015 Shuvo . All rights reserved.
//

#import "MSCalendarUtility.h"
#import "MSCalendarAlarm.h"

#define SECONDS								1
#define MINUTES								60
#define HOURS								60 * MINUTES
#define DAYS								HOURS * 24

@implementation MSCalendarUtility

+ (EKRecurrenceFrequency)recurrenceFrequencyFromString:(NSString *)string
{
    EKRecurrenceFrequency recurrenceFrequency;
    
    if (string && [string caseInsensitiveCompare:@"yearly"] == NSOrderedSame) {
        recurrenceFrequency = EKRecurrenceFrequencyYearly;
    } else if (string && [string caseInsensitiveCompare:@"monthly"] == NSOrderedSame) {
        recurrenceFrequency = EKRecurrenceFrequencyMonthly;
    } else if (string && [string caseInsensitiveCompare:@"weekly"] == NSOrderedSame) {
        recurrenceFrequency = EKRecurrenceFrequencyWeekly;
    } else {
        recurrenceFrequency = EKRecurrenceFrequencyDaily;
    }
    
    return recurrenceFrequency;
}

+ (NSDate *)retrieveDateFromString:(NSString *)string
{
    NSString *timeZone = nil;
    
    NSRange range = [string rangeOfString:@"TZID="];
    
    if (range.length > 0) {
        string = [string substringFromIndex:range.length];
        
        if ([[string componentsSeparatedByString:@":"] count] > 1) {
            timeZone	= [[string componentsSeparatedByString:@":"] objectAtIndex:0];
            string		= [[string componentsSeparatedByString:@":"] objectAtIndex:1];
        }
    }
    
    if (string == nil) {
        return nil;
    }
    
    if (timeZone.length == 0) {
        timeZone = @"UTC";
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    range = [string rangeOfString:@"VALUE=DATE:"];
    
    if (range.length > 0) {
        string = [string substringFromIndex:range.length];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:timeZone]];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
    } else {
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:timeZone]];
        [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
    }
    
    return [dateFormatter dateFromString:string];
}

+ (NSString *)retriveWeekDay:(NSString *)byDayString
{
    NSString	*weekDay = nil;
    NSRange		range;
    NSArray		*weekDays = [NSArray arrayWithObjects:@"SU", @"MO", @"TU", @"WE", @"TH", @"FR", @"SA", nil];
    
    for (NSUInteger i = 0; i < [weekDays count]; i++) {
        range = [byDayString rangeOfString:[weekDays objectAtIndex:i]];
        
        if (range.length > 0) {
            weekDay = [weekDays objectAtIndex:i];
        }
    }
    
    return weekDay;
}

+ (NSInteger)weekdayToInt:(NSString *)weekDay
{
    NSInteger value = 0;
    
    if (weekDay) {
        if ([weekDay caseInsensitiveCompare:@"SU"] == NSOrderedSame) {
            value = 1;
        } else if ([weekDay caseInsensitiveCompare:@"MO"] == NSOrderedSame) {
            value = 2;
        } else if ([weekDay caseInsensitiveCompare:@"TU"] == NSOrderedSame) {
            value = 3;
        } else if ([weekDay caseInsensitiveCompare:@"WE"] == NSOrderedSame) {
            value = 4;
        } else if ([weekDay caseInsensitiveCompare:@"TH"] == NSOrderedSame) {
            value = 5;
        } else if ([weekDay caseInsensitiveCompare:@"FR"] == NSOrderedSame) {
            value = 6;
        } else if ([weekDay caseInsensitiveCompare:@"SA"] == NSOrderedSame) {
            value = 7;
        }
    }
    
    return value;
}

+ (NSInteger)relativeTimeOffsetForAlarm:(NSString *)triggerString
{
    NSInteger	timeValue		= 0;
    NSInteger	timeOffsetValue = 0;
    
    if (triggerString && ([triggerString length] >= 2)) {
        BOOL positive = YES;
        
        if ([triggerString characterAtIndex:0] == '-') {
            positive = NO;
        }
        
        NSRange range = [triggerString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"T"]];
        
        if (range.location != NSNotFound) {
            triggerString = [triggerString substringFromIndex:range.location + 1];
        } else {
            return timeOffsetValue;
        }
        
        while ([triggerString length] >= 2) {
            range = [triggerString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"WDHMS"]];
            
            if (range.location != NSNotFound) {
                timeValue		= [[triggerString substringToIndex:range.location] integerValue];
                timeValue		*= [MSCalendarUtility multiplierToCalculateTime:[triggerString characterAtIndex:range.location]];
                timeOffsetValue += timeValue;
                triggerString	= [triggerString substringFromIndex:range.location + 1];
            }
        }
        
        if (!positive) {
            timeOffsetValue *= -1;
        }
    }
    
    return timeOffsetValue;
}

+ (NSInteger)multiplierToCalculateTime:(char)character
{
    NSInteger value = 0;
    
    switch (character) {
        case 'W':
            value = 7 * DAYS;
            break;
            
        case 'D':
            value = DAYS;
            break;
            
        case 'H':
            value = HOURS;
            break;
            
        case 'M':
            value = MINUTES;
            break;
            
        case 'S':
            value = SECONDS;
            break;
    }
    return value;
}

+ (NSDate *)dateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
    return [dateFormatter dateFromString:dateString];
}

+ (NSArray *)eventAlarm:(NSArray *)alarmList
{
    NSMutableArray *alarmsArray = [NSMutableArray array];
    
    for (MSCalendarAlarm *alarm in alarmList) {
        if (alarm.isDate) {
            EKAlarm *eventAlarm = [EKAlarm alarmWithAbsoluteDate:[self dateFromString:alarm.triggerTime]];
            [alarmsArray addObject:eventAlarm];
        }
        else {
            NSInteger timeValue = [MSCalendarUtility relativeTimeOffsetForAlarm:alarm.triggerTime];
            if (timeValue != 0) {
                EKAlarm *eventAlarm = [EKAlarm alarmWithRelativeOffset:timeValue];
                [alarmsArray addObject:eventAlarm];
            }
        }
    }
    return alarmsArray;
}


@end
