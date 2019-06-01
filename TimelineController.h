//
//  TimelineController.h
//  TwReader
//
//  Created by bluebox on 19/05/25.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GDataOAuthWindowController.h"

#import "TimelineViewController.h"
#import "NSImage+MGCropExtensions.h"
#import "Tweet.h"


@interface TimelineController : NSObject {
	NSString *sinceID;
	NSTimer *refreshTimer;
	IBOutlet NSArrayController *tweetsArrayController;
	IBOutlet TimelineViewController *timelineViewController;
	NSArray *topLevelObjects;
}

@property (nonatomic) GDataOAuthAuthentication *mAuth;
@property (nonatomic) NSString *windowTitle;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *filePath;
@property (nonatomic) NSMutableArray *tweetsArray;
@property (nonatomic) NSTimeInterval refreshTimerInterval;

+ initWithAuth:(GDataOAuthAuthentication*)auth forURL:(NSString*)url;
+ initForFilePath:(NSURL*)path;
- (void)start;
@end
