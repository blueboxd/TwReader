//
//  TwReader_AppDelegate.h
//  TwReader
//
//  Created by bluebox on 19/05/16.
//  Copyright __MyCompanyName__ 2019 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "GDataOAuthWindowController.h"

#import "TimelineController.h"

@interface TwReader_AppDelegate : NSObject
{
 	GDataOAuthAuthentication *mAuth;
}

@end

