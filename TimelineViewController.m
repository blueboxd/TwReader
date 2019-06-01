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

//@synthesize tweetsArrayController;
//@synthesize timelineWindow;
//@synthesize timelineTableView;
//@synthesize tweetDetailTweetTextVIew;
//@synthesize tweetDetailDrawer;
//@synthesize tweetDetailDrawerView;
//@synthesize tweetDetailFooterView;
//@synthesize pictureDetailWindow;
//@synthesize pictureDetailView;
//
//@synthesize movieDetailWindow;
//@synthesize movieDetailView;

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

- (NSSize)drawerWillResizeContents:(NSDrawer *)sender toSize:(NSSize)contentSize {
	NSRect textRect = [tweetDetailTweetTextVIew frame];
	NSRect footerRect = [tweetDetailFooterView frame];
	footerRect.origin.y = textRect.origin.y-footerRect.size.height;
	[tweetDetailFooterView setFrame:footerRect];

	return contentSize;
}

-(void) finishedLoadIconAsync {

	dispatch_async(dispatch_get_main_queue(), ^{
//		[tweetsArrayController rearrangeObjects];
		[timelineTableView reloadData];
	});
}

-(void) finishedLoadImageAsync {
	[self reselectCurrentSelection];
}

-(void) reselectCurrentSelection {
	dispatch_async(dispatch_get_main_queue(), ^{
		NSIndexSet *index = [tweetsArrayController selectionIndexes];
		[tweetsArrayController setSelectionIndexes:[NSIndexSet indexSet]];
		[tweetsArrayController setSelectionIndexes:index];
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
//	NSLog(@"%@",notification);
	if(notification.object == movieDetailWindow)
		[movieDetailView pause:self];

	if(notification.object == timelineWindow) {
//		timelineTableView = nil;
//		tweetDetailDrawerView = nil;
//		tweetDetailFooterView = nil;
//		tweetsArrayController =nil;
		[[NSNotificationCenter defaultCenter] postNotificationName:kTimeLineWindowClosed object:self];
	}

}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if(![NSThread isMainThread])
		NSLog(@"%@",[NSThread currentThread]);
//	dispatch_async(dispatch_get_main_queue(), ^{
		if([[tweetsArrayController selectedObjects] count]==0)return;
		if(![cell isKindOfClass:[NSTextFieldCell class]])return;
		
		Tweet *selected = [tweetsArrayController selectedObjects][0];
		Tweet *current = [tweetsArrayController arrangedObjects][row];
	//	NSLog(@"%u:%@/%@",row,[selected user],[current user]);
	//	NSLog(@"%u:%@/%@",row,[selected mentionedStatusID],[current statusID]);
		if ([[selected user] isEqualToString:[current user]]) {
			[cell setBackgroundColor:[NSColor colorWithDeviceRed:0.9 green:0.9 blue:0.9 alpha:1]];
		} else if (
			(([selected mentionedStatusID]!=[NSNull null]) && ([current mentionedStatusID]!=[NSNull null]))
			&& ([[current statusID] isEqualToString:[selected mentionedStatusID]] || [[selected statusID] isEqualToString:[current mentionedStatusID]])) {
			[cell setBackgroundColor:[NSColor colorWithDeviceRed:0.95 green:0.85 blue:0.85 alpha:1]];
		} else if (
			([selected mentionedUser]!=[NSNull null]) &&
			([[current user] isEqualToString:[selected mentionedUser]]))
			{
			[cell setBackgroundColor:[NSColor colorWithDeviceRed:0.85 green:0.95 blue:0.85 alpha:1]];
		} else {
			[cell setBackgroundColor:[NSColor controlBackgroundColor]];
		}
//	});

}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
//	NSLog(@"%u",row);
	if([[tweetsArrayController selectionIndexes] firstIndex]==row)
		return 48.0f;
	else {
		return 16.0f;
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
//	NSLog(@"tableViewSelectionDidChange:%@",notification);
//	[timelineTableView reloadDataForRowIndexes:[tweetsArrayController selectionIndexes] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
//    NSTableColumn *column = [timelineTableView tableColumnWithIdentifier:@"tweet"];
//    NSCell *cell = [column dataCellForRow:[[notification object] selectedRow]];
//	cell.wraps = YES;
//	NSLog(@"%@",cell);

	[timelineTableView reloadData];
}

@end
