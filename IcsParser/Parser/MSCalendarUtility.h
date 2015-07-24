//
//  MSCalendarUtility.h
//
//  Created by Shuvo on 2/17/15.
//  Copyright (c) 2015 Shuvo . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface MSCalendarUtility : NSObject

+ (EKRecurrenceFrequency)recurrenceFrequencyFromString:(NSString *)string;
+ (NSDate *)retrieveDateFromString:(NSString *)string;
+ (NSString *)retriveWeekDay:(NSString *)byDayString;
+ (NSInteger)weekdayToInt:(NSString *)weekDay;
+ (NSInteger)relativeTimeOffsetForAlarm:(NSString *)triggerString;
+ (NSInteger)multiplierToCalculateTime:(char)character;
+ (NSDate *)dateFromString:(NSString *)dateString;
+ (NSArray *)eventAlarm:(NSArray *)alarmList;

@end
