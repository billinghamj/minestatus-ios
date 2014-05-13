//
//  MNSAddress.m
//  MineStatus
//
//  Created by James Billingham on 05/12/14.
//  Copyright (c) 2014 James Billingham. All rights reserved.
//

#import "MNSAddress.h"
#import <DNSKit/DNSQuery.h>

#define ValidationRegex @"^([A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,}))(\\:([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5]))?$"
#define DefaultMinecraftPort 25565

@implementation MNSAddress

+ (instancetype)addressWithString:(NSString *)string
{
	return [[MNSAddress alloc] initWithString:string];
}

+ (instancetype)addressWithSRVRecord:(DNSSRVRecord *)record
{
	return [[MNSAddress alloc] initWithSRVRecord:record];
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

- (instancetype)initWithSRVRecord:(DNSSRVRecord *)record
{
	if (self = [self init])
	{
		self.host = record.target;
		self.port = record.port;
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

- (void)resolveServer:(void (^)(MNSAddress *address))callback
{
	if (_port != 0)
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
		{
			callback(self);
		});

		return;
	}

	DNSQuery *query = [[DNSQuery alloc] init];
	query.rrType = kDNSServiceType_SRV;
	query.timeout = 2;

	NSString *host = [@"_minecraft._tcp." stringByAppendingString:self.host];

	[query searchWithName:host block:^(DNSResponse *response)
	{
		if (!response.records.count)
		{
			MNSAddress *address = self.copy;
			address.port = DefaultMinecraftPort;
			callback(address);
			return;
		}

		DNSSRVRecord *record = response.records[0];
		MNSAddress *address = [MNSAddress addressWithSRVRecord:record];
		callback(address);
	}];
}

@end
