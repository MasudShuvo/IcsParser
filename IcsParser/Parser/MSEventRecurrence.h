//
//  MSEventRecurrence.h
//
//  Created by Shuvo on 2/17/15.
//  Copyright (c) 2015 Shuvo . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface MSEventRecurrence : NSObject

- (EKRecurrenceRule *)recurrenceRuleForRecurrenceString:(NSString *)rRule;
- (void)reset;
@end
