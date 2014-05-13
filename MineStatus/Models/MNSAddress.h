//
//  MNSAddress.h
//  MineStatus
//
//  Created by James Billingham on 05/12/14.
//  Copyright (c) 2014 James Billingham. All rights reserved.
//

#import <DNSKit/DNSResponse.h>

@interface MNSAddress : NSObject <NSCopying>

@property (strong, nonatomic) NSString *host;
@property (assign, nonatomic) uint16_t port;

+ (instancetype)addressWithString:(NSString *)string;
+ (instancetype)addressWithSRVRecord:(DNSSRVRecord *)record;

- (instancetype)initWithString:(NSString *)string;
- (instancetype)initWithSRVRecord:(DNSSRVRecord *)record;

@end
