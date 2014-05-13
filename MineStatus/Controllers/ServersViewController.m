//
//  ServersViewController.m
//  MineStatus
//
//  Created by James Billingham on 05/12/14.
//  Copyright (c) 2014 James Billingham. All rights reserved.
//

#import "ServersViewController.h"
#import "AddServerViewController.h"

@interface ServersViewController () <UITableViewDataSource, AddServerDelegate>

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

	NSIndexPath *ip = [NSIndexPath indexPathForRow:_servers.count - 1 inSection:0];
	[self.serversTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
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
