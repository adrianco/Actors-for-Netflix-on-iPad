//
//  MovieCell.h
//  Actors
//
//  Created by Andrew Pouliot on 4/17/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AQGridViewCell.h"


@interface MovieCell : AQGridViewCell {
	IBOutlet UIImageView *imageView;
	IBOutlet UIView *instantAvailableView;
}

@property (nonatomic, retain) UIView *instantAvailableView;
@property (nonatomic, retain) UIImageView *imageView;

@end
