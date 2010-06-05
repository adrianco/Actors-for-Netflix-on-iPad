//
//  Movie.h
//  Actors
//
//  Created by Andrew Pouliot on 4/18/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Movie : NSObject {
	NSURL *directorsURL;
	NSURL *castURL;
	
	NSURL *thumbURL;
	NSURL *fullImageURL;
	UIImage *thumb;
	UIImage *fullImage;
	
	NSString *title;
	NSArray *directors;
	NSArray *actors;
	NSString *synopsis;
	NSString *stars;
	NSString *releaseYear;
	NSString *rating;
	NSString *netflixIdentifer;
	
	NSInteger seconds;
	BOOL instantAvailable;
}

@property (nonatomic, assign) BOOL instantAvailable;
@property (nonatomic, assign) NSInteger seconds;

@property (nonatomic, retain) UIImage *thumb;
@property (nonatomic, retain) UIImage *fullImage;
@property (nonatomic, copy) NSString *netflixIdentifer;
@property (nonatomic, retain) NSURL *thumbURL;
@property (nonatomic, retain) NSURL *fullImageURL;
@property (nonatomic, retain) NSURL *directorsURL;
@property (nonatomic, retain) NSURL *castURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray *directors;
@property (nonatomic, copy) NSArray *actors;
@property (nonatomic, copy) NSString *synopsis;
@property (nonatomic, copy) NSString *stars;
@property (nonatomic, copy) NSString *releaseYear;
@property (nonatomic, copy) NSString *rating;

@end
