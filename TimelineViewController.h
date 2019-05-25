//
//  TimelineViewController.h
//  TwReader
//
//  Created by bluebox on 19/05/25.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>


@interface TimelineViewController : NSViewController {

}

@property (nonatomic, strong, retain) IBOutlet NSArrayController *tweetsArrayController;
@property (nonatomic, strong, retain) IBOutlet NSWindow *timelineWindow;

@property (nonatomic, strong, retain) IBOutlet NSTableView *timelineTableView;

@property (nonatomic, strong, retain) IBOutlet NSDrawer *tweetDetailDrawer;
@property (nonatomic, strong, retain) IBOutlet NSView *tweetDetailDrawerView;
@property (nonatomic, strong, retain) IBOutlet NSView *tweetDetailFooterView;

@property (nonatomic, strong, retain) IBOutlet NSTextView *tweetDetailTweetTextVIew;

@property (nonatomic, strong, retain) IBOutlet NSPanel *pictureDetailWindow;
@property (nonatomic, strong, retain) IBOutlet NSImageView *pictureDetailView;

@property (nonatomic, strong, retain) IBOutlet NSPanel *movieDetailWindow;
@property (nonatomic, strong, retain) IBOutlet QTMovieView *movieDetailView;

- (IBAction) imageClicked:(id)sender;

@end
