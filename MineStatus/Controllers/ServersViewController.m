//
//  ServersViewController.m
//  MineStatus
//
//  Created by James Billingham on 05/12/14.
//  Copyright (c) 2014 James Billingham. All rights reserved.
//

#import "ServersViewController.h"
#import "AddServerViewController.h"
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

@interface ServersViewController () <UITableViewDataSource, AddServerDelegate, GCDAsyncUdpSocketDelegate>

@property (weak, nonatomic) IBOutlet UITableView *serversTableView;

@end

@implementation ServersViewController
{
	NSArray *_servers;
}

#pragma mark - UIViewController Overrides

- (void)viewDidLoad
{
	[super viewDidLoad];

	_servers = [NSArray array];

	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	[self.serversTableView setEditing:editing animated:animated];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"addServer"])
	{
		[self setEditing:false animated:true];

		UINavigationController *nc = segue.destinationViewController;
		AddServerViewController *vc = nc.childViewControllers[0];
		vc.delegate = self;
	}
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _servers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServerCell" forIndexPath:indexPath];

	MNSServer *server = _servers[indexPath.row];

	cell.textLabel.text = server.name;
	cell.detailTextLabel.text = server.address.description;

	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self deleteServerIndex:indexPath.row];
	}
}

#pragma mark - AddServerDelegate Methods

- (void)addServer:(MNSServer *)server
{
	_servers = [_servers arrayByAddingObject:server];
	int index = (int)_servers.count - 1;

	NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:0];
	[self.serversTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];

	[server.address resolveServer:^(MNSAddress *address)
	{
		NSError *error;
		GCDAsyncUdpSocket *sock = [[GCDAsyncUdpSocket alloc] init];

		sock.delegate = self;
		sock.delegateQueue = dispatch_get_main_queue();
		sock.userData = @(index);

		if (![sock connectToHost:address.host onPort:address.port error:&error])
			NSLog(@"Immediate connection failure - %@", error);

		if (![sock beginReceiving:&error])
			NSLog(@"Immediate receiving failure - %@", error);
	}];
}

#pragma mark - GCDAsyncUdpSocketDelegate Methods

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
	const uint8_t magic[] = { 0xFE, 0xFD };
	const uint8_t challenge[] = { 0x09 };
	const uint8_t status[] = { 0x00 };

	uint8_t idToken[4] = { 0x00, 0x00, 0x00, 0x00 };
	int index = [sock.userData intValue];
	memcpy(idToken, &index, sizeof(index));

	NSMutableData *data = [NSMutableData data];
	[data appendBytes:magic length:sizeof(magic)];
	[data appendBytes:challenge length:sizeof(challenge)];
	[data appendBytes:idToken length:sizeof(idToken)];

	[sock sendData:data withTimeout:10 tag:0];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
	NSLog(@"Connection failure - %@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
	NSLog(@"Did send data");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	NSLog(@"Did not send data - %@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
	NSLog(@"Did receive data");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
	NSLog(@"Socket closed - %@", error);
}

#pragma mark - Supporting Methods

- (void)deleteServerIndex:(NSInteger)index
{
	NSMutableArray *servers = _servers.mutableCopy;
	[servers removeObjectAtIndex:index];
	_servers = servers;

	NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:0];
	[self.serversTableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
