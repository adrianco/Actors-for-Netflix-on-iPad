//
//  ButtonGroupButton.h
//  Actors
//
//  Created by Andrew Pouliot on 4/17/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Actor.h"

@interface ButtonGroupButton : UIButton {
	Actor *actor;
}

@property (nonatomic, retain) Actor *actor;

@end
