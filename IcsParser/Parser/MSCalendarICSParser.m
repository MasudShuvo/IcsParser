//
//  MSCalendarICSParser.m
//
//  Created by Shuvo on 2/17/15.
//  Copyright (c) 2015 Shuvo . All rights reserved.
//

#import "MSCalendarICSParser.h"
#import "MSCalendarEvent.h"
#import "MSCalendarAlarm.h"
#import "MSCalendarUtility.h"

NSString *const MSName				= @"X-WR-CALNAME;VALUE=TEXT";
NSString *const MSEventStart		= @"BEGIN:VEVENT";
NSString *const MSEventEnd			= @"END:VEVENT";
NSString *const MSAlarmStart		= @"BEGIN:VALARM";
NSString *const MSAlarmEnd			= @"END:VALARM";
NSString *const MSEventStartTime	= @"DTSTART";
NSString *const MSEventDisplayTime	= @"EVENTDISPLAYTIME";
NSString *const MSEventEndTime		= @"DTEND";
NSString *const MSSummary			= @"SUMMARY";
NSString *const MSCreated			= @"CREATED";
NSString *const MSTStamp			= @"DTSTAMP";
NSString *const MSSequence			= @"SEQUENCE";
NSString *const MSRRule			= @"RRULE";
NSString *const MSUID				= @"UID";
NSString *const MSLocation			= @"LOCATION";
NSString *const MSDescription		= @"DESCRIPTION";
NSString *const MSURL				= @"URL";
NSString *const MSAlarmList        = @"ALARMLIST";
NSString *const MSTrigger          = @"TRIGGER";
NSString *const MSTriggerWithValue = @"TRIGGER;VALUE=DATE-TIME";

@implementation MSCalendarICSParser

- (id)init
{
    if (self = [super init]) {
        self.eventArray = [NSMutableArray array];
    }
    return self;
}

- (NSString *)valueForKey:(NSString *)key inIcsString:(NSString *)icsString
{
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@([^\r\n]+)[\r\n]",key] options:0 error:nil];
    
    return [icsString substringWithRange:[[regularExpression firstMatchInString:icsString options:0 range:NSMakeRange(0, [icsString length])] rangeAtIndex:1]];
    
}

- (void)parseEvents:(NSString *)event
{
    MSCalendarEvent *calendarEvent = [[MSCalendarEvent alloc] init];
    NSMutableArray	*alarmArray = [NSMutableArray array];
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@([\\s\\S]+?)%@",MSAlarmStart,MSAlarmEnd] options:0 error:nil];
    NSArray *eventArray = [regularExpression matchesInString:event
                                                     options:0
                                                       range:NSMakeRange(0,[event length])];
    
    for (NSTextCheckingResult* result in eventArray) {
        [alarmArray addObject:[self parseAlarm:[event substringWithRange:[result rangeAtIndex:1]]]];
    }
    calendarEvent.name = [self valueForKey:[NSString stringWithFormat:@"%@:",MSSummary] inIcsString:event];
    calendarEvent.startTime = [self valueForKey:[NSString stringWithFormat:@"%@;",MSEventStartTime] inIcsString:event];
    calendarEvent.endTime = [self valueForKey:[NSString stringWithFormat:@"%@;",MSEventEndTime] inIcsString:event];
    calendarEvent.createdTime = [self valueForKey:[NSString stringWithFormat:@"%@:",MSCreated] inIcsString:event];
    calendarEvent.timeStamp = [self valueForKey:[NSString stringWithFormat:@"%@:",MSTStamp] inIcsString:event];
    calendarEvent.sequence = [self valueForKey:[NSString stringWithFormat:@"%@:",MSSequence] inIcsString:event];
    calendarEvent.recurrenceRule = [self valueForKey:[NSString stringWithFormat:@"%@:",MSRRule] inIcsString:event];
    calendarEvent.UID = [self valueForKey:[NSString stringWithFormat:@"%@:",MSUID] inIcsString:event];
    calendarEvent.location = [self valueForKey:[NSString stringWithFormat:@"%@:",MSLocation] inIcsString:event];
    calendarEvent.eventDescription = [self valueForKey:[NSString stringWithFormat:@"%@:",MSDescription] inIcsString:event];
    calendarEvent.URL = [self valueForKey:[NSString stringWithFormat:@"%@:",MSURL] inIcsString:event];
    calendarEvent.alarmList = alarmArray;
    [self.eventArray addObject:calendarEvent];
}

- (MSCalendarAlarm *)parseAlarm:(NSString *)alarm
{
    MSCalendarAlarm *calendarAlarm;
    
    NSString *eventAlarm = [self valueForKey:[NSString stringWithFormat:@"%@:",MSTrigger] inIcsString:alarm];
    
    if (eventAlarm) {
        calendarAlarm = [[MSCalendarAlarm alloc] initWithTriggerTime:eventAlarm isDate:NO];
        return calendarAlarm;
    }
    
    eventAlarm = [self valueForKey:[NSString stringWithFormat:@"%@:",MSTriggerWithValue] inIcsString:alarm];
    
    if (eventAlarm) {
        calendarAlarm = [[MSCalendarAlarm alloc] initWithTriggerTime:eventAlarm isDate:YES];
    }
    return calendarAlarm;
}

- (void)allEvents:(NSString *)icsString
{
    self.calendarName = [self valueForKey:[NSString stringWithFormat:@"%@:",MSName] inIcsString:icsString];
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@([\\s\\S]+?)%@",MSEventStart,MSEventEnd] options:0 error:nil];
    NSArray *eventArray = [regularExpression matchesInString:icsString
                                                     options:0
                                                       range:NSMakeRange(0,[icsString length])];
    
    for (NSTextCheckingResult* result in eventArray) {
        
        [self parseEvents:[icsString substringWithRange:[result rangeAtIndex:1]]];
    }
    
    [self.delegate icsParserDidFinishParsing];
}

- (void)reset
{
    self.calendarName = nil;
    [self.eventArray removeAllObjects];
}

@end
