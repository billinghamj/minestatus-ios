//
//  MNSAddress.h
//  MineStatus
//
//  Created by James Billingham on 05/12/14.
//  Copyright (c) 2014 James Billingham. All rights reserved.
//

@interface MNSAddress : NSObject

@property (strong, nonatomic) NSString *host;
@property (assign, nonatomic) uint16_t port;

@end
