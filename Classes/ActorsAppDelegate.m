//
//  ActorsAppDelegate.m
//  Actors
//
//  Created by Andrew Pouliot on 4/17/10.
//  Copyright Darknoon 2010. All rights reserved.
//

#import "ActorsAppDelegate.h"
#import "ActorsViewController.h"

@implementation ActorsAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
