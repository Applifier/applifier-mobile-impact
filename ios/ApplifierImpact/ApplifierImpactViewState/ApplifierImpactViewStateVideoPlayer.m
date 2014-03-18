//
//  ApplifierImpactViewStateVideoPlayer.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/11/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewStateVideoPlayer.h"
#import "../ApplifierImpactVideo/ApplifierImpactVideoViewController.h"
#import "ApplifierImpactAppSheetManager.h"

@implementation ApplifierImpactViewStateVideoPlayer

- (void)enterState:(NSDictionary *)options {
  [super enterState:options];
  
  AILOG_DEBUG(@"campaign=%@  byPassAppSheet=%i", [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign], [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].bypassAppSheet);
  
  if ([[ApplifierImpactCampaignManager sharedInstance] selectedCampaign] != nil &&
      ![[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].bypassAppSheet &&
      ![[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].viewed) {
    [[ApplifierImpactAppSheetManager sharedInstance] preloadAppSheetWithId:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].itunesID];
  }
  
  self.checkIfWatched = YES;
  if ([options objectForKey:kApplifierImpactWebViewEventDataRewatchKey] != nil && [[options valueForKey:kApplifierImpactWebViewEventDataRewatchKey] boolValue] == true) {
    self.checkIfWatched = NO;
  }
}

- (void)exitState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  [super exitState:options];
  [self dismissVideoController];
}

- (void)applyOptions:(NSDictionary *)options {
  if (options != nil) {
    if ([options objectForKey:kApplifierImpactNativeEventForceStopVideoPlayback] != nil) {
      [self destroyVideoController];
    }
  }
}

- (void)destroyVideoController {
  if (self.videoController != nil) {
    [self.videoController forceStopVideoPlayer];
    self.videoController.delegate = nil;
  }
  
  self.videoController = nil;
}

- (void)createVideoController:(id)targetDelegate {
  self.videoController = [[ApplifierImpactVideoViewController alloc] initWithNibName:nil bundle:nil];
  self.videoController.delegate = targetDelegate;
}

- (void)dismissVideoController {
  if ([[[ApplifierImpactMainViewController sharedInstance] presentedViewController] isEqual:self.videoController])
    [[[ApplifierImpactMainViewController sharedInstance] presentedViewController] dismissViewControllerAnimated:NO completion:nil];
  
  [self destroyVideoController];
}

- (BOOL)canViewSelectedCampaign {
  if ([[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].viewed && self.checkIfWatched) {
    AILOG_DEBUG(@"Trying to watch a campaign that is already viewed!");
    return false;
  }
  
  return true;
}

- (void)startVideoPlayback:(BOOL)createVideoController withDelegate:(id)videoControllerDelegate {
  if ([[ApplifierImpactMainViewController sharedInstance] isOpen]) {
    [self.videoController playCampaign:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign]];
  }
}

@end
