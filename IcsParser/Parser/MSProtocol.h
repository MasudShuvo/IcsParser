//
//  MSProtocol.h
//  IcsParser
//
//  Created by Shuvo on 7/24/15.
//  Copyright (c) 2015 Shuvo. All rights reserved.
//

@protocol MSCalendarICSParserDelegate <NSObject>
@required
- (void)icsParserDidFinishParsing;
@end