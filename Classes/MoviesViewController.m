    //
//  MoviesViewController.m
//  Actors
//
//  Created by Andrew Pouliot on 4/17/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "MoviesViewController.h"

#import "AQGridView.h"
#import "Movie.h"
#import "MovieCell.h"
#import "MovieInfoViewController.h"
#import "NetflixViewController.h"
#import "CJSONDeserializer.h"
#import "Actor.h"

@implementation MoviesViewController

@synthesize navBar;
@synthesize actor;
@synthesize movies;
@synthesize gridView;
@synthesize networkQueue;
@synthesize netflixButton;


- (void)viewDidLoad;
{
	[super viewDidLoad];
	
	gridView.leftContentInset = 60.f;
	gridView.rightContentInset = 60.f;
	
	navBar.topItem.title = self.title;
	navBar.topItem.rightBarButtonItem.title = [NSString stringWithFormat:@"%@ - Delivered by Netflix", actor.name];
}

- (void)setActor:(Actor *)value
{
	if (actor == value) return;
	[actor release];
	actor = [value retain];
	
	self.title = [NSString stringWithFormat:@"Movies with %@", actor.name];
	navBar.topItem.title = self.title;
	navBar.topItem.rightBarButtonItem.title = [NSString stringWithFormat:@"%@ - Delivered by Netflix", actor.name];
	page = 0;
	[self requestActorPage]; // get the first page of 20 movies
	[gridView reloadData];
}

- (void)requestActorPage
{
	// we get 20 titles per page, so skip as required
	NSURL *odotaURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://odata.netflix.com/Catalog/People(%@)?$expand=Awards,TitlesActedIn,TitlesDirected&$format=json", actor.identifier]];
		
	[networkQueue cancelAllOperations];
	networkQueue = [ASINetworkQueue queue];
	[networkQueue retain];
	networkQueue.delegate = self;
	networkQueue.requestDidFinishSelector = @selector(requestFinished:);
	networkQueue.requestDidFailSelector = @selector(actorRequestFailed:);
	networkQueue.queueDidFinishSelector = nil;
	
	getActorMoviesRequest = [ASIHTTPRequest requestWithURL:odotaURL];
	
	[networkQueue addOperation:getActorMoviesRequest];
	[networkQueue go];
}

- (void)actorRequestFailed:(ASIHTTPRequest *)inRequest;
{
	NSLog(@"Actor request timed out or cancelled");
}

- (void)requestFinished:(ASIHTTPRequest *)inRequest;
{
	NSData *jsonData = [inRequest responseData];
	NSDictionary *dicto = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];
	
	NSArray *moviesActedIn = [[dicto valueForKeyPath:@"d.TitlesDirected.results"] 
							  arrayByAddingObjectsFromArray:[dicto valueForKeyPath:@"d.TitlesActedIn.results"]];
	//NSLog(@"Movies: %@", moviesActedIn);
	
	NSMutableArray *mutableMovies = [NSMutableArray array];
	for (NSDictionary *movieDictionary in moviesActedIn) {
		Movie *movie = [[[Movie alloc] init] autorelease];
		movie.title = [movieDictionary objectForKey:@"Name"];
		NSString *largeimage = [movieDictionary valueForKeyPath:@"BoxArt.LargeUrl"];
		movie.thumbURL = [NSURL URLWithString:largeimage]; // stringByReplacingOccurrencesOfString:@"large" withString:@"150"]];
		NSString *hdstring = [movieDictionary valueForKeyPath:@"BoxArt.HighDefinitionUrl"];
		movie.fullImageURL = ((id)hdstring == [NSNull null]) ? movie.thumbURL : [NSURL URLWithString:hdstring ]; //stringByReplacingOccurrencesOfString:@"ghd" withString:@"hd1080"]];
		movie.synopsis = [movieDictionary valueForKeyPath:@"Synopsis"];
		movie.stars = [movieDictionary valueForKeyPath:@"AverageRating"];
		movie.releaseYear = [movieDictionary valueForKeyPath:@"ReleaseYear"];
		movie.rating = [movieDictionary valueForKeyPath:@"Rating"];
		if ([movieDictionary valueForKeyPath:@"Runtime"] == [NSNull null])
			movie.seconds = 0;
		else
			movie.seconds = [[movieDictionary valueForKeyPath:@"Runtime"] intValue];
		//NSLog(@"Seconds %d", movie.seconds);
		movie.castURL = [NSURL URLWithString:[[movieDictionary valueForKeyPath:@"Cast.__deferred.uri"] stringByAppendingString:@"?$format=json"]];
		movie.directorsURL = [NSURL URLWithString:[[movieDictionary valueForKeyPath:@"Directors.__deferred.uri"] stringByAppendingString:@"?$format=json"]];
		movie.instantAvailable = [[movieDictionary valueForKeyPath:@"Instant.Available"] boolValue];
		
		// remove duplicates, actor-director, using brute force since the lists are short
		BOOL add = YES;
		for (Movie *m in mutableMovies) {
			if ([[movie.thumbURL absoluteString] isEqualToString:[m.thumbURL absoluteString]]) {
				add = NO;
				break;
			}
		} 
		if (add)		
			[mutableMovies addObject:movie];
	}
	if (page == 0) {
		self.movies = mutableMovies; // first page
		[self requestBoxshotsForPage];
	} else {
		NSLog(@"Adding page %d", page);
		self.movies = [self.movies arrayByAddingObjectsFromArray:mutableMovies];
		[self requestBoxshotsForPage];
	}
	
}

