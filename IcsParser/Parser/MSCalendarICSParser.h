//
//  MSCalendarICSParser.h
//
//  Created by Shuvo on 2/17/15.
//  Copyright (c) 2015 Shuvo . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSProtocol.h"

@interface MSCalendarICSParser : NSObject
@property (nonatomic, strong) NSString			*calendarName;
@property (nonatomic, strong) NSMutableArray	*eventArray;
@property (nonatomic, assign) id <MSCalendarICSParserDelegate> delegate;

- (void)allEvents:(NSString *)icsString;
- (void)reset;
@end

