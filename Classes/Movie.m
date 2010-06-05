//
//  Movie.m
//  Actors
//
//  Created by Andrew Pouliot on 4/18/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "Movie.h"


@implementation Movie

@synthesize instantAvailable;
@synthesize thumb;
@synthesize fullImage;
@synthesize netflixIdentifer;
@synthesize thumbURL;
@synthesize fullImageURL;
@synthesize directorsURL;
@synthesize castURL;
@synthesize title;
@synthesize directors;
@synthesize actors;
@synthesize synopsis;
@synthesize stars;
@synthesize seconds;
@synthesize rating;
@synthesize releaseYear;

- (id)init;
{
	self = [super init];
	if (!self) return nil;
	
	self.title = @"Movie title here!";
	self.directors = [NSArray arrayWithObjects:@"William Wyler", @"John Ford", nil];
	self.actors = [NSArray arrayWithObjects:@"Ashton Kutcher", @"Otoet Otote", @"Omoumoo On One", @"Foouo Tuoeoto", @"Foo Boao", @"Otoet Otote", @"Omoumoo On One", nil];
	self.stars = @"4.1";
	
	return self;
}

- (void)dealloc
{
	[title release];
	title = nil;
	[directors release];
	directors = nil;
	[actors release];
	actors = nil;
	[synopsis release];
	synopsis = nil;
	[stars release];
	stars = nil;
	[rating release];
	rating = nil;
	[releaseYear release];
	releaseYear = nil;

	[castURL release];
	castURL = nil;

	[directorsURL release];
	directorsURL = nil;

	[thumbURL release];
	thumbURL = nil;
	[fullImageURL release];
	fullImageURL = nil;

	[netflixIdentifer release];
	netflixIdentifer = nil;

	[fullImage release];
	fullImage = nil;

	[thumb release];
	thumb = nil;

	[super dealloc];
}

@end
