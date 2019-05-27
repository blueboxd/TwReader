//
//  TwReader_AppDelegate.m
//  TwReader
//
//  Created by bluebox on 19/05/16.
//  Copyright __MyCompanyName__ 2019 . All rights reserved.
//

#import "TwReader_AppDelegate.h"

@implementation TwReader_AppDelegate
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
		TimelineController *tc = [TimelineController initWithAuth:mAuth forURL:@"https://api.twitter.com/1.1/lists/statuses.json?slug=tl-20180817180736&owner_screen_name=b5x&count=500&include_entities=true&include_rts=true&tweet_mode=extended"];
		tc.refreshTimerInterval = 5;
		[tc start];
	}
}

-(void)openDocument:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:YES];
	[panel setCanChooseDirectories:NO];
	[panel setAllowsMultipleSelection:NO];
	
	[panel beginSheetModalForWindow:nil
				  completionHandler:^(NSInteger result) {
					  if (result == NSFileHandlingPanelOKButton) {
						  NSURL* selectedURL = [[panel URLs] objectAtIndex:0];
						  NSLog(@"selected URL: %@", [selectedURL path]);
						  TimelineController *tc = [TimelineController initForFilePath:selectedURL];
						  [tc start];
					  }
				  }];
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

@end
