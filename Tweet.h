//
//  Tweet.h
//  TwReader
//
//  Created by bluebox on 19/05/23.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Tweet : NSObject {
	id delegate;
	NSMutableDictionary *raw;
	NSImage	*mUserIcon;
	NSImage	*mUserIconTrimmed;
	NSString *mDisplayDate;
	NSString *mFullDate;
	
	NSString *mTweet;
	NSString *mFullTweet;
	
	NSImage *mImages[4];
	QTMovie *mMovie;
}

+ (Tweet*)initWithTweetDictionary:(NSDictionary*) dict;
+ (Tweet*)initWithTweetDictionary:(NSDictionary*) dict withDelegate:(id)del;
- (void)setTweet:(NSDictionary*) dict;
- (void)setDelegate:(id) del;
- (NSString*) user;
- (NSString*) fullTweet;
- (NSString*) tweet;
- (NSString*) date;
- (NSImage*) icon;
- (NSImage*) iconRaw;
- (NSImage*) fullImage:(NSUInteger)idx;
- (NSString*) fullImageSrc:(NSUInteger)idx;
- (BOOL) hasMovie;
- (void)loadMovieAsync;
@end
