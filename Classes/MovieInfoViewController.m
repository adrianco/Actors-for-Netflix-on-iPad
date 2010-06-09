    //
//  MovieInfoViewController.m
//  Actors
//
//  Created by Andrew Pouliot on 4/17/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "MovieInfoViewController.h"

#import "ButtonGroup.h"
#import "ButtonGroupButton.h"
#import "Movie.h"
#import "MoviesViewController.h"
#import "CJSONDeserializer.h"
#import "ASIHTTPRequest.h"
#import "NetflixViewController.h"
#import "NetflixShopperId.h"

@implementation MovieInfoViewController

@synthesize instantWatchButton;
@synthesize	navBar;
@synthesize netflixButton;
@synthesize favoriteButton;
@synthesize synopsisView;
@synthesize helpfulLabel;
@synthesize releaseLabel;
@synthesize starsLabel;
@synthesize movie;
@synthesize actorsButtonGroup;
@synthesize directorsButtonGroup;
@synthesize largeImageView;
@synthesize networkQueue;

- (IBAction)back;
{
	[self dismissModalViewControllerAnimated:YES];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void) playFromBoxShotString:(NSString *)boxshot {
	NSString *mvstrng = [[boxshot lastPathComponent] stringByDeletingPathExtension];
	//NSLog(@"play: %@", mvstrng);
	if (mvstrng == nil) return;

	NetflixShopperId *nf = [[NetflixShopperId alloc] init];
	NSString *sid = [nf getShopperId];
	
	if (sid != nil) { 
		NSString *wiPlayer = [[NSString alloc] initWithFormat:@"nflx://www.netflix.com/WiPlayer?shopperId=%@&movieid=%@&returnUrl=nact:", sid, mvstrng];
		NSURL *url = [NSURL URLWithString:wiPlayer];
		[wiPlayer release];
		// On device we open the nflx url
		[[UIApplication sharedApplication] openURL:url];
		// if it works, this app stops running at this point, so fall through here if fails
	} 
	[self netflix];	// open the page for that movie
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if ([[request.URL absoluteString] hasPrefix:@"http://www.netflix.com/WiPlayer?shopperId"]) {
		NSLog(@"Request to rewrite %@", [request.URL absoluteString]);
		// http://www.netflix.com/WiPlayer?shopperId=GA-...&movieid=464403&trkid=496800&returnUrl=http%3A%2F%2Fwww.netflix.com%2FWiHome
		// reconstruct it with nflx: and nact: as the return
		// save it in defaults
	} 
	if ([[request.URL absoluteString] hasPrefix:@"nflx:"]) {
		NSMutableString *murls = [NSMutableString stringWithString:[request.URL absoluteString]];
		[murls replaceOccurrencesOfString:@"returnUrl=http" withString:@"returnUrl=nact" options:NSLiteralSearch range:NSMakeRange(0, [murls length])];
		NSLog(@"Request sent to netflix %@", murls);
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:murls]];
		return NO;
	}

	return YES;
}

- (IBAction)play;
{
	[self playFromBoxShotString:[movie.thumbURL absoluteString]];
}

- (IBAction)netflix
{
	NSString *mvstrng = [[[movie.thumbURL absoluteString] lastPathComponent] stringByDeletingPathExtension];
	NetflixViewController *web = [[NetflixViewController alloc]
								  initWithUrlString:[NSString stringWithFormat:@"http://www.netflix.com/Movie/%@", mvstrng]];
	web.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentModalViewController:web animated:YES];
}

- (IBAction)favorite
{
	if (favoriteButton.selected == NO) {
		[favoriteButton setSelected:YES];
	} else {
		[favoriteButton setSelected:NO];
	}
}

- (NSString *)flattenHTML:(NSString *)html
{
	NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:html];
    while ([theScanner isAtEnd] == NO) {		
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
				[ NSString stringWithFormat:@"%@>", text]
										withString:@" "];
    } // while //
    return html;
}

- (NSString *)stars:(NSString *)rating {
	// convert 3.4 to ★★★☆☆ or ✭✭✭✩✩
	int i = round([rating floatValue]);
	//NSLog(@"rating: %@ %d\n", rating, i);
	switch(i) {
		case 1: return [NSString stringWithFormat:@"%@ ✭✩✩✩✩", rating];
		case 2: return [NSString stringWithFormat:@"%@ ✭✭✩✩✩", rating];
		case 3: return [NSString stringWithFormat:@"%@ ✭✭✭✩✩", rating];
		case 4: return [NSString stringWithFormat:@"%@ ✭✭✭✭✩", rating];
		case 5: return [NSString stringWithFormat:@"%@ ✭✭✭✭✭", rating];
		default: return [NSString stringWithFormat:@"%@", rating];
	}
}

