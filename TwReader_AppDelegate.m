//
//  TwReader_AppDelegate.m
//  TwReader
//
//  Created by bluebox on 19/05/16.
//  Copyright __MyCompanyName__ 2019 . All rights reserved.
//

#import "TwReader_AppDelegate.h"
#import "NSImage+MGCropExtensions.h"
#import "Tweet.h"


@implementation TwReader_AppDelegate


@synthesize tweetsArrayController;
@synthesize tweetsArray;
@synthesize tvc;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
    // there is no saved Google authentication
    //
    // perhaps we have a saved authorization for Twitter instead; try getting
    // that from the keychain
	GDataOAuthAuthentication *auth;
    auth = [self authForTwitter];
    if (auth) {
		BOOL didAuth = [GDataOAuthWindowController authorizeFromKeychainForName:kTwitterAppServiceName
																 authentication:auth];
		if (!didAuth) {
			[self signInToTwitter];
		} else {
			mAuth = auth;
		}
    }
	
	if(mAuth) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self initialFetch];
		});
	}
}

static NSString *const kTwitterServiceName = @"Twitter";
static NSString *const kTwitterAppServiceName = @"TwReader OAuth";
- (GDataOAuthAuthentication *)authForTwitter {
	// Note: to use this sample, you need to fill in a valid consumer key and
	// consumer secret provided by Twitter for their API
	//
	// http://twitter.com/apps/
	NSString *myConsumerKey = @"kMbfUY1Iq4B3WWbhultnwlIRm";
	NSString *myConsumerSecret = @"MMexsDn7HANzRq7WYhmzklYWZlUOg86WnTtgjKiVA9HpSM0g3c";
	
	if ([myConsumerKey length] == 0 || [myConsumerSecret length] == 0) {
		return nil;
	}
	
	GDataOAuthAuthentication *auth;
	auth = [[GDataOAuthAuthentication alloc] initWithSignatureMethod:kGDataOAuthSignatureMethodHMAC_SHA1
														 consumerKey:myConsumerKey
														  privateKey:myConsumerSecret];
	
	// setting the service name lets us inspect the auth object later to know
	// what service it is for
	[auth setServiceProvider:kTwitterAppServiceName];
	return auth;
}

- (void)signInToTwitter {
	
	NSURL *requestURL = [NSURL URLWithString:@"https://twitter.com/oauth/request_token"];
	NSURL *accessURL = [NSURL URLWithString:@"https://twitter.com/oauth/access_token"];
	NSURL *authorizeURL = [NSURL URLWithString:@"https://twitter.com/oauth/authorize"];
	NSString *scope = @"https://api.twitter.com/";
	
	GDataOAuthAuthentication *auth = [self authForTwitter];
	[auth setCallback:@"oob"];
	
	GDataOAuthWindowController *windowController;
	windowController = [[GDataOAuthWindowController alloc] initWithScope:scope
																language:nil
														 requestTokenURL:requestURL
													   authorizeTokenURL:authorizeURL
														  accessTokenURL:accessURL
														  authentication:auth
														  appServiceName:kTwitterAppServiceName
														  resourceBundle:nil];
	[windowController signInSheetModalForWindow:nil
									   delegate:self
							   finishedSelector:@selector(windowController:finishedWithAuth:error:)];
}




- (void)windowController:(GDataOAuthWindowController *)windowController
        finishedWithAuth:(GDataOAuthAuthentication *)auth
                   error:(NSError *)error {
	if (error != nil) {
		// Authentication failed (perhaps the user denied access, or closed the
		// window before granting access)
		NSLog(@"Authentication error: %@", error);
		NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGDataHTTPFetcherStatusDataKey
		if ([responseData length] > 0) {
			// show the body of the server's authentication failure response
			NSString *str = [[NSString alloc] initWithData:responseData
												  encoding:NSUTF8StringEncoding];
			NSLog(@"%@", str);
		}
		
		mAuth = nil;
	} else {
		// save the authentication object
		mAuth = auth;
	}
}

#pragma mark -

- (void)refreshTimeline{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self doAnAuthenticatedAPIFetch];
	});
}

- (void)doAnAuthenticatedAPIFetch {
	NSString *urlStr;
	if(sinceID)
		urlStr = [NSString stringWithFormat:@"https://api.twitter.com/1.1/lists/statuses.json?slug=tl-20180817180736&owner_screen_name=b5x&count=500&include_entities=true&include_rts=true&tweet_mode=extended&since_id=%@",sinceID];//@"https://api.twitter.com/1.1/statuses/home_timeline.json?count=100&exclude_replies=false&include_entities=true&tweet_mode=extended";
	else
		urlStr = @"https://api.twitter.com/1.1/lists/statuses.json?slug=tl-20180817180736&owner_screen_name=b5x&count=500&include_entities=true&include_rts=true&tweet_mode=extended";
	
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
				
			[tweetsArray addObject:[Tweet initWithTweetDictionary:tweet withDelegate:tvc]];
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
			urlStr = [NSString stringWithFormat:@"https://api.twitter.com/1.1/lists/statuses.json?slug=tl-20180817180736&owner_screen_name=b5x&count=500&include_entities=true&include_rts=true&tweet_mode=extended&max_id=%@",maxID];
		else
			urlStr = @"https://api.twitter.com/1.1/lists/statuses.json?slug=tl-20180817180736&owner_screen_name=b5x&count=500&include_entities=true&include_rts=true&tweet_mode=extended";

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
			NSError *err;
			NSArray *tweets = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
//			NSLog(@"%u tweets",(UInt32)[tweets count]);

			[tweets enumerateObjectsUsingBlock:^(NSDictionary *tweet, NSUInteger idx, BOOL *stop) {
				if(i==0&&idx==0)
					sinceID = tweet[@"id"];

				maxID = tweet[@"id"];
				Tweet*tw = [Tweet initWithTweetDictionary:tweet withDelegate:tvc];
//				if([tw hasMovie])
					[tweetsArray addObject:tw];
				dispatch_async(dispatch_get_main_queue(), ^{
					[tweetsArrayController rearrangeObjects];
//					[timelineTableView reloadData];
				});
			}];

		} else {
			// fetch failed
			NSLog(@"API fetch error: %@", error);
		}
	}
	
	NSTimer *timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(refreshTimeline) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}



@end
