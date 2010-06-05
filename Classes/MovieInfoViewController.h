//
//  MovieInfoViewController.h
//  Actors
//
//  Created by Andrew Pouliot on 4/17/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequestDelegate.h"

@class ButtonGroup;

@class Movie;

@interface MovieInfoViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate, ASIHTTPRequestDelegate> {
	ButtonGroup *directorsButtonGroup;
	ButtonGroup *actorsButtonGroup;
	
	UILabel *helpfulLabel;
	UILabel *releaseLabel;
	UILabel *starsLabel;
	UITextView *synopsisView;
	
	UIImageView *largeImageView;

	UINavigationBar *navBar;
	UIBarButtonItem *instantWatchButton;
	
	UIButton *netflixButton;
	UIButton *favoriteButton;
	
	Movie *movie;
	
	ASINetworkQueue *networkQueue;
}

@property (retain) ASINetworkQueue *networkQueue;
@property (nonatomic, retain) Movie *movie;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *instantWatchButton;
@property (nonatomic, retain) IBOutlet UIButton *netflixButton;
@property (nonatomic, retain) IBOutlet UIButton *favoriteButton;
@property (nonatomic, retain) IBOutlet UIImageView *largeImageView;
@property (nonatomic, retain) IBOutlet UITextView *synopsisView;
@property (nonatomic, retain) IBOutlet UILabel *helpfulLabel;
@property (nonatomic, retain) IBOutlet UILabel *releaseLabel;
@property (nonatomic, retain) IBOutlet UILabel *starsLabel;
@property (nonatomic, retain) IBOutlet ButtonGroup *actorsButtonGroup;
@property (nonatomic, retain) IBOutlet ButtonGroup *directorsButtonGroup;

- (IBAction)back;
- (IBAction)play;
- (IBAction)netflix;
- (IBAction)favorite;

- (void)actorsDidLoad:(ASIHTTPRequest *)inRequest;
- (void)directorsDidLoad:(ASIHTTPRequest *)inRequest;
- (void)loadedImage:(ASIHTTPRequest *)inRequest;

@end
