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
	
    [self changePhase:1];
    [buttonView addTarget:self action:@selector(nextPhase) forControlEvents:UIControlEventTouchUpInside];
    [self initVideo];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == avPlayer && [keyPath isEqualToString:@"status"]) {
        if (avPlayer.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
        } else if (avPlayer.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayer Ready to Play");
        } else if (avPlayer.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)nextPhase
{
	[[ApplifierImpact sharedInstance] showImpact];
	
	return;
    NSLog(@"nextPhase");
    [self changePhase:currentPhase + 1];
}

- (void)changePhase:(int)newPhase
{
    currentPhase = newPhase;
    
    if (currentPhase > 5)
        currentPhase = 1;
    
    NSLog(@"change phase: %d", currentPhase);
    
    switch (currentPhase) {
        case 1:
            [buttonView setBackgroundImage:[UIImage imageNamed:@"hayday_start.png"] forState:UIControlStateNormal];
            break;
        case 2:
            [buttonView setBackgroundImage:[UIImage imageNamed:@"hayday_watchvideo.png"] forState:UIControlStateNormal];
            break;
        case 3:
            [self playVideo];
            break;
        case 4:
            [buttonView setBackgroundImage:[UIImage imageNamed:@"hayday_watchedvideo.png"] forState:UIControlStateNormal];
            [buttonView addTarget:self action:@selector(nextPhase) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 5:
            [buttonView setBackgroundImage:[UIImage imageNamed:@"hayday_end.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }   
}

- (void)initVideo
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jetiphone" ofType:@"mp4"];    
    avAsset = [AVAsset assetWithURL:[[NSURL alloc] initFileURLWithPath:path]];
    avPlayerItem = [AVPlayerItem playerItemWithAsset:avAsset];
    avPlayer = [AVPlayer playerWithPlayerItem:avPlayerItem];
    [avPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:avPlayerItem];
    avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
    avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    avPlayerLayer.frame = contentView.layer.bounds;
    avPlayerLayer.bounds = avPlayerLayer.bounds;
}

- (void)playVideo
{
    [buttonView removeTarget:self action:@selector(nextPhase) forControlEvents:UIControlEventTouchUpInside];
    [contentView.layer addSublayer:avPlayerLayer];
    [avPlayer seekToTime:CMTimeMake(0, 1)];
    [avPlayer play];
}

- (void)videoEnd
{
    NSLog(@"video end");
    [self nextPhase];
    [self hideVideo];
}
 
- (void)hideVideo
{
    [avPlayerLayer removeFromSuperlayer];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - ApplifierImpactDelegate

- (void)applifierImpactWillOpen:(ApplifierImpact *)applifierImpact
{
}

- (void)applifierImpactWillClose:(ApplifierImpact *)applifierImpact
{
}

- (void)applifierImpactVideoStarted:(ApplifierImpact *)applifierImpact
{
}

- (void)applifierImpactVideoCompleted:(ApplifierImpact *)applifierImpact
{
}

- (void)applifierImpactCampaignsAreAvailable:(ApplifierImpact *)applifierImpact
{
}

- (void)applifierImpact:(ApplifierImpact *)applifierImpact wantsToShowAdView:(UIView *)adView
{
	adView.frame = self.view.bounds;
	
	[self.view addSubview:adView];
}

@end