- (void)setMovie:(Movie *)value {
	if (movie == value) return;
	[movie release];
	movie = [value retain];
	
	[self view];
	
	navBar.topItem.title = movie.title;
	
	if (movie.instantAvailable) {
		navBar.topItem.rightBarButtonItem = instantWatchButton;
		helpfulLabel.text = @"Play this movie instantly or visit it's Netflix web site page for more options";
	} else {
		navBar.topItem.rightBarButtonItem = nil;
		helpfulLabel.text = @"Visit this movie's Netflix web site page for more options";
	}
	
	// setup a fresh queue
	[networkQueue cancelAllOperations];
	networkQueue = [ASINetworkQueue queue];
	[networkQueue retain];
	networkQueue.delegate = self;
	networkQueue.requestDidFinishSelector = nil;
	networkQueue.requestDidFailSelector = @selector(requestFailed:);
	networkQueue.queueDidFinishSelector = nil;
	
	if (movie.castURL) {
		//NSLog(@"Loading cast from : %@", movie.castURL);
		ASIHTTPRequest *actorsRequest = [ASIHTTPRequest requestWithURL:movie.castURL];
		actorsRequest.didFinishSelector = @selector(actorsDidLoad:);
		actorsRequest.delegate = self;
		[networkQueue addOperation:actorsRequest];
	}
	if (movie.directorsURL) {
		//NSLog(@"Loading directors from : %@", movie.directorsURL);
		ASIHTTPRequest *directorsRequest = [ASIHTTPRequest requestWithURL:movie.directorsURL];
		directorsRequest.didFinishSelector = @selector(directorsDidLoad:);
		directorsRequest.delegate = self;
		[networkQueue addOperation:directorsRequest];
	}
	
	ASIHTTPRequest *imgreq = [ASIHTTPRequest requestWithURL:movie.fullImageURL];
	imgreq.delegate = self;
	imgreq.didFinishSelector = @selector(loadedImage:);
	[networkQueue addOperation:imgreq];
	
	[networkQueue go];
	
	synopsisView.text = [self flattenHTML:movie.synopsis];
	starsLabel.text = [self stars:movie.stars];
	if (movie.seconds > 0)
		releaseLabel.text = [NSString stringWithFormat:@"Released %@, %@, %d minutes", movie.releaseYear, movie.rating, movie.seconds/60];
	else
		releaseLabel.text = [NSString stringWithFormat:@"Released %@, %@", movie.releaseYear, movie.rating];
}

- (void)requestFailed:(ASIHTTPRequest *)inRequest;
{
	NSLog(@"MovieInfoView async request failed for: %@", [[inRequest url] absoluteURL]);
}

- (void)loadedImage:(ASIHTTPRequest *)inRequest;
{
	largeImageView.image = [UIImage imageWithData:[inRequest responseData]];
}

- (void)buttonTapped:(ButtonGroupButton *)inButton;
{
	MoviesViewController *movs = (MoviesViewController *)self.parentViewController;
	movs.actor = inButton.actor;
	[self dismissModalViewControllerAnimated:YES];
}

- (void)directorsDidLoad:(ASIHTTPRequest *)inRequest;
{
	
	NSMutableArray *movDirs = [NSMutableArray array];
	NSDictionary *data = [[CJSONDeserializer deserializer] deserializeAsDictionary:[inRequest responseData] error:nil];
	NSArray *arr = [data valueForKeyPath:@"d.results"];
	
	[directorsButtonGroup removeAllSubviews];
	for (NSDictionary *dird in arr) {
		Actor *actor = [[[Actor alloc] init] autorelease];
		actor.name = [dird objectForKey:@"Name"];
		actor.identifier = [dird objectForKey:@"Id"];

		ButtonGroupButton *button = [ButtonGroupButton buttonWithType:UIButtonTypeCustom];
		[button setTitle:actor.name forState:UIControlStateNormal];
		[directorsButtonGroup addSubview:button];
		
		[button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		button.actor = actor;
		
		[movDirs addObject:actor];
	}
	movie.directors = movDirs;
	
}

- (void)actorsDidLoad:(ASIHTTPRequest *)inRequest;
{
	NSMutableArray *movDirs = [NSMutableArray array];
	NSDictionary *data = [[CJSONDeserializer deserializer] deserializeAsDictionary:[inRequest responseData] error:nil];
	NSArray *arr = [data valueForKeyPath:@"d.results"];
	
	[actorsButtonGroup removeAllSubviews];
	for (NSDictionary *dird in arr) {
		Actor *actor = [[[Actor alloc] init] autorelease];
		actor.name = [dird objectForKey:@"Name"];
		actor.identifier = [dird objectForKey:@"Id"];
		
		ButtonGroupButton *button = [ButtonGroupButton buttonWithType:UIButtonTypeCustom];
		[button setTitle:actor.name forState:UIControlStateNormal];
		[actorsButtonGroup addSubview:button];
		
		[button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];

		button.actor = actor;
		
		[movDirs addObject:actor];
	}
	movie.actors = movDirs;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow any orientation.
    // return YES;
	// this view needs fixing for portrait, but movies play better landscape as well
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
			interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[networkQueue cancelAllOperations];
	[networkQueue release];
	networkQueue = nil;
	
	[directorsButtonGroup release];
	directorsButtonGroup = nil;

	[actorsButtonGroup release];
	actorsButtonGroup = nil;

	[movie release];
	movie = nil;

	[helpfulLabel release];
	helpfulLabel = nil;
	
	[releaseLabel release];
	releaseLabel = nil;

	[synopsisView release];
	synopsisView = nil;

	[instantWatchButton release];
	instantWatchButton = nil;

	[navBar release];
	navBar = nil;
	
    [super dealloc];
}


@end
