//
//  ActorsAppDelegate.h
//  Actors
//
//  Created by Andrew Pouliot on 4/17/10.
//  Copyright Darknoon 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActorsViewController;

@interface ActorsAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ActorsViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ActorsViewController *viewController;

@end

