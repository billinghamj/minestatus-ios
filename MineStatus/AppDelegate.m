//
//  AppDelegate.m
//  MineStatus
//
//  Created by James Billingham on 05/12/14.
//  Copyright (c) 2014 James Billingham. All rights reserved.
//

#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[Crashlytics startWithAPIKey:@"60943e36753b3348a2894642edf74cefa01a0feb"];

	return true;
}

@end
