//
//  TwitterDateTimeFormatter.m
//  TwReader
//
//  Created by bluebox on 19/05/27.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "TwitterDateTimeFormatter.h"


@implementation TwitterDateTimeFormatter

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (TwitterDateTimeFormatter*)init{
	self = [super init];
	
	formatterQueue = dispatch_queue_create("TwitterDateTimeFormatter queue", DISPATCH_QUEUE_SERIAL);
	dateFormatterParser = [[NSDateFormatter alloc] init];
	dateFormatterParser.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	dateFormatterParser.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
	dateFormatterParser.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	dateFormatterFull = [[NSDateFormatter alloc] init];
	dateFormatterFull.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	dateFormatterFull.dateFormat = @"yyyy/MM/dd HH:mm:ss";
	dateFormatterShort = [[NSDateFormatter alloc] init];
	dateFormatterShort.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	dateFormatterShort.dateFormat = @"HH:mm:ss";

	return self;
}

- (NSString*) shortDateForDate:(NSString*)date {
	__block NSString *res;
	dispatch_sync(formatterQueue, ^{
	res = [dateFormatterShort stringFromDate:[dateFormatterParser dateFromString:date]];
	});
	return res;
}

- (NSString*) longDateForDate:(NSString*)date {
	__block NSString *res;
	dispatch_sync(formatterQueue, ^{
	res = [dateFormatterFull stringFromDate:[dateFormatterParser dateFromString:date]];
	});
	return res;
}

@end
