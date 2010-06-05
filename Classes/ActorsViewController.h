//
//  ActorsViewController.h
//  Actors
//
//  Created by Andrew Pouliot on 4/17/10.
//  Copyright Darknoon 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AQGridViewController.h"
#import "CellLoading.h"
#import "NetflixShopperId.h"

@interface ActorsViewController : UIViewController <AQGridViewDelegate, AQGridViewDataSource, UIActionSheetDelegate> {
	AQGridView *gridView;
	
	NSArray *actorArray;
	
	UIBarButtonItem *netflixButton;
	UIBarButtonItem *searchButton;
	
	NetflixShopperId *netflixShopperId;

}

@property (nonatomic, copy) NSArray *actorArray;
@property (retain, nonatomic) IBOutlet AQGridView *gridView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *netflixButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *searchButton;
@property (retain) NetflixShopperId *netflixShopperId;

- (IBAction)netflix;
- (IBAction)search;
@end

