//
//  MNSAddress.m
//  MineStatus
//
//  Created by James Billingham on 05/12/14.
//  Copyright (c) 2014 James Billingham. All rights reserved.
//

#import "MNSAddress.h"

@implementation MNSAddress

- (NSString *)description
{
	NSString *output = self.host;

	if (self.port != 0)
		output = [output stringByAppendingFormat:@":%u", self.port];

	return output;
}

@end
