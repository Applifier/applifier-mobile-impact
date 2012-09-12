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
#import "ApplifierImpact.h"

@interface ApplifierImpactViewController () <ApplifierImpactDelegate>
@end

@implementation ApplifierImpactViewController

@synthesize buttonView;
@synthesize contentView;
@synthesize currentPhase;
@synthesize avPlayer;
@synthesize avPlayerLayer;
@synthesize avAsset;
@synthesize avPlayerItem;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[ApplifierImpact sharedInstance] setDelegate:self];
	
    [buttonView addTarget:self action:@selector(nextPhase) forControlEvents:UIControlEventTouchUpInside];
	[buttonView setImage:[UIImage imageNamed:@"hayday_start"] forState:UIControlStateNormal];
}

- (void)nextPhase
{
	[[ApplifierImpact sharedInstance] showImpact];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - ApplifierImpactDelegate

- (void)applifierImpactWillOpen:(ApplifierImpact *)applifierImpact
{
	NSLog(@"applifierImpactWillOpen");
}

- (void)applifierImpactWillClose:(ApplifierImpact *)applifierImpact
{
	NSLog(@"applifierImpactWillClose");
}

- (void)applifierImpactVideoStarted:(ApplifierImpact *)applifierImpact
{
	NSLog(@"applifierImpactVideoStarted");
}

- (void)applifierImpactVideoCompleted:(ApplifierImpact *)applifierImpact
{
	NSLog(@"applifierImpactVideoCompleted");
}

- (void)applifierImpactCampaignsAreAvailable:(ApplifierImpact *)applifierImpact
{
	NSLog(@"applifierImpactCampaignsAreAvailable");
}

- (void)applifierImpact:(ApplifierImpact *)applifierImpact wantsToShowAdView:(UIView *)adView
{
	NSLog(@"wantsToShowAdView");
	
	adView.frame = self.view.bounds;
	
	[self.view addSubview:adView];
}

@end
