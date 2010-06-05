//
//  NetflixShopperId.h
//  Actors
//
//  Created by Adrian Cockcroft on 4/26/10.
//  Copyright 2010 millicomputer.com . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequestDelegate.h"


@interface NetflixShopperId : NSObject <ASIHTTPRequestDelegate> {
	ASINetworkQueue *networkQueue;
}

@property (retain) ASINetworkQueue *networkQueue;

// ping the website and pickup the cookie, persist it
// this object must be retained for a few seconds by the calling class so
// the request can notify asynchronously without being cancelled
- (void)obtainShopperIdWithAsyncRequest;
- (void)idDidLoad:(ASIHTTPRequest *)request;

// these functions can be accessed by an ephemeral instance
- (NSString *)getShopperId;	// return the id if we have one persisted
- (void)setShopperId:(NSString *)sid; // change the persisted id

@end
