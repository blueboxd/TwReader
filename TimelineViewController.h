//
//  TimelineViewController.h
//  TwReader
//
//  Created by bluebox on 19/05/25.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

#define kTimeLineWindowClosed @"kTimeLineWindowClosed"
@interface TimelineViewController : NSViewController {
	IBOutlet __weak NSArrayController *tweetsArrayController;
	IBOutlet  NSWindow *timelineWindow;
	IBOutlet __weak NSTableView *timelineTableView;
	IBOutlet __weak NSDrawer *tweetDetailDrawer;
	IBOutlet __weak NSView *tweetDetailDrawerView;
	IBOutlet __weak NSView *tweetDetailFooterView;
	IBOutlet  NSTextView *tweetDetailTweetTextVIew;
	IBOutlet  NSPanel *pictureDetailWindow;
	IBOutlet __weak NSImageView *pictureDetailView;
	IBOutlet  NSPanel *movieDetailWindow;
	IBOutlet __weak QTMovieView *movieDetailView;

}


- (IBAction) imageClicked:(id)sender;

@end
