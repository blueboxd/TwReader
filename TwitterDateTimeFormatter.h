//
//  TwitterDateTimeFormatter.h
//  TwReader
//
//  Created by bluebox on 19/05/27.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TwitterDateTimeFormatter : NSObject {
	NSDateFormatter *dateFormatterParser;
	NSDateFormatter *dateFormatterFull;
	NSDateFormatter *dateFormatterShort;
	dispatch_queue_t formatterQueue;
}

+ (instancetype)sharedInstance;
- (NSString*) shortDateForDate:(NSString*)date;
- (NSString*) longDateForDate:(NSString*)date;

@end
