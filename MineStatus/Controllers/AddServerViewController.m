//
//  AddServerViewController.m
//  MineStatus
//
//  Created by James Billingham on 05/12/14.
//  Copyright (c) 2014 James Billingham. All rights reserved.
//

#import "AddServerViewController.h"

@interface AddServerViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *addressField;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end

@implementation AddServerViewController

- (IBAction)cancel:(id)sender
{
	[self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)done:(id)sender
{
	MNSAddress *address = [[MNSAddress alloc] init];
	address.host = self.addressField.text;
	address.port = 0;

	MNSServer *server = [[MNSServer alloc] init];
	server.name = self.nameField.text;
	server.address = address;

	[self dismissViewControllerAnimated:true completion:^
	{
		[self.delegate addServer:server];
	}];
}

@end
