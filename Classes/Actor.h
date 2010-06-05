//
//  Actor.h
//  Actors
//
//  Created by Andrew Pouliot on 4/18/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Actor : NSObject {
	NSString *name;
	NSString *identifier;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *identifier;

@end
