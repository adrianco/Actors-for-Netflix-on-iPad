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
#define NETFLIXKEY @"NFLX_NETFLIXID"

@implementation NetflixShopperId

@synthesize networkQueue;


// shopperId is an authentication token found in the Netflix website cookie.
// if a user logs out and back in, their shopperId will change, so check it each time
// NetflixId is a more recent authentication cookie
- (void) obtainShopperIdWithAsyncRequest {
	//NSLog(@"Loading netflixid and shopperid from https://www.netflix.com/YourAccount");
	NSURL *webUrl = [NSURL URLWithString:@"https://www.netflix.com/YourAccount"];
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
		NSLog(@"Cookie %@ = %@", [oneCookie name], [oneCookie value]);
		if ([@"NetflixShopperId" isEqualToString:[oneCookie name]]) {
			[self setShopperId:[oneCookie value]];
		} else if ([@"NetflixId" isEqualToString:[oneCookie name]]) {
			[self setNetflixId:[oneCookie value]];
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

- (NSString *)getNetflixId
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:NETFLIXKEY];
}

- (void)setNetflixId:(NSString *)nid
{
	[[NSUserDefaults standardUserDefaults] setObject:nid forKey:NETFLIXKEY];
}

- (void)dealloc {
	[networkQueue cancelAllOperations];
	[networkQueue release];
	networkQueue = nil;
	[super dealloc];
}

@end
