//
//  MNSServer.m
//  MineStatus
//
//  Created by James Billingham on 05/12/14.
//  Copyright (c) 2014 James Billingham. All rights reserved.
//

#import "MNSServer.h"

@implementation MNSServer

- (id)copyWithZone:(NSZone *)zone
{
	MNSServer *copy = [[MNSServer allocWithZone:zone] init];

	if (copy)
	{
		copy.name = [self.name copyWithZone:zone];
		copy.address = [self.address copyWithZone:zone];
	}

	return copy;
}

@end
