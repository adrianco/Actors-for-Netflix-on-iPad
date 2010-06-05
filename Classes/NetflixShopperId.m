//
//  Defaults.m
//  Actors
//
//  Created by Adrian Cockcroft on 4/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NetflixShopperId.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

#define SHOPKEY @"NFLX_SHOPPERID"

@implementation NetflixShopperId

@synthesize networkQueue;


// shopperId is an authentication token found in the Netflix website cookie.
// if a user logs out and back in, their shopperId will change, so check it each time
- (void) obtainShopperIdWithAsyncRequest {
	//NSLog(@"Loading shopperid from http://www.netflix.com/WiHome");
	NSURL *webUrl = [NSURL URLWithString:@"http://www.netflix.com/WiHome"];
	[networkQueue cancelAllOperations];
	networkQueue = [ASINetworkQueue queue];
	[networkQueue retain];
	networkQueue.delegate = self;
	networkQueue.requestDidFinishSelector = @selector(idDidLoad:);
	networkQueue.requestDidFailSelector = @selector(requestFailed:);
	networkQueue.queueDidFinishSelector = @selector(queueFinished:);
	[networkQueue addOperation:[ASIHTTPRequest requestWithURL:webUrl]];
	//NSLog(@"NetflixShopperId async request started");
	[networkQueue go];
}

- (void)idDidLoad:(ASIHTTPRequest *)request {
	//NSLog(@"NetflixShopperId async request succeeded");
	NSArray *cookies = [request responseCookies];
	for(NSHTTPCookie *oneCookie in cookies) {
		if ([@"NetflixShopperId" isEqualToString:[oneCookie name]]) {
			[self setShopperId:[oneCookie value]];
			//NSLog(@"NetflixShopperId from cookie = %@", [oneCookie value]);
			break;
		}
	}
}

- (void)requestFailed:(ASIHTTPRequest *)inRequest;
{
	NSLog(@"NetflixShopperId async request failed for: %@", [[inRequest url] absoluteURL]);
}

- (void)queueFinished:(ASIHTTPRequest *)inRequest;
{
	//NSLog(@"MovieInfoView async request queue finished");
}

- (NSString *)getShopperId
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:SHOPKEY];
}

- (void)setShopperId:(NSString *)sid
{
	[[NSUserDefaults standardUserDefaults] setObject:sid forKey:SHOPKEY];
}

- (void)dealloc {
	[networkQueue cancelAllOperations];
	[networkQueue release];
	networkQueue = nil;
	[super dealloc];
}

@end
