//
//  MoviesViewController.h
//  Actors
//
//  Created by Andrew Pouliot on 4/17/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AQGridView.h"
#import "CellLoading.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequestDelegate.h"

@class Actor;

@interface MoviesViewController : UIViewController <AQGridViewDelegate, AQGridViewDataSource, ASIHTTPRequestDelegate> {
	IBOutlet AQGridView *gridView;
	
	ASIHTTPRequest *getActorMoviesRequest;
	ASINetworkQueue *networkQueue;
	
	Actor *actor;
	
	UINavigationBar *navBar;
	
	NSArray *movies;
	
	NSInteger page;
}

@property (retain) IBOutlet UINavigationBar *navBar;
@property (retain) Actor *actor;
@property (copy) NSArray *movies;
@property (retain) AQGridView *gridView;
@property (retain) ASINetworkQueue *networkQueue;

- (IBAction)back;

// forward definitions to make code more readable
- (void)requestActorPage;
- (void)requestBoxshotsForPage;


@end
