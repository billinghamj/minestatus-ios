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
	if (!self.nameField.text.length)
	{
		[[[UIAlertView alloc]
			initWithTitle:@"Invalid Name"
			message:@"Please provide a name for the server"
			delegate:nil
			cancelButtonTitle:@"Okay"
			otherButtonTitles:nil]
		 show];
		return;
	}

	MNSAddress *address = [MNSAddress addressWithString:self.addressField.text];

	if (address == nil)
	{
		[[[UIAlertView alloc]
			initWithTitle:@"Invalid Address"
			message:@"The address you entered is not valid"
			delegate:nil
			cancelButtonTitle:@"Okay"
			otherButtonTitles:nil]
		 show];
		return;
	}

	MNSServer *server = [[MNSServer alloc] init];
	server.name = self.nameField.text;
	server.address = address;

	[self dismissViewControllerAnimated:true completion:^
	{
		[self.delegate addServer:server];
	}];
}

@end
