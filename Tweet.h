//
//  Tweet.h
//  TwReader
//
//  Created by bluebox on 19/05/23.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TwitterDateTimeFormatter.h"

@interface Tweet : NSObject {
	__weak id delegate; //__unsafe_unretained
	NSMutableDictionary *raw;
	Tweet *mRewteetedStatus;
	Tweet *mQuotedStatus;	
	
	BOOL mIsRetweet;
	NSDictionary *mUserInfo;
	NSDictionary *mOriginalUserInfo;
	NSDictionary *mStatus;
	NSDictionary *mOriginalStatus;
	NSDictionary *mEntities;
	NSDictionary *mExtendedEntities;
	
	BOOL mIconLoading;
	NSImage	*mUserIcon;
	NSImage	*mUserIconTrimmed;
	NSString *mDisplayDate;
	NSString *mFullDate;
	
	NSString *mTweet;
	NSString *mFullTweet;
	NSAttributedString *mFullTweetAttributed;
	
	NSImage *mImages[4];
	BOOL mImagesLoading[4];
	QTMovie *mMovie;
}

+ (Tweet*)initWithTweetDictionary:(NSDictionary*) dict;
+ (Tweet*)initWithTweetDictionary:(NSDictionary*) dict withDelegate:(id)del;
- (BOOL)setTweet:(NSDictionary*) dict;
- (void)setDelegate:(id) del;
- (NSString*) statusID;
- (NSString*) mentionedStatusID;
- (NSString*) user;
- (NSString*) mentionedUser;
- (NSString*) fullTweet;
- (NSAttributedString*) fullTweetAttributed;
- (NSString*) tweet;
- (NSString*) date;
- (NSImage*) icon;
- (NSImage*) iconRaw;
- (NSImage*) fullImage:(NSUInteger)idx;
- (NSString*) fullImageSrc:(NSUInteger)idx;
- (BOOL) hasMovie;
- (void)loadMovieAsync;
@end
