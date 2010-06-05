//
//  MovieCell.m
//  Actors
//
//  Created by Andrew Pouliot on 4/17/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "MovieCell.h"


@implementation MovieCell

@synthesize instantAvailableView;
@synthesize imageView;

- (void)dealloc
{
	[imageView release];
	imageView = nil;
	
	[instantAvailableView release];
	instantAvailableView = nil;

	[super dealloc];
}


@end
