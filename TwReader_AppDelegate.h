//
//  TwReader_AppDelegate.h
//  TwReader
//
//  Created by bluebox on 19/05/16.
//  Copyright __MyCompanyName__ 2019 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "GDataOAuthWindowController.h"

#import "TimelineViewController.h"

@interface TwReader_AppDelegate : NSObject <NSTableViewDelegate>
{
 	GDataOAuthAuthentication *mAuth;
	NSString *sinceID;
}


@property (nonatomic, strong, retain) IBOutlet NSArrayController *tweetsArrayController;
@property (nonatomic, strong, retain) IBOutlet NSMutableArray *tweetsArray;
@property (nonatomic, strong, retain) IBOutlet TimelineViewController *tvc;
@end

