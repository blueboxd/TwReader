//
//  CachedAsyncURLConnection.m
//  TwReader
//
//  Created by bluebox on 19/05/28.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "CachedAsyncURLConnection.h"


@implementation CachedAsyncURLConnection
#if 0
@interface ViewController () {
  NSMutableData *receivedData_;
}
@end

...

- (IBAction)asyncButtonPushed:(id)sender {
  NSURL *url = [NSURL URLWithString:@"http://localhost/"];
  NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"user", @"username", 
                            @"password", @"password", nil];
  NSData *postData = [self encodeDictionary:postDict];

  // Create the request
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"POST"];
  [request setValue:[NSString stringWithFormat:@"%d", postData.length] forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
  [request setHTTPBody:postData];

  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request 
                                                                delegate:self];

  [connection start];  
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  [receivedData_ setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data { 
  [receivedData_ appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSLog(@"Succeeded! Received %d bytes of data", [receivedData_ length]);
  NSString *responeString = [[NSString alloc] initWithData:receivedData_
                                                  encoding:NSUTF8StringEncoding];
  // Assume lowercase 
  if ([responeString isEqualToString:@"true"]) {
    // Deal with true
    return;
  }    
  // Deal with an error
}
#endif
@end
