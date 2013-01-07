//
//  ApplifierImpactViewController.m
//  ImpactProto
//
//  Created by bluesun on 7/30/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <ApplifierImpact/ApplifierImpact.h>

@interface ApplifierImpactViewController () <ApplifierImpactDelegate>
@end

@implementation ApplifierImpactViewController

@synthesize buttonView;
@synthesize loadingImage;
@synthesize contentView;
@synthesize currentPhase;
@synthesize avPlayer;
@synthesize avPlayerLayer;
@synthesize avAsset;
@synthesize avPlayerItem;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[ApplifierImpact sharedInstance] setDelegate:self];
    [self.buttonView addTarget:self action:@selector(openImpact) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // TEST MODE: Do not use in production apps
    [[ApplifierImpact sharedInstance] setTestMode:YES];
    
    // Initialize Applifier Impact
	[[ApplifierImpact sharedInstance] startWithGameId:@"11006" andViewController:self];
}

- (void)openImpact {
	if ([[ApplifierImpact sharedInstance] canShowImpact]) {
        NSLog(@"REWARD_ITEM_KEYS: %@", [[ApplifierImpact sharedInstance] getRewardItemKeys]);
        NSLog(@"CURRENT_REWARD_ITEM: %@", [[ApplifierImpact sharedInstance] getCurrentRewardItemKey]);
        NSLog(@"SETTING_REWARD_ITEM (wrong): %i", [[ApplifierImpact sharedInstance] setRewardItemKey:@"wrong_key"]);
        NSLog(@"CURRENT_REWARD_ITEM: %@", [[ApplifierImpact sharedInstance] getCurrentRewardItemKey]);
        NSLog(@"SETTING_REWARD_ITEM (right): %i", [[ApplifierImpact sharedInstance] setRewardItemKey:[[[ApplifierImpact sharedInstance] getRewardItemKeys] objectAtIndex:0]]);
        NSLog(@"CURRENT_REWARD_ITEM: %@", [[ApplifierImpact sharedInstance] getCurrentRewardItemKey]);
        NSLog(@"DEFAULT_REWARD_ITEM: %@", [[ApplifierImpact sharedInstance] getDefaultRewardItemKey]);

        //[[ApplifierImpact sharedInstance] setViewController:self showImmediatelyInNewController:YES];
        [[ApplifierImpact sharedInstance] showImpact];
        
        NSLog(@"SETTING_REWARD_ITEM (while open): %i", [[ApplifierImpact sharedInstance] setRewardItemKey:[[ApplifierImpact sharedInstance] getDefaultRewardItemKey]]);

	}
	else {
        NSLog(@"Impact cannot be shown.");
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}


#pragma mark - ApplifierImpactDelegate

- (void)applifierImpactCampaignsAreAvailable:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactCampaignsAreAvailable");
    [self.loadingImage setImage:[UIImage imageNamed:@"impact-loaded"]];
	[self.buttonView setEnabled:YES];
}

- (void)applifierImpactWillOpen:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactWillOpen");
}

- (void)applifierImpactDidOpen:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactDidOpen");
}

- (void)applifierImpactWillClose:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactWillClose");
}

- (void)applifierImpactDidClose:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactDidClose");
}

- (void)applifierImpactVideoStarted:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactVideoStarted");
}

- (void)applifierImpact:(ApplifierImpact *)applifierImpact completedVideoWithRewardItemKey:(NSString *)rewardItemKey {
	NSLog(@"applifierImpact:completedVideoWithRewardItem: -- key: %@", rewardItemKey);
    [self.loadingImage setImage:[UIImage imageNamed:@"impact-reward"]];
}

@end
