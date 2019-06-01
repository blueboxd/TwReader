//
//  TimelineController.m
//  TwReader
//
//  Created by bluebox on 19/05/25.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "TimelineController.h"


@implementation TimelineController

@synthesize windowTitle;
@synthesize mAuth;
@synthesize url;
@synthesize filePath;
@synthesize tweetsArray;
@synthesize refreshTimerInterval;

+ initWithAuth:(GDataOAuthAuthentication*)auth forURL:(NSString*)url {
	TimelineController *tc = [self new];
	tc.mAuth = auth;
	tc.url = url;
	tc.windowTitle = @"Timeline";
	return tc;
}

+ initForFilePath:(NSURL*)path {
	TimelineController *tc = [self new];
	tc.filePath = [path path];
	tc.windowTitle = [path lastPathComponent];

	return tc;
}

- (id)init
{
	self = [super init];
	if (self) {
		tweetsArray = [[NSMutableArray alloc] init];
		NSNib *nib = [[NSNib alloc] initWithNibNamed:@"TimelineView" bundle:nil];
		NSArray*ar;
		if([nib instantiateNibWithOwner:self topLevelObjects:&ar]) {
			topLevelObjects = ar;
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(terminate) name:kTimeLineWindowClosed object:timelineViewController];
		}
	}
	return self;
}

- (void)start {
	if(mAuth&&url) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self initialFetch];
		});
	} else if (filePath) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self initialFetchForFile:filePath];
		});		
	}
}

- (void)terminate {
	NSLog(@"terminate:%@",self);
	if(refreshTimer)
		[refreshTimer invalidate];

//	[topLevelObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		CFRelease((__bridge CFTypeRef)obj);
//	}];

//	[tweetsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		CFRelease((__bridge CFTypeRef)obj);
//	}];
	
	[tweetsArrayController setContent:nil];
	[tweetsArray removeAllObjects];
	tweetsArrayController = nil;
	tweetsArray =nil;
	timelineViewController = nil;
}

- (void)startTimer {
	refreshTimer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(refreshTimeline) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:refreshTimer forMode:NSDefaultRunLoopMode];
}

- (void)refreshTimeline{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self doAnAuthenticatedAPIFetch];
	});
}

- (void)doAnAuthenticatedAPIFetch {
	NSString *urlStr;
	if(sinceID)
		urlStr = [NSString stringWithFormat:@"%@&since_id=%@",url,sinceID];
	else
		urlStr = url;
	
//	NSLog(@"fetch:%@",urlStr);
	NSURL *url = [NSURL URLWithString:urlStr];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[mAuth authorizeRequest:request];

	NSError *error = nil;
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request
										 returningResponse:&response
													 error:&error];
	
	if (data) {
		NSError *err;
		NSArray *tweets = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
//		NSLog(@"%u tweets",(UInt32)[tweets count]);

		[tweets enumerateObjectsUsingBlock:^(NSDictionary *tweet, NSUInteger idx, BOOL *stop) {
			if(idx==0)
				sinceID = tweet[@"id"];
				
			[tweetsArray addObject:[Tweet initWithTweetDictionary:tweet withDelegate:timelineViewController]];

			dispatch_async(dispatch_get_main_queue(), ^{
				[tweetsArrayController rearrangeObjects];
//				[timelineTableView reloadData];
			});
		}];

	} else {
		// fetch failed
		NSLog(@"API fetch error: %@", error);
	}
}

- (void)initialFetch {
	NSString *urlStr;
	__block NSString *maxID;
	for(int i=0;i<5;i++) {
		if(maxID)
			urlStr = [NSString stringWithFormat:@"%@&max_id=%@",url,maxID];
		else
			urlStr = url;

//		NSLog(@"fetch:%@",urlStr);
		NSURL *url = [NSURL URLWithString:urlStr];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		[mAuth authorizeRequest:request];

		NSError *error = nil;
		NSURLResponse *response = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:request
											 returningResponse:&response
														 error:&error];
		
		if (data) {
			dispatch_queue_t arrayQ = dispatch_queue_create([urlStr cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
			NSError *err;
			NSArray *tweets = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
//			NSLog(@"%u tweets",(UInt32)[tweets count]);

//			[tweets enumerateObjectsUsingBlock:^(NSDictionary *tweet, NSUInteger idx, BOOL *stop) {
			[tweets enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSDictionary *tweet, NSUInteger idx, BOOL *stop) {
				if(i==0&&idx==0)
					sinceID = tweet[@"id"];
				
				Tweet*tw = [Tweet initWithTweetDictionary:tweet withDelegate:timelineViewController];
				if(tw) {
					dispatch_async(arrayQ, ^{
						[tweetsArray addObject:tw];
					});
				}
				if(!(idx%100))
				dispatch_async(dispatch_get_main_queue(), ^{
					[tweetsArrayController rearrangeObjects];
				});
				
				if ((idx+1)==[tweets count]) {
					maxID = tweet[@"id"];
				}
			}];
			dispatch_async(dispatch_get_main_queue(), ^{
				[tweetsArrayController rearrangeObjects];
			});
		} else {
			// fetch failed
			NSLog(@"API fetch error: %@", error);
		}
	}
	if(refreshTimerInterval)
		[self startTimer];
}

- (void)initialFetchForFile:(NSString*)path {
	NSError *err;
	NSMutableString *st=[NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
	[st replaceOccurrencesOfString:@"\n" withString:@"," options:NSLiteralSearch range:NSMakeRange(0, [st length])];
	NSData *data = [[NSString stringWithFormat:@"[%@]",st] dataUsingEncoding:NSUTF8StringEncoding];
	
	if (data) {
		dispatch_queue_t arrayQ = dispatch_queue_create([path cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);	
		NSArray *tweets = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
		NSLog(@"%u tweets",(UInt32)[tweets count]);

		[tweets enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSDictionary *tweet, NSUInteger idx, BOOL *stop) {
//		[tweets enumerateObjectsUsingBlock:^(NSDictionary *tweet, NSUInteger idx, BOOL *stop) {
			Tweet*tw = [Tweet initWithTweetDictionary:tweet withDelegate:timelineViewController];
			if(tw) {
				dispatch_async(arrayQ, ^{
				[tweetsArray addObject:tw];
				});
			}
			if(!(idx%500))
			dispatch_async(dispatch_get_main_queue(), ^{
				[tweetsArrayController rearrangeObjects];
//					[timelineTableView reloadData];
			});
		}];
		dispatch_async(dispatch_get_main_queue(), ^{
			[tweetsArrayController rearrangeObjects];
		});
	} else {
		// fetch failed
		NSLog(@"API fetch error: %@", err);
	}
}



@end
