//
//  ActorCell.m
//  Actors
//
//  Created by Andrew Pouliot on 4/17/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "ActorCell.h"


@implementation ActorCell

@synthesize nameLabel;

- (void)dealloc
{
	[nameLabel release];
	nameLabel = nil;

	[super dealloc];
}

@end
