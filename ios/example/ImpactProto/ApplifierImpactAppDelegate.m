//
//  ApplifierImpactAppDelegate.m
//  ImpactProto
//
//  Created by bluesun on 7/30/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactAppDelegate.h"
#import "ApplifierImpactViewController.h"
#import <ApplifierImpact/ApplifierImpact.h>

@interface ApplifierImpactAppDelegate ()
@end

@implementation ApplifierImpactAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	if ([self.window respondsToSelector:@selector(setRootViewController:)]) {
        NSString *xibName = @"ApplifierImpactViewController";
        
        /*
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
            xibName = @"ApplifierImpact_iPad";
        }*/
        
		self.viewController = [[ApplifierImpactViewController alloc] initWithNibName:xibName bundle:nil];
		self.window.rootViewController = self.viewController;
	}
	else {
		UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
		view.backgroundColor = [UIColor greenColor];
		[self.window addSubview:view];
	}
	
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.viewController.loadingImage setImage:[UIImage imageNamed:@"impact-loading"]];
    [self.viewController.buttonView setEnabled:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
