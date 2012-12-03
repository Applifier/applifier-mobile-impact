//
//  ApplifierImpactViewController.m
//  ImpactProto
//
//  Created by bluesun on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
    //[[ApplifierImpact sharedInstance] setTestMode:YES];
	[[ApplifierImpact sharedInstance] startWithGameId:@"16" andViewController:self];
    //[[ApplifierImpact sharedInstance] setViewController:self showImmediatelyInNewController:YES];
}

- (void)openImpact {
	if ([[ApplifierImpact sharedInstance] canShowImpact]) {
        [[ApplifierImpact sharedInstance] showImpact];
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

- (void)applifierImpact:(ApplifierImpact *)applifierImpact completedVideoWithRewardItemKey:(NSString *)rewardItemKey {
	NSLog(@"applifierImpact:completedVideoWithRewardItem: -- key: %@", rewardItemKey);
    [self.loadingImage setImage:[UIImage imageNamed:@"impact-reward"]];
}

- (void)applifierImpactWillOpen:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactWillOpen");
}

- (void)applifierImpactWillClose:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactWillClose");
}

- (void)applifierImpactVideoStarted:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactVideoStarted");
}

- (void)applifierImpactCampaignsAreAvailable:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactCampaignsAreAvailable");
    [self.loadingImage setImage:[UIImage imageNamed:@"impact-loaded"]];
	[self.buttonView setEnabled:YES];
}

@end
