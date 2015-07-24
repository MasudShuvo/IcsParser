//
//  ViewController.m
//  IcsParser
//
//  Created by Shuvo on 7/20/15.
//  Copyright (c) 2015 Shuvo. All rights reserved.
//

#import "ViewController.h"
#import "MSCalendarICSParser.h"
#import "MSEventRecurrence.h"
#import "MSCalendarEvent.h"
#import "MSCalendarAlarm.h"
#import "MSCalendarUtility.h"

@interface ViewController () <MSCalendarICSParserDelegate>

@property (nonatomic, strong) MSEventRecurrence *eventRecurrence;
@property (nonatomic, strong) MSCalendarICSParser	*icsParser;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initParser];
    [self loadIcsFromLocal];
    
    //for remote ics file
    //[self parseIcs:@"remote_ICS_Link_here"];
}

- (void)initParser
{
    self.icsParser = [[MSCalendarICSParser alloc] init];
    self.icsParser.delegate = self;
    self.eventRecurrence = [[MSEventRecurrence alloc] init];
}

- (void)parseIcs:(NSString *)string
{
    NSError *error	= nil;
    NSURL * urlToRequest = [NSURL   URLWithString:string];
    NSString *content = [NSString stringWithContentsOfURL:urlToRequest
                                                 encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"error : %@",[error description]);
    }
    else {
        [self.icsParser allEvents:content];
    }
}

- (void)loadIcsFromLocal
{
    NSURL *icsPath = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"ics"];
    NSString *pathString = [icsPath absoluteString];
    
    [self parseIcs:pathString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MSCalendarICSParserDelegate method

- (void)icsParserDidFinishParsing
{
    EKEventStore *store = [[EKEventStore alloc] init];
    
    for (MSCalendarEvent *calendarEvent in self.icsParser.eventArray)
    {
        //create EKEvent object with parsed data
        NSString		*recurrenceRule = nil;
        NSDate	*parsedStartDate	= [MSCalendarUtility retrieveDateFromString:calendarEvent.startTime];
        NSDate	*parsedEndDate		= [MSCalendarUtility retrieveDateFromString:calendarEvent.endTime];
        
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.location	= calendarEvent.location;
        event.title		= calendarEvent.name;
        event.notes		= calendarEvent.eventDescription;
        event.alarms	= [MSCalendarUtility eventAlarm:calendarEvent.alarmList];
        event.startDate = parsedStartDate;
        event.endDate	= parsedEndDate;
        event.URL		= [NSURL URLWithString:calendarEvent.URL];
        recurrenceRule	= calendarEvent.recurrenceRule;
        
        if ([recurrenceRule length] > 0) {
            // setting recurrenceRules for the event.
            [event addRecurrenceRule:[self.eventRecurrence recurrenceRuleForRecurrenceString:recurrenceRule]];
        }
        NSLog(@"%@",[event description]);
    }
}

@end
