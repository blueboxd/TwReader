//
//  Tweet.m
//  TwReader
//
//  Created by bluebox on 19/05/23.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "Tweet.h"
#import "NSImage+MGCropExtensions.h"

@implementation Tweet

+ (Tweet*)initWithTweetDictionary:(NSDictionary*) dict {
	Tweet* tw = [self new];
	
	if(![tw setTweet:dict])
		return nil;

	return tw;
}

+ (Tweet*)initWithTweetDictionary:(NSDictionary*) dict withDelegate:(id)del {
	Tweet* tw = [self new];
	if(![tw setTweet:dict])
		return nil;

	[tw setDelegate:del];

	return tw;
}

- (Tweet*) init{
	self = [super init];
	return self;
}

- (instancetype) retain {
	_objc_rootRetain(self);
//	NSLog(@"retain:%@:%ul",self,CFGetRetainCount((__bridge CFTypeRef)self));
//	NSLog(@"%@",[NSThread callStackSymbols]);
	return self;
}

- (instancetype) release {
	_objc_rootRelease(self);
//	NSLog(@"release:%@:%ul",self,CFGetRetainCount((__bridge CFTypeRef)self));
//	NSLog(@"%@",[NSThread callStackSymbols]);
	return self;
}

- (void) dealloc{
	NSLog(@"dealloc:%@",self);
}

- (BOOL)setTweet:(NSDictionary*) dict {
	if(![dict isKindOfClass:[NSDictionary class]])
		return NO;
		
	if(!dict[@"created_at"])
		return NO;

	raw = [dict mutableCopy];

	mDisplayDate = [[TwitterDateTimeFormatter sharedInstance] shortDateForDate:raw[@"created_at"]];
	mFullDate = [[TwitterDateTimeFormatter sharedInstance] longDateForDate:raw[@"created_at"]];
	
	NSString *fullText;
	NSDictionary *entities=nil;
	if (raw[@"retweeted_status"]) { 
		fullText = [NSString stringWithFormat:@"RT @%@ %@",raw[@"retweeted_status"][@"user"][@"screen_name"],raw[@"retweeted_status"][@"full_text"]];
		if(raw[@"retweeted_status"][@"entities"])
			mEntities = raw[@"retweeted_status"][@"entities"];
		if(raw[@"retweeted_status"][@"extended_entities"])
			mExtendedEntities = raw[@"retweeted_status"][@"extended_entities"];
		
	} else {
		fullText = raw[@"full_text"];
		if(raw[@"entities"])
			mEntities = raw[@"entities"];

		if(raw[@"extended_entities"])
			mExtendedEntities = raw[@"extended_entities"];
	}
	NSMutableString *tweet = [fullText mutableCopy];
	NSMutableString *fullTweet = [fullText mutableCopy];

	if(mEntities) {
		[mEntities enumerateKeysAndObjectsUsingBlock:^(NSString*ekey, NSArray *curEntity, BOOL *stop) {
//			NSLog(@"%@:%@",ekey,curEntity);
			[curEntity enumerateObjectsUsingBlock:^(NSDictionary *url, NSUInteger idx, BOOL *stop) {
//				NSLog(@"%u:%@",idx,url);
				if(url[@"display_url"]&&url[@"expanded_url"]){
					[tweet replaceOccurrencesOfString:url[@"url"] withString:url[@"display_url"] options:NSLiteralSearch range:NSMakeRange(0, [tweet length])];
					[fullTweet replaceOccurrencesOfString:url[@"url"] withString:url[@"expanded_url"] options:NSLiteralSearch range:NSMakeRange(0, [fullTweet length])];
				}
			}];
		}];
	}
	[tweet replaceOccurrencesOfString:@"\n" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, [tweet length])];
	mTweet = tweet;

	mFullTweet = fullTweet;
	return YES;
}

- (void)setDelegate:(id) del {
	delegate = del;
}

- (NSString*) user {
	return raw[@"user"][@"screen_name"];
}

- (NSString*) fullTweet {
	return mFullTweet;
}

- (NSAttributedString*) fullTweetAttributed {
	if(!mFullTweetAttributed) {
		NSMutableAttributedString *linkedString = [[NSMutableAttributedString alloc] initWithString:mFullTweet];
		[linkedString addAttributes:@{
					NSForegroundColorAttributeName: [NSColor controlTextColor],
					NSFontAttributeName: [NSFont fontWithName:@"Osaka-Mono" size:12.0]
				} range:NSMakeRange(0, [mFullTweet length])];
		NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
		[detector enumerateMatchesInString:mFullTweet options:0 range:NSMakeRange(0, mFullTweet.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
			if (match.URL) {
				NSDictionary *attributes = @{
					NSLinkAttributeName: match.URL,
					NSForegroundColorAttributeName: [NSColor controlTextColor],
					NSFontAttributeName: [NSFont fontWithName:@"Osaka-Mono" size:12.0]
				};
				[linkedString addAttributes:attributes range:match.range];
			}
		}];
		mFullTweetAttributed = [linkedString copy];
	}
	return mFullTweetAttributed;
}

- (NSString*) tweet {
	return mTweet;
}

- (NSString*) date {
	return mDisplayDate;
}

- (NSString*) fullDate {
	return mFullDate;
}

- (NSImage*) icon {
	if(!mUserIconTrimmed&&(!mIconLoading))
		[self loadIconAsync];
	return mUserIconTrimmed;
}

- (NSImage*) iconRaw {
	if(!mUserIcon&&(!mIconLoading))
		[self loadIconAsync];
	return mUserIcon;
}

