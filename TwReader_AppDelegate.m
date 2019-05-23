//
//  TwReader_AppDelegate.m
//  TwReader
//
//  Created by bluebox on 19/05/16.
//  Copyright __MyCompanyName__ 2019 . All rights reserved.
//

#import "TwReader_AppDelegate.h"
#import "NSImage+MGCropExtensions.h"

@implementation TwReader_AppDelegate

@synthesize window;
@synthesize tweetsArrayController;
@synthesize tweetsArray;
@synthesize timelineTableView;
@synthesize tweetDetailTweetTextVIew;

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
		[self refreshTimeline];
		NSTimer *timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(refreshTimeline) userInfo:nil repeats:YES];
		[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
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
	[windowController signInSheetModalForWindow:window
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
	
	NSLog(urlStr);
	NSURL *url = [NSURL URLWithString:urlStr];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[mAuth authorizeRequest:request];
	
	// Synchronous fetches like this are a really bad idea in Cocoa applications
	//
	// For a very easy async alternative, we could use GDataHTTPFetcher
	NSError *error = nil;
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request
										 returningResponse:&response
													 error:&error];
	
	if (data) {
		NSError *err;
		NSArray *tweets = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
		dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
		dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
		NSDateFormatter *dateFormatterParsed = [[NSDateFormatter alloc] init];
		dateFormatterParsed.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
		dateFormatterParsed.dateFormat = @"HH:mm:ss";

		[tweets enumerateObjectsUsingBlock:^(NSDictionary *tweet, NSUInteger idx, BOOL *stop) {
			if(idx==0)
				sinceID = tweet[@"id"];
				
			NSString *tweetText, *userText;
			if (tweet[@"retweeted_status"]) { 
				tweetText = tweet[@"retweeted_status"][@"full_text"];
				userText = tweet[@"retweeted_status"][@"user"][@"screen_name"];
			} else {
				tweetText = tweet[@"full_text"];
				userText = tweet[@"user"][@"screen_name"];
			}
			
			NSMutableDictionary *curTweet= [@{
				@"user":userText,
				@"date":[dateFormatterParsed stringFromDate:[dateFormatter dateFromString:tweet[@"created_at"]]],
				@"tweet":tweetText,
				@"raw":tweet
			} mutableCopy];

			[tweetsArray addObject:curTweet];

			dispatch_async(dispatch_get_main_queue(), ^{
				[tweetsArrayController rearrangeObjects];
				[timelineTableView reloadData];
			});

			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
				[self loadIconForTweet:curTweet withURL:tweet[@"user"][@"profile_image_url_https"]];
			});

		}];

	} else {
		// fetch failed
		NSLog(@"API fetch error: %@", error);
	}
}

- (void) loadIconForTweet:(NSMutableDictionary*)tweet withURL:(NSString*)url {
	NSError *error = nil;
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10]
										 returningResponse:&response
													 error:&error];

	NSImage *iconRaw = [[NSImage alloc] initWithData:data];
	dispatch_async(dispatch_get_main_queue(), ^{
		tweet[@"icon"] = [iconRaw imageToFitSize:NSMakeSize(48, 16.0) method:MGImageResizeCrop],
		tweet[@"iconRaw"] =iconRaw,
		[timelineTableView reloadData];
	});
}

- (NSAttributedString *)autoLinkURLs:(NSString *)string {
    NSMutableAttributedString *linkedString = [[NSMutableAttributedString alloc] initWithString:string];
	
	[linkedString addAttributes:@{
				NSForegroundColorAttributeName: [NSColor controlTextColor],
				NSFontAttributeName: [NSFont fontWithName:@"Osaka-Mono" size:12.0]
			} range:NSMakeRange(0, [string length])];
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    [detector enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        if (match.URL) {
            NSDictionary *attributes = @{
				NSLinkAttributeName: match.URL,
				NSForegroundColorAttributeName: [NSColor controlTextColor],
				NSFontAttributeName: [NSFont fontWithName:@"Osaka-Mono" size:12.0]
			};
            [linkedString addAttributes:attributes range:match.range];
        }
    }];

    return [linkedString copy];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
	NSDictionary *selection = [[tweetsArrayController arrangedObjects] objectAtIndex:row];
	if(selection)
		[tweetDetailTweetTextVIew.textStorage setAttributedString:[self autoLinkURLs:selection[@"tweet"]]];

	return YES;
}

@end
