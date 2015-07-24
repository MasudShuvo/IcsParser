//
//  MSEventRecurrence.m
//
//  Created by Shuvo on 2/17/15.
//  Copyright (c) 2015 Shuvo . All rights reserved.
//

#import "MSEventRecurrence.h"
#import "MSCalendarUtility.h"

@interface MSEventRecurrence ()

@property (nonatomic, assign) EKRecurrenceFrequency frequency;
@property (nonatomic, assign) NSInteger				interval;
@property (nonatomic, strong) EKRecurrenceEnd		*endRecurrence;
@property (nonatomic, strong) NSMutableArray		*monthsOfTheYear;
@property (nonatomic, strong) NSMutableArray		*daysOfTheWeek;
@property (nonatomic, strong) NSMutableArray		*daysOfTheMonth;
@property (nonatomic, strong) NSMutableArray		*weeksOfTheYear;
@property (nonatomic, strong) NSMutableArray		*daysOfTheYear;
@property (nonatomic, strong) NSMutableArray		*setPositions;
@property (nonatomic, strong) NSString				*recurrenceRule;
@end

@implementation MSEventRecurrence
- (id)init
{
	if (self = [super init]) {
        self.frequency = EKRecurrenceFrequencyDaily;
        self.interval = 1;
    }

	return self;
}

- (NSString *)valueForKey:(NSString *)key inIcsString:(NSString *)icsString
{
	NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@([^;]+)", key] options:0 error:nil];
	return [icsString substringWithRange:[[regularExpression firstMatchInString:icsString options:0 range:NSMakeRange(0, [icsString length])] rangeAtIndex:1]];
}

- (void)recurrenceInterval
{
	NSInteger recurrenceInterval = [[self valueForKey:@"INTERVAL=" inIcsString:self.recurrenceRule] integerValue];

	self.interval = recurrenceInterval > 0 ? recurrenceInterval : 1;
}

- (void)recurrenceEnd
{
	NSString *recurrenceEnd = [self valueForKey:@"COUNT=" inIcsString:self.recurrenceRule];

	if ([recurrenceEnd length] > 0) {
		self.endRecurrence = [EKRecurrenceEnd recurrenceEndWithOccurrenceCount:[recurrenceEnd integerValue]];
	}

	recurrenceEnd = [self valueForKey:@"UNTIL=" inIcsString:self.recurrenceRule];

	if ([recurrenceEnd length] > 0) {
		self.endRecurrence = [EKRecurrenceEnd recurrenceEndWithEndDate:[MSCalendarUtility retrieveDateFromString:recurrenceEnd]];
	}
}

- (void)monthsInYear
{
	NSString *monthsInYear = [self valueForKey:@"BYMONTH=" inIcsString:self.recurrenceRule];

	if (([monthsInYear length] > 0) && (self.frequency == EKRecurrenceFrequencyYearly)) {
		self.monthsOfTheYear = [NSMutableArray array];

		for (NSUInteger i = 0; i < [[monthsInYear componentsSeparatedByString:@","] count]; i++) {
			[self.monthsOfTheYear addObject:@ ([[[monthsInYear componentsSeparatedByString:@","] objectAtIndex:i] integerValue])];
		}
	}
}

- (void)daysInWeek
{
	NSString *daysInWeek = [self valueForKey:@"BYDAY=" inIcsString:self.recurrenceRule];

	if (([daysInWeek length] > 0) && (self.frequency != EKRecurrenceFrequencyDaily)) {
		self.daysOfTheWeek = [NSMutableArray array];

		for (NSUInteger i = 0; i < [[daysInWeek componentsSeparatedByString:@","] count]; i++) {
			// checking if there is any -/+ int value starting on weekday. example : BYDAY:-1SU or BYDAY:-1SU,1MO
			if ([[[daysInWeek componentsSeparatedByString:@","] objectAtIndex:i] intValue] != 0) {
				// if the component has weekNumber too then make EKRecurrenceDayOfWeek object using (EKRecurrenceDayOfWeek *)dayOfWeek:(NSInteger)dayOfTheWeek weekNumber:(NSInteger)weekNumber method
				NSInteger weekDay = [MSCalendarUtility weekdayToInt:[MSCalendarUtility retriveWeekDay:[[daysInWeek componentsSeparatedByString:@","] objectAtIndex:i]]];

				if (weekDay != 0) {
					[self.daysOfTheWeek addObject:[EKRecurrenceDayOfWeek dayOfWeek:weekDay weekNumber:[[[daysInWeek componentsSeparatedByString:@","] objectAtIndex:i] integerValue]]];
				}
			} else {
				// if the component does not have weekNumber then make EKRecurrenceDayOfWeek object using (EKRecurrenceDayOfWeek *)dayOfWeek:(NSInteger)dayOfTheWeek method
				NSInteger weekDay = [MSCalendarUtility weekdayToInt:[[daysInWeek componentsSeparatedByString:@","] objectAtIndex:i]];

				if (weekDay != 0) {
					[self.daysOfTheWeek addObject:[EKRecurrenceDayOfWeek dayOfWeek:weekDay]];
				}
			}
		}
	}
}