- (NSImage*) image1 {
//	NSLog(@"image1:%@",self);
	if(!mImages[0] && mExtendedEntities[@"media"])
		[self loadImageAsync:0];
	return [mImages[0] imageToFitSize:NSMakeSize(256,256) method:MGImageResizeCrop];
}

- (NSImage*) image2 {
	if(!mImages[1] && ([mExtendedEntities[@"media"] count]>1))
		[self loadImageAsync:1];
	return [mImages[1] imageToFitSize:NSMakeSize(256,256) method:MGImageResizeCrop];
}

- (NSImage*) image3 {
	if(!mImages[2] && ([mExtendedEntities[@"media"] count]>2))
		[self loadImageAsync:2];
	return [mImages[2] imageToFitSize:NSMakeSize(256,256) method:MGImageResizeCrop];
}

- (NSImage*) image4 {
	if(!mImages[3] && ([mExtendedEntities[@"media"] count]>3))
		[self loadImageAsync:3];
	return [mImages[3] imageToFitSize:NSMakeSize(256,256) method:MGImageResizeCrop];
}

- (NSImage*) fullImage:(NSUInteger)idx {
	return mImages[idx];
}

- (NSString*) fullImageSrc:(NSUInteger)idx {
	if([mExtendedEntities[@"media"] count]>idx)
	return [NSString stringWithFormat:@"%@:orig",mExtendedEntities[@"media"][idx][@"media_url_https"]];
}

- (BOOL) hasMovie {
	return mExtendedEntities[@"media"][0][@"video_info"]!=nil;
}

- (NSDictionary*) finestMovieForMIME:(NSString*)mime {
	if(![self hasMovie])
		return nil;
	
	__block NSDictionary *candidate;
	[mExtendedEntities[@"media"][0][@"video_info"][@"variants"] enumerateObjectsUsingBlock:^(NSDictionary *media, NSUInteger idx, BOOL *stop) {
		NSLog(@"%@",media);
		if([mime isEqualToString:media[@"content_type"]]){
			if(!candidate)
				candidate = media;
			else {
				if([media[@"bitrate"] longValue]>[candidate[@"bitrate"] longValue])
					candidate = media;
			}
		}
	}];
	return candidate;
}

- (void) loadIconAsync {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		[self loadIconForURL:raw[@"user"][@"profile_image_url_https"]];
	});

}

- (void) loadIconForURL:(NSString*)url {
	mIconLoading=YES;
	NSError *error = nil;
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10]
										 returningResponse:&response
													 error:&error];

	if(error) {
		NSLog(@"%@",error);
		mIconLoading=NO;
		return;
	}
	NSImage *iconRaw = [[NSImage alloc] initWithData:data];
	dispatch_async(dispatch_get_main_queue(), ^{
		mUserIconTrimmed = [iconRaw imageToFitSize:NSMakeSize(48, 16.0) method:MGImageResizeCrop];
		mUserIcon =iconRaw;
	});
	
	if(delegate)
		[delegate performSelector:@selector(finishedLoadIconAsync)];
}

- (void) loadImageAsync:(NSUInteger)idx {
	if(mImagesLoading[idx])
		return;
	mImagesLoading[idx] = YES;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		[self loadImageForIndex:idx];
	});

}

- (void) loadImageForIndex:(NSUInteger)idx {
	NSError *error = nil;
	NSURLResponse *response = nil;
	NSString *url = [self fullImageSrc:idx];
	NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10]
										 returningResponse:&response
													 error:&error];

	if(error) {
		NSLog(@"%@",error);
		mImagesLoading[idx] = NO;
		return;
	}
	NSImage *image = [[NSImage alloc] initWithData:data];
	dispatch_async(dispatch_get_main_queue(), ^{
		mImages[idx] = image;
	});
	
	NSLog(@"loadImageForIndex:%u loaded:%@",idx,url);
	if(delegate)
		[delegate performSelector:@selector(finishedLoadImageAsync)];
}

- (void)loadMovieAsync {
	if(![self hasMovie])
		return;
		
	if(mMovie)
		if(delegate)
			[delegate performSelector:@selector(finishedLoadMovieAsync:) withObject:mMovie];
		
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		[self loadMovieForURL:[self finestMovieForMIME:@"video/mp4"][@"url"]];
	});
}

- (void) loadMovieForURL:(NSString*)url {
	NSError *error = nil;
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10]
										 returningResponse:&response
													 error:&error];

	if(error) {
		NSLog(@"%@",error);
		return;
	}
	NSLog(@"loadMovieForURL:loaded:%@",url);
	QTMovie *mov = [QTMovie movieWithData:data error:&error];

	if(error) {
		NSLog(@"%@",error);
//		[[NSWorkspace sharedWorkspace] openURLs:@[[NSURL URLWithString:url]] withAppBundleIdentifier:@"com.google.Chrome" options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifiers:nil];
		NSMutableString *urlm = [url mutableCopy];
		[urlm replaceOccurrencesOfString:@"https://" withString:@"http://" options:NSLiteralSearch range:NSMakeRange(0, [url length])];
		[[NSWorkspace sharedWorkspace] openURLs:@[[NSURL URLWithString:urlm]] withAppBundleIdentifier:@"org.videolan.vlc" options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifiers:nil];
		return;
	}

	mMovie = mov;
	
	if(delegate)
		[delegate performSelector:@selector(finishedLoadMovieAsync:) withObject:mMovie];
}


@end
