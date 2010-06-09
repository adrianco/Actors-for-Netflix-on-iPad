//
//  ActorsViewController.m
//  Actors
//
//  Created by Andrew Pouliot on 4/17/10.
//  Copyright Darknoon 2010. All rights reserved.
//

#import "ActorsViewController.h"

#import "Actor.h"
#import "ActorCell.h"
#import "MoviesViewController.h"
#import "CJSONDeserializer.h"
#import "NetflixViewController.h"
#import "NetflixShopperId.h"

@implementation ActorsViewController

@synthesize actorArray;
@synthesize gridView;
@synthesize netflixButton;
@synthesize searchButton;
@synthesize netflixShopperId;


- (void)viewWillAppear:(BOOL)animated;
{
	[super viewWillAppear:animated];
	
	[self.gridView deselectItemAtIndex: [self.gridView indexOfSelectedItem] animated: animated];
	[gridView reloadData];

}

NSInteger alphaSortPerson(id p1, id p2, void *context)
{
	// Try to sort by last name, excluding the Jr. that occurs in places
	Actor *a1 = p1;
	Actor *a2 = p2;
	NSString *n1 = [[[a1.name stringByReplacingOccurrencesOfString:@" Jr." withString:@""]
					stringByReplacingOccurrencesOfString:@" " withString:@"/"]
					lastPathComponent];
	NSString *n2 = [[[a2.name stringByReplacingOccurrencesOfString:@" Jr." withString:@""]
					stringByReplacingOccurrencesOfString:@" " withString:@"/"]
					lastPathComponent];
    return [n1 compare:n2 options:NSNumericSearch];
}

- (void)viewDidLoad;
{
	// do this once at app startup, so we are ready to hit play later
	// spawns async request so must be retained long enough to complete
	if (netflixShopperId == nil) {
		netflixShopperId = [[NetflixShopperId alloc] init];
		[netflixShopperId retain];
	}
	[netflixShopperId obtainShopperIdWithAsyncRequest];		// try to get a new one
	
	NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Actors" ofType:@"json"]];
	
	NSMutableArray *muta = [NSMutableArray array];
	
	for (NSDictionary *adict in [[[CJSONDeserializer deserializer] deserializeAsDictionary:data error:nil] objectForKey:@"People"]) {
		Actor *actor = [[Actor new] autorelease];
		actor.name = [adict valueForKeyPath:@"name"];
		actor.identifier = [adict valueForKeyPath:@"netflix_id"];
		
		[muta addObject:actor];
	}
	
	// not very elegant but it works
	NSRange sortRange;
	sortRange.location = 0;
	sortRange.length = [muta count];
	
	[muta replaceObjectsInRange:sortRange withObjectsFromArray:
	 [[muta subarrayWithRange:sortRange] sortedArrayUsingFunction:alphaSortPerson context:NULL]];
	
	self.actorArray = muta;
}


- (NSUInteger) numberOfItemsInGridView: (AQGridView *) gridView;
{
	return actorArray.count;
}

- (AQGridViewCell *) gridView: (AQGridView *)inGridView cellForItemAtIndex: (NSUInteger) index;
{
	ActorCell *cell = (ActorCell *)[inGridView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [ActorCell cell];
		cell.reuseIdentifier = @"cell";
	}
	cell.backgroundColor = [UIColor clearColor];
	cell.selectionStyle = AQGridViewCellSelectionStyleGlow;
	
	
	cell.nameLabel.text = [[actorArray objectAtIndex:index] name];
	
	return cell;
}

- (void) gridView:(AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index;
{
	MoviesViewController *vc = [[[MoviesViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	//aoteuha
	Actor *actor = [actorArray objectAtIndex:index];
	vc.actor = actor;
	vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

	[self presentModalViewController:vc animated:YES];
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) gridView;
{
	return CGSizeMake(223, 250);
}

- (IBAction)netflix
{
	NetflixViewController *web = [[NetflixViewController alloc] initWithUrlString:nil];
	web.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentModalViewController:web animated:YES];
}

- (IBAction)search
{
	UIActionSheet *actionAlert = [[UIActionSheet alloc] initWithTitle:@"Menu"
															 delegate:self
													cancelButtonTitle:nil
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Credits", @"Help Wiki at GitHub", nil];
	[actionAlert showInView:[self view]];
	[actionAlert release];
}

- (void)actionSheet:(UIActionSheet *)actionSheetView clickedButtonAtIndex:(NSInteger)alertButtonIndex {
	switch (alertButtonIndex) {
		case 0: { // Credits popup	
			UIActionSheet *actionAlert = [[UIActionSheet alloc] initWithTitle:@"Credits\n\nThanks to Netflix for the API and the Movies\nthe iPadDevCamp for Inspiration\nAndrew Pouliot for most of the code\nKirsten Jones for OData and the queries\nJim Dovey for AQGridView\nAdrian Cockcroft for product concept, debug and final production\n\n"
																	 delegate:self
															cancelButtonTitle:nil
													   destructiveButtonTitle:nil
															otherButtonTitles:nil];
			[actionAlert showInView:[self view]];
			[actionAlert release];
			break;
		}
		case 1: { // Visit the Help Wiki
			NetflixViewController *web = [[NetflixViewController alloc] initWithUrlString:@"http://wiki.github.com/adrianco/Actors-for-Netflix-on-iPad/"];
			web.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
			[self presentModalViewController:web animated:YES];
			break;
		}
		default:
			break;
	}
	return;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.gridView = nil;
}


- (void)dealloc {
	[gridView release], gridView = nil;
	[actorArray release];
	actorArray = nil;

    [super dealloc];
}

@end
