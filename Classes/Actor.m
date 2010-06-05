//
//  Actor.m
//  Actors
//
//  Created by Andrew Pouliot on 4/18/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "Actor.h"


@implementation Actor

@synthesize name;
@synthesize identifier;

- (void)dealloc
{
	[name release];
	name = nil;
	[identifier release];
	identifier = nil;

	[super dealloc];
}

@end
