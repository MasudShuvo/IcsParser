//
//  MSCalendarEvent.h
//
//  Created by Shuvo on 2/17/15.
//  Copyright (c) 2015 Shuvo . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSCalendarEvent : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, strong) NSString *createdTime;
@property (nonatomic, strong) NSString *timeStamp;
@property (nonatomic, strong) NSString *sequence;
@property (nonatomic, strong) NSString *recurrenceRule;
@property (nonatomic, strong) NSString *UID;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *eventDescription;
@property (nonatomic, strong) NSString *URL;
@property (nonatomic, strong) NSArray  *alarmList;
@end
