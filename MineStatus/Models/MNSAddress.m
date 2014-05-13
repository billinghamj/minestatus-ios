//
//  MNSAddress.m
//  MineStatus
//
//  Created by James Billingham on 05/12/14.
//  Copyright (c) 2014 James Billingham. All rights reserved.
//

#import "MNSAddress.h"

#define ValidationRegex @"^([A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,}))(\\:([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5]))?$"

@implementation MNSAddress

+ (instancetype)addressWithString:(NSString *)string
{
	return [[MNSAddress alloc] initWithString:string];
}

- (instancetype)initWithString:(NSString *)string
{
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:ValidationRegex options:0 error:nil];
	NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];

	NSTextCheckingResult *result = matches.firstObject;

	if (result == nil)
		return nil;

	if (self = [self init])
	{
		self.host = [string substringWithRange:[result rangeAtIndex:1]];

		NSRange portRange = [result rangeAtIndex:5];

		if (portRange.location != NSNotFound)
		{
			NSString *port = [string substringWithRange:portRange];
			self.port = [port intValue];
		}
	}

	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	MNSAddress *copy = [[MNSAddress allocWithZone:zone] init];

	if (copy)
	{
		copy.host = [self.host copyWithZone:zone];
		copy.port = self.port;
	}

	return copy;
}

- (NSString *)description
{
	NSString *output = self.host;

	if (self.port != 0)
		output = [output stringByAppendingFormat:@":%u", self.port];

	return output;
}

@end
