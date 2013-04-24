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
    [[ApplifierImpact sharedInstance] setDebugMode:YES];
    [[ApplifierImpact sharedInstance] setTestMode:YES];
    [[ApplifierImpact sharedInstance] setImpactMode:kApplifierImpactModeNoWebView];
    
    // Initialize Applifier Impact
	[[ApplifierImpact sharedInstance] startWithGameId:@"16" andViewController:self];
}

- (void)openImpact {
	NSLog(@"canShowImpact: %i",[[ApplifierImpact sharedInstance] canShowImpact]);
    if ([[ApplifierImpact sharedInstance] canShowImpact]) {
        /*
        NSLog(@"REWARD_ITEM_KEYS: %@", [[ApplifierImpact sharedInstance] getRewardItemKeys]);
        NSLog(@"CURRENT_REWARD_ITEM: %@", [[ApplifierImpact sharedInstance] getCurrentRewardItemKey]);
        NSLog(@"SETTING_REWARD_ITEM (wrong): %i", [[ApplifierImpact sharedInstance] setRewardItemKey:@"wrong_key"]);
        NSLog(@"CURRENT_REWARD_ITEM: %@", [[ApplifierImpact sharedInstance] getCurrentRewardItemKey]);
        NSLog(@"SETTING_REWARD_ITEM (right): %i", [[ApplifierImpact sharedInstance] setRewardItemKey:[[[ApplifierImpact sharedInstance] getRewardItemKeys] objectAtIndex:0]]);
        NSLog(@"CURRENT_REWARD_ITEM: %@", [[ApplifierImpact sharedInstance] getCurrentRewardItemKey]);
        NSLog(@"DEFAULT_REWARD_ITEM: %@", [[ApplifierImpact sharedInstance] getDefaultRewardItemKey]); */

        //[[ApplifierImpact sharedInstance] setViewController:self showImmediatelyInNewController:YES];
        
        NSLog(@"showImpact: %i", [[ApplifierImpact sharedInstance] showImpact:@{kApplifierImpactOptionNoOfferscreenKey:@false, kApplifierImpactOptionOpenAnimatedKey:@true, kApplifierImpactOptionGamerSIDKey:@"gom", kApplifierImpactOptionMuteVideoSounds:@true}]);
        
        //[[ApplifierImpact sharedInstance] showImpact];
        
        /*
        NSLog(@"SETTING_REWARD_ITEM (while open): %i", [[ApplifierImpact sharedInstance] setRewardItemKey:[[ApplifierImpact sharedInstance] getDefaultRewardItemKey]]);
        NSLog(@"GETTING_REWARD_ITEM_DETAILS: %@", [[ApplifierImpact sharedInstance] getRewardItemDetailsWithKey:[[ApplifierImpact sharedInstance] getCurrentRewardItemKey]]); */
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
