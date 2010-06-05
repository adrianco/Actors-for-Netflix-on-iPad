//
//  WebkitViewController.m
//  Webkit
//
//  Created by Adrian Cockcroft on 2/4/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "NetflixViewController.h"

@implementation NetflixViewController

@synthesize netflixView;
@synthesize freeButton;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (id) initWithUrlString:(NSString *)aString {
	urlString = aString;
	[urlString retain];
	return self;
}

- (IBAction)back;
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)free;
{
	// Free trial affiliate string administered by Adrian Cockcroft
	// proceeds shared between Andrew Pouliot, Kirsten Jones and Adrian Cockcroft
	urlString = @"http://clickserve.cc-dt.com/link/tplclick?lid=41000000029889162&pubid=21000000000247802&redirect=http%3A%2F%2Fwww.netflix.com%2F";
	[netflixView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
//- (void)loadView {
	// using a nib
//}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	if (urlString == nil)
		[self free];
	else
		[netflixView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (YES);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
