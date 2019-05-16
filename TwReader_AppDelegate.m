//
//  TwReader_AppDelegate.m
//  TwReader
//
//  Created by bluebox on 19/05/16.
//  Copyright __MyCompanyName__ 2019 . All rights reserved.
//

#import "TwReader_AppDelegate.h"

@implementation TwReader_AppDelegate

@synthesize window;


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
	[self doAnAuthenticatedAPIFetch];
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

- (void)doAnAuthenticatedAPIFetch {
	NSString *urlStr;
	urlStr = @"https://api.twitter.com/1.1/statuses/home_timeline.json?count=10&exclude_replies=false&include_entities=true&tweet_mode=extended";
	
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
		// API fetch succeeded
//		NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		//NSLog(@"API response: %@", str);
		NSError *err;
		NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
		NSLog(@"%@",dict);
	} else {
		// fetch failed
		NSLog(@"API fetch error: %@", error);
	}
}

@end
