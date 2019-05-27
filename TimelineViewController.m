//
//  TimelineViewController.m
//  TwReader
//
//  Created by bluebox on 19/05/25.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "TimelineViewController.h"
#import "Tweet.h"

@implementation TimelineViewController

@synthesize tweetsArrayController;
@synthesize timelineWindow;
@synthesize timelineTableView;
@synthesize tweetDetailTweetTextVIew;
@synthesize tweetDetailDrawer;
@synthesize tweetDetailDrawerView;
@synthesize tweetDetailFooterView;
@synthesize pictureDetailWindow;
@synthesize pictureDetailView;

@synthesize movieDetailWindow;
@synthesize movieDetailView;

- (NSString *)windowNibName
{
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"TimelineView";
}

- (void)awakeFromNib {
	[timelineWindow makeKeyAndOrderFront:self];
	[tweetDetailDrawer openOnEdge:NSMaxXEdge];
	[timelineTableView setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fullDate" ascending:NO]]];
	[tweetDetailTweetTextVIew setVerticallyResizable:YES];
//	tweetDetailTweetTextVIew.backgroundColor = [NSColor controlBackgroundColor];
	tweetDetailTweetTextVIew.drawsBackground = NO;
	tweetDetailTweetTextVIew.editable = NO;
	
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
	Tweet *selection = [[tweetsArrayController arrangedObjects] objectAtIndex:row];
	if(selection) {
		[tweetDetailTweetTextVIew.textStorage setAttributedString:[selection fullTweetAttributed]];
		[[tweetDetailTweetTextVIew layoutManager] ensureLayoutForTextContainer:[tweetDetailTweetTextVIew textContainer]];
		NSRect textRect = [tweetDetailTweetTextVIew frame];
		NSRect footerRect = [tweetDetailFooterView frame];
		footerRect.origin.y = textRect.origin.y-footerRect.size.height;
		[tweetDetailFooterView setFrame:footerRect];
//		tweetDetailDrawerView.position = nil;
		[tweetDetailDrawerView setNeedsDisplay:YES];
	}
	return YES;
}

-(void) finishedLoadIconAsync {

	dispatch_async(dispatch_get_main_queue(), ^{
//		[tweetsArrayController rearrangeObjects];
		[timelineTableView reloadData];
	});
}

-(void) finishedLoadImageAsync {
	dispatch_async(dispatch_get_main_queue(), ^{
		[tweetsArrayController rearrangeObjects];
	});
}

- (NSRect) sizeForContentAndCenteringForWindow:(NSWindow*)window contentSize:(NSSize)size {
	CGFloat titleBarHeight = window.frame.size.height - ((NSView*)window.contentView).frame.size.height;
    CGSize windowSize = CGSizeMake(size.width, size.height + titleBarHeight);

    float originX = window.frame.origin.x + (window.frame.size.width - windowSize.width) / 2;
    float originY = window.frame.origin.y + (window.frame.size.height - windowSize.height) / 2;
    NSRect windowFrame = CGRectMake(originX, originY, windowSize.width, windowSize.height);

	CGFloat xPos = NSWidth([[window screen] frame])/2 - NSWidth(windowFrame)/2;
	CGFloat yPos = NSHeight([[window screen] frame])/2 - NSHeight(windowFrame)/2;
	return NSMakeRect(xPos, yPos, NSWidth(windowFrame), NSHeight(windowFrame));
}

- (void) finishedLoadMovieAsync:(QTMovie*)mov {
//	[movieDetailWindow close];
	[movieDetailView pause:self];
	dispatch_async(dispatch_get_main_queue(), ^{
	[movieDetailView setMovie:mov];
	});
	
	NSValue* sizeVal = [mov attributeForKey:QTMovieNaturalSizeAttribute];
	NSSize size = [sizeVal sizeValue];
	dispatch_async(dispatch_get_main_queue(), ^{
	[movieDetailWindow setFrame:[self sizeForContentAndCenteringForWindow:movieDetailWindow contentSize:size] display:NO animate:NO];
	});
	[movieDetailWindow makeKeyAndOrderFront:self];
	[movieDetailView play:self];
}

- (IBAction) imageClicked:(NSControl*)sender {
	Tweet *selection = [tweetsArrayController selectedObjects][0];
	if((sender.tag==1)&&[selection hasMovie]) {
		[selection loadMovieAsync];
		return;
	}
	
	if(sender==pictureDetailView) {
		NSURL *url = [NSURL URLWithString:[selection fullImageSrc:([pictureDetailView tag]-1)]];
		[[NSWorkspace sharedWorkspace] openURL:url];
		[pictureDetailWindow close];
		return;
	}
	
	[pictureDetailWindow close];
//	if([pictureDetailView tag]==sender.tag) {
//		[pictureDetailView setTag:0];
//		return;
//	}

	NSImage *img = [selection fullImage:(sender.tag-1)];
	NSSize size = [img size];
	[pictureDetailView setImage:img];
	[pictureDetailView setTag:sender.tag];
	dispatch_async(dispatch_get_main_queue(), ^{
	[pictureDetailWindow setFrame:[self sizeForContentAndCenteringForWindow:pictureDetailWindow contentSize:size] display:NO animate:NO];
	});
	[pictureDetailWindow makeKeyAndOrderFront:self];
}

- (void)windowWillClose:(NSNotification *)notification {
	NSLog(@"%@",notification);
	if(notification.object == movieDetailWindow)
		[movieDetailView pause:self];

	if(notification.object == timelineWindow)
		[];
		
}

@end
