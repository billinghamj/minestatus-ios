//
//  AddServerViewController.h
//  MineStatus
//
//  Created by James Billingham on 05/12/14.
//  Copyright (c) 2014 James Billingham. All rights reserved.
//

#import "MNSServer.h"

@protocol AddServerDelegate

- (void)addServer:(MNSServer *)server;

@end

@interface AddServerViewController : UIViewController

@property (weak, nonatomic) id <AddServerDelegate> delegate;

@end
