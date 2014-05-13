//
//  MNSAddressTests.m
//  MineStatus
//
//  Created by James Billingham on 05/13/14.
//  Copyright (c) 2014 James Billingham. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTest+Async.h"
#import "MNSAddress.h"

@interface MNSAddressTests : XCTestCase

@end

@implementation MNSAddressTests

- (void)setUp
{
	[super setUp];
}

- (void)tearDown
{
	[super tearDown];
}

#pragma mark - Initialization

- (void)testInitPlain
{
	MNSAddress *address = [[MNSAddress alloc] init];

	XCTAssertNil(address.host);
	XCTAssertEqual(address.port, 0);
}

- (void)testInitWithStringInvalid
{
	NSArray *strings =
	@[
		@"jamesbillingham",
		@"google",
		@"yahoo",
		@"apple",
		@"gov",
		@"jamesbillingham.c",
		@"google.c",
		@"yahoo.c",
		@"apple.c",
		@"gov.u",
		@"jamesbillingham.com:0",
		@"google.com:0",
		@"yahoo.com:0",
		@"apple.com:0",
		@"gov.uk:0",
		@"jamesbillingham.com:65536",
		@"google.com:65536",
		@"yahoo.com:65536",
		@"apple.com:65536",
		@"gov.uk:65536"
	];

	for (NSString *string in strings)
	{
		MNSAddress *address = [[MNSAddress alloc] initWithString:string];

		XCTAssertNil(address);
	}
}

- (void)testInitWithStringWithoutPort
{
	NSArray *strings =
	@[
		@"jamesbillingham.com",
		@"google.com",
		@"yahoo.com",
		@"apple.com",
		@"gov.uk"
	];

	for (NSString *string in strings)
	{
		MNSAddress *address = [[MNSAddress alloc] initWithString:string];

		XCTAssertTrue([address.host isEqualToString:string]);
		XCTAssertEqual(address.port, 0);
	}
}

- (void)testInitWithStringWithPort
{
	NSArray *strings =
	@[
		@"jamesbillingham.com:25565",
		@"google.com:1234",
		@"yahoo.com:1",
		@"apple.com:937",
		@"gov.uk:65535"
	];

	for (NSString *string in strings)
	{
		MNSAddress *address = [[MNSAddress alloc] initWithString:string];

		NSArray *comps = [string componentsSeparatedByString:@":"];
		XCTAssertTrue([address.host isEqualToString:comps[0]]);
		XCTAssertEqual(address.port, [comps[1] intValue]);
	}
}

- (void)testInitWithSRVRecord
{
	NSArray *data =
	@[
		@[@"jamesbillingham.com", @(25565)],
		@[@"google.com", @(1234)],
		@[@"yahoo.com", @(1)],
		@[@"apple.com", @(937)],
		@[@"gov.uk", @(65535)]
	];

	for (NSArray *line in data)
	{
		DNSSRVRecord *record = [[DNSSRVRecord alloc] init];
		record.target = line[0];
		record.port = [line[1] intValue];

		MNSAddress *address = [[MNSAddress alloc] initWithSRVRecord:record];

		XCTAssertTrue([address.host isEqualToString:line[0]]);
		XCTAssertEqual(address.port, [line[1] intValue]);
	}
}

#pragma mark - Server Resolution

- (void)testServerResolutionWithExplicitPorts
{
	NSArray *data =
	@[
		@[@"jamesbillingham.com", @(25565)],
		@[@"google.com", @(1234)],
		@[@"yahoo.com", @(1)],
		@[@"apple.com", @(937)],
		@[@"gov.uk", @(65535)]
	];

	for (NSArray *line in data)
	{
		MNSAddress *address = [[MNSAddress alloc] init];
		address.host = line[0];
		address.port = [line[1] intValue];

		ASYNC_TEST_START;

		[address resolveServer:^(MNSAddress *address)
		{
			XCTAssertTrue([address.host isEqualToString:line[0]]);
			XCTAssertEqual(address.port, [line[1] intValue]);

			ASYNC_TEST_DONE;
		}];

		ASYNC_TEST_END;
	}
}

- (void)testServerResolutionWithoutSRV
{
	NSArray *domains =
	@[
		@"jamesbillingham.com",
		@"google.com",
		@"yahoo.com",
		@"apple.com",
		@"gov.uk"
	];

	for (NSString *domain in domains)
	{
		MNSAddress *address = [[MNSAddress alloc] init];
		address.host = domain;
		address.port = 0;

		ASYNC_TEST_START;

		[address resolveServer:^(MNSAddress *address)
		{
			XCTAssertTrue([address.host isEqualToString:domain]);
			XCTAssertEqual(address.port, 25565);

			ASYNC_TEST_DONE;
		}];

		ASYNC_TEST_END;
	}
}

- (void)testServerResolutionWithSRV
{
	NSArray *data =
	@[
		@[@"skepmc.mcpro.co", @"node278.minecraft.toomanynodes.com", @(25569)],
		@[@"obsidianprison.com", @"minecraft.obsidianprison.com", @(25565)],
		@[@"build.punkcraft.org", @"198.27.95.115", @(25565)],
		@[@"mcunited.mcpro.co", @"node123.minecraft.toomanynodes.com", @(43232)],
		@[@"mc.arkhamnetwork.org", @"dnsresolver1.arkhamnetwork.org", @(25565)]
	];

	for (NSArray *line in data)
	{
		MNSAddress *address = [[MNSAddress alloc] init];
		address.host = line[0];
		address.port = 0;

		ASYNC_TEST_START;

		[address resolveServer:^(MNSAddress *address)
		{
			XCTAssertTrue([address.host isEqualToString:line[1]]);
			XCTAssertEqual(address.port, [line[2] intValue]);

			ASYNC_TEST_DONE;
		}];

		ASYNC_TEST_END;
	}
}

- (void)testServerResolutionWithInvalidDomain
{
	NSArray *domains =
	@[
		@"jamesbillingham.doesnt.exist",
		@"google.asdf",
		@"yahoo.foobar",
		@"apple.arguablyfalse",
		@"gov.uk.a.b.c.d.e.f.g"
	];

	for (NSString *domain in domains)
	{
		MNSAddress *address = [[MNSAddress alloc] init];
		address.host = domain;
		address.port = 0;

		ASYNC_TEST_START;

		[address resolveServer:^(MNSAddress *address)
		{
			// does not test for actual existence, so this is correct
			XCTAssertTrue([address.host isEqualToString:domain]);
			XCTAssertEqual(address.port, 25565);

			ASYNC_TEST_DONE;
		}];

		ASYNC_TEST_END;
	}
}

@end
