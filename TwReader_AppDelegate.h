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

@interface TwReader_AppDelegate : NSObject <NSTableViewDelegate>
{
    NSWindow *window;
	GDataOAuthAuthentication *mAuth;
	NSString *sinceID;
}

@property (nonatomic, strong, retain) IBOutlet NSWindow *window;
@property (nonatomic, strong, retain) IBOutlet NSArrayController *tweetsArrayController;
@property (nonatomic, strong, retain) IBOutlet NSMutableArray *tweetsArray;
@property (nonatomic, strong, retain) IBOutlet NSTableView *timelineTableView;

@property (nonatomic, strong, retain) IBOutlet NSDrawer *tweetDetailDrawer;
@property (nonatomic, strong, retain) IBOutlet NSView *tweetDetailDrawerView;
@property (nonatomic, strong, retain) IBOutlet NSImageView *tweetDetailImage1;

@property (nonatomic, strong, retain) IBOutlet NSTextView *tweetDetailTweetTextVIew;
@end