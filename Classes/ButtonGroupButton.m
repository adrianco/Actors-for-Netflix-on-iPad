//
//  ButtonGroupButton.m
//  Actors
//
//  Created by Andrew Pouliot on 4/17/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "ButtonGroupButton.h"


@implementation ButtonGroupButton

@synthesize actor;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		UIImage *image = [[UIImage imageNamed:@"ActorButtonBG.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
		self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
		[self setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0] forState:UIControlStateNormal];
		[self setBackgroundImage:image forState:UIControlStateNormal];
		[self setImage:[UIImage imageNamed:@"Chevron.png"] forState:UIControlStateNormal];
		self.titleLabel.textAlignment = UITextAlignmentLeft;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size;
{
	size.width = [self.currentTitle sizeWithFont:self.titleLabel.font].width + 40;
	size.height = 32;
	return size;
}

- (CGRect)contentRectForBounds:(CGRect)bounds;
{
	return CGRectInset(bounds, 10, 5);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect;
{
	return CGRectMake(contentRect.size.width - 14, 0, 30, 32);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect;
{
	return contentRect;
}

- (void)setFrame:(CGRect)inFrame;
{
	[super setFrame:inFrame];
	
	//NSLog(@"%@", NSStringFromCGRect(inFrame));
}

- (void)dealloc {
	[actor release];
	actor = nil;

    [super dealloc];
}


@end