- (void)requestBoxshotsForPage
{	
	[networkQueue cancelAllOperations];
	networkQueue = [ASINetworkQueue queue];
	[networkQueue retain];
	networkQueue.delegate = self;
	networkQueue.requestDidFinishSelector = @selector(loadedImage:);
	networkQueue.requestDidFailSelector = @selector(movieRequestFailed:);
	//if (page == 0)
	//	networkQueue.queueDidFinishSelector = @selector(nextPage:);
	//else
		networkQueue.queueDidFinishSelector = nil; // only get one page for now
	
	int i=page*20;
	for (Movie *movie in movies) {
		//Load movie url
		ASIHTTPRequest *rejq = [ASIHTTPRequest requestWithURL:movie.thumbURL];
		rejq.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:i++] forKey:@"Index"];
		rejq.delegate = self;
		[rejq setDidFinishSelector:@selector(loadedImage:)];
		
		[networkQueue addOperation:rejq];
	}
	[networkQueue go];
}

- (void)loadedImage:(ASIHTTPRequest *)inRequest;
{
	NSNumber *indexNumb = [inRequest.userInfo objectForKey:@"Index"];
	if (indexNumb == nil) {
		NSLog(@"MoviesViewController.loadedImage.indexNumb is null for request: %@", [[inRequest url] absoluteURL]);
		return;
	}
	int idx = [indexNumb intValue];
	if (idx < movies.count) {
		[[movies objectAtIndex:idx] setThumb: [UIImage imageWithData:[inRequest responseData]]];
	}
	[gridView reloadData];
	
}

- (void)movieRequestFailed:(ASIHTTPRequest *)inRequest;
{
	NSLog(@"Movie request timed out or cancelled for %@", [[inRequest url] absoluteURL]);
}

- (void)nextPage:(ASINetworkQueue *)nq
{
	NSLog(@"Next page request");
	page++;
	[self requestActorPage];
}

- (void)setMovies:(NSArray *)value {
	if (movies == value) return;
	[movies release];
	movies = [value retain];
	
	[gridView reloadData];
}

- (IBAction)back;
{
	[networkQueue cancelAllOperations];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)netflix
{
	//NSLog(@"Actor ident %@", actor.identifier);
	NetflixViewController *web = [[NetflixViewController alloc] initWithUrlString:[NSString stringWithFormat:@"http://www.netflix.com/RoleDisplay/%@", actor.identifier]];
	web.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentModalViewController:web animated:YES];
}

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) gridView;
{
	return movies.count;
}

- (AQGridViewCell *) gridView: (AQGridView *)inGridView cellForItemAtIndex: (NSUInteger) index;
{
	MovieCell *cell = (MovieCell *)[inGridView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [MovieCell cell];
		cell.reuseIdentifier = @"cell";
	}
	//cell.backgroundColor = [UIColor blueColor];
	cell.selectionStyle = AQGridViewCellSelectionStyleGlow;
		
	Movie *mov = [movies objectAtIndex:index];
	
	cell.imageView.image = mov.thumb ? mov.thumb : nil;
	cell.instantAvailableView.hidden = !mov.instantAvailable;
	
	return cell;
}

- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index;
{
	MovieInfoViewController *vc = [[[MovieInfoViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	
	Movie *movie = [movies objectAtIndex:index];
	vc.movie = movie;
	vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentModalViewController:vc animated:YES];
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) gridView;
{
	return CGSizeMake(200, 250);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)viewWillAppear:(BOOL)animated;
{
	[gridView reloadData];
	
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated;
{
	[self.gridView deselectItemAtIndex: [self.gridView indexOfSelectedItem] animated: YES];
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
	
	[gridView release];
	gridView = nil;

	[movies release];
	movies = nil;

	[actor release];
	actor = nil;

	[navBar release];
	navBar = nil;

    [super dealloc];
}

/* This is the returned json format for each movie to parse data from
{
	AudioFormats = {
		"__deferred" = {
			uri = "http://odata.netflix.com/Catalog/Titles('7wcf7')/AudioFormats";
		};
	};
	AverageRating = 4.2;
	Awards = {
		"__deferred" = {
			uri = "http://odata.netflix.com/Catalog/Titles('7wcf7')/Awards";
		};
	};
	BluRay =                     {
		Available = 0;
		AvailableFrom = <null>;
		AvailableTo = <null>;
		"__metadata" = {
			type = "NetflixModel.DeliveryFormatAvailability";
		};
	};
	BoxArt = {
		HighDefinitionUrl = <null>;
		LargeUrl = "http://cdn-7.nflximg.com/us/boxshots/large/17405997.jpg";
		MediumUrl = "http://cdn-7.nflximg.com/us/boxshots/small/17405997.jpg";
		SmallUrl = "http://cdn-7.nflximg.com/us/boxshots/tiny/17405997.jpg";
		"__metadata" =                         {
			type = "NetflixModel.BoxArt";
		};
	};
	Cast = {
		"__deferred" = {
			uri = "http://odata.netflix.com/Catalog/Titles('7wcf7')/Cast";
		};
	};
	DateModified = "/Date(1271871175000)/";
	Directors = {
		"__deferred" = {
			uri = "http://odata.netflix.com/Catalog/Titles('7wcf7')/Directors";
		};
	};
	Disc = {
		"__deferred" = {
			uri = "http://odata.netflix.com/Catalog/Titles('7wcf7')/Disc";
		};
	};
	Dvd = {
		Available = 1;
		AvailableFrom = "/Date(912729600000)/";
		AvailableTo = <null>;
		"__metadata" = {
			type = "NetflixModel.DeliveryFormatAvailability";
		};
	};
	Genres = {
		"__deferred" = {
			uri = "http://odata.netflix.com/Catalog/Titles('7wcf7')/Genres";
		};
	};
	Id = 7wcf7;
	Instant = {
		Available = 0;
		AvailableFrom = <null>;
		AvailableTo = <null>;
		HighDefinitionAvailable = 0;
		"__metadata" = {
			type = "NetflixModel.InstantAvailability";
		};
	};
	Languages = {
		"__deferred" = {
			uri = "http://odata.netflix.com/Catalog/Titles('7wcf7')/Languages";
		};
	};
	Movie = {
		"__deferred" = {
			uri = "http://odata.netflix.com/Catalog/Titles('7wcf7')/Movie";
		};
	};
	Name = "Good Will Hunting";
	NetflixApiId = "http://api.netflix.com/catalog/titles/movies/17405997";
	Rating = R;
	ReleaseYear = 1997;
	Runtime = 7560;
	ScreenFormats = {
		"__deferred" = {
			uri = "http://odata.netflix.com/Catalog/Titles('7wcf7')/ScreenFormats";
		};
	};
	Season = {
		"__deferred" = {
			uri = "http://odata.netflix.com/Catalog/Titles('7wcf7')/Season";
		};
	};
	Series = {
		"__deferred" = {
			uri = "http://odata.netflix.com/Catalog/Titles('7wcf7')/Series";
		};
	};
	ShortName = "Good Will Hunting";
	Synopsis = "Will Hunting (<a href=\"http://www.netflix.com/RoleDisplay/Matt_Damon/20002120\">Matt Damon</a>) spends his days as a janitor at MIT, but the aimless young man is also a mathematical genius. So when his talents are discovered, a therapist (<a href=\"http://www.netflix.com/RoleDisplay/Robin_Williams/99687\">Robin Williams</a>) helps Will confront the demons that have been holding him back. Damon and co-star <a href=\"http://www.netflix.com/RoleDisplay/Ben_Affleck/20000016\">Ben Affleck</a> -- who appears in a small role as Will's best friend -- won an Oscar for their screenplay about friendship and risk in this uplifting drama from director <a href=\"http://www.netflix.com/RoleDisplay/Gus_Van_Sant/95033\">Gus Van Sant</a>.";
	TinyUrl = "http://movi.es/7wcf7";
	Type = Movie;
	Url = "http://www.netflix.com/Movie/Good_Will_Hunting/17405997";
	WebsiteUrl = "http://www.miramax.com/mm_front/owa/mp.entryPoint?action=2&midStr=497";
	"__metadata" =                     {
		"content_type" = "image/jpeg";
		"edit_media" = "http://odata.netflix.com/Catalog/Titles('7wcf7')/$value";
		etag = "W/\"datetime'2010-04-21T17%3A32%3A55'\"";
		"media_etag" = "\"4/21/2010 5:32:55 PM\"";
		"media_src" = "http://cdn-7.nflximg.com/us/boxshots/large/17405997.jpg";
		type = "NetflixModel.Title";
		uri = "http://odata.netflix.com/Catalog/Titles('7wcf7')";
	};
}
*/
@end

