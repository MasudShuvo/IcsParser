//
//  MSCalendarAlarm.m
//
//  Created by Shuvo on 2/17/15.
//  Copyright (c) 2015 Shuvo . All rights reserved.
//

#import "MSCalendarAlarm.h"

@implementation MSCalendarAlarm

- (id)initWithTriggerTime:(NSString *)triggerTime isDate:(BOOL)isDate
{
    if (self = [super init]) {
        self.triggerTime = triggerTime;
        self.isDate = isDate;
    }
    
    return self;
}

@end