- (void)weeksInYear
{
	NSString *weeksInYear = [self valueForKey:@"BYWEEKNO=" inIcsString:self.recurrenceRule];

	if (([weeksInYear length] > 0) && (self.frequency == EKRecurrenceFrequencyYearly)) {
		self.weeksOfTheYear = [NSMutableArray array];

		for (NSUInteger i = 0; i < [[weeksInYear componentsSeparatedByString:@","] count]; i++) {
			[self.weeksOfTheYear addObject:@ ([[[weeksInYear componentsSeparatedByString:@","] objectAtIndex:i] integerValue])];
		}
	}
}

- (void)daysInMonth
{
	NSString *daysInMonth = [self valueForKey:@"BYMONTHDAY=" inIcsString:self.recurrenceRule];

	if (([daysInMonth length] > 0) && (self.frequency == EKRecurrenceFrequencyMonthly)) {
		self.daysOfTheMonth = [NSMutableArray array];

		for (NSUInteger i = 0; i < [[daysInMonth componentsSeparatedByString:@","] count]; i++) {
			[self.daysOfTheMonth addObject:@ ([[[daysInMonth componentsSeparatedByString:@","] objectAtIndex:i] integerValue])];
		}
	}
}

- (void)daysInYear
{
	NSString *daysInYear = [self valueForKey:@"BYYEARDAY=" inIcsString:self.recurrenceRule];

	if (([daysInYear length] > 0) && (self.frequency == EKRecurrenceFrequencyYearly)) {
		self.daysOfTheYear = [NSMutableArray array];

		for (NSUInteger i = 0; i < [[daysInYear componentsSeparatedByString:@","] count]; i++) {
			[self.daysOfTheYear addObject:@ ([[[daysInYear componentsSeparatedByString:@","] objectAtIndex:i] integerValue])];
		}
	}
}

- (void)recurrencePosition
{
	NSString *recurrencePosition = [self valueForKey:@"BYSETPOS=" inIcsString:self.recurrenceRule];

	if (([recurrencePosition integerValue] > 0)
		&& ([self.daysOfTheWeek count] > 0)
		&& ([self.daysOfTheMonth count] > 0)
		&& ([self.monthsOfTheYear count] > 0)
		&& ([self.weeksOfTheYear count] > 0)
		&& ([self.daysOfTheYear count] > 0)) {
		self.setPositions = [NSMutableArray array];

		for (NSUInteger i = 0; i < [[recurrencePosition componentsSeparatedByString:@","] count]; i++) {
			[self.setPositions addObject:@ ([[[recurrencePosition componentsSeparatedByString:@","] objectAtIndex:i] integerValue])];
		}
	}
}

- (EKRecurrenceRule *)recurrenceRuleForRecurrenceString:(NSString *)rRule
{
	self.recurrenceRule = rRule;
	self.frequency		= [MSCalendarUtility recurrenceFrequencyFromString:[self valueForKey:@"FREQ=" inIcsString:self.recurrenceRule]];
	[self recurrenceInterval];
	[self recurrenceEnd];
	[self monthsInYear];
	[self daysInWeek];
	[self weeksInYear];
	[self daysInMonth];
	[self daysInYear];
	[self recurrencePosition];

	EKRecurrenceRule *recurrence = [[EKRecurrenceRule alloc]
                                    initRecurrenceWithFrequency:self.frequency
                                    interval:self.interval
                                    daysOfTheWeek:self.daysOfTheWeek
                                    daysOfTheMonth:self.daysOfTheMonth
                                    monthsOfTheYear:self.monthsOfTheYear
                                    weeksOfTheYear:self.weeksOfTheYear
                                    daysOfTheYear:self.daysOfTheYear
                                    setPositions:self.setPositions
                                    end:self.endRecurrence];
	return recurrence;
}

- (void)reset
{
    self.frequency = EKRecurrenceFrequencyDaily;
    self.interval = 1;
    self.endRecurrence = nil;
    self.monthsOfTheYear = nil;
    self.daysOfTheWeek = nil;
    self.daysOfTheMonth = nil;
    self.weeksOfTheYear = nil;
    self.daysOfTheYear = nil;
    self.setPositions = nil;
    self.recurrenceRule = nil;
}
@end