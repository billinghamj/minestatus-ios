//
//  MNSServer.h
//  MineStatus
//
//  Created by James Billingham on 05/12/14.
//  Copyright (c) 2014 James Billingham. All rights reserved.
//

#import "MNSAddress.h"

@interface MNSServer : NSObject <NSCopying>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) MNSAddress *address;

@end
