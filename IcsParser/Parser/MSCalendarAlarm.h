//
//  MSCalendarAlarm.h
//
//  Created by Shuvo on 2/17/15.
//  Copyright (c) 2015 Shuvo . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSCalendarAlarm : NSObject
@property (nonatomic, strong) NSString	*triggerTime;
@property (nonatomic, assign) BOOL		isDate;

- (id)initWithTriggerTime:(NSString *)triggerTime isDate:(BOOL)isDate;
@end
