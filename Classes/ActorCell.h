//
//  ActorCell.h
//  Actors
//
//  Created by Andrew Pouliot on 4/17/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "AQGridViewCell.h"

@interface ActorCell : AQGridViewCell {
	UILabel *nameLabel;
	UIImageView *imageView;
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

@end
