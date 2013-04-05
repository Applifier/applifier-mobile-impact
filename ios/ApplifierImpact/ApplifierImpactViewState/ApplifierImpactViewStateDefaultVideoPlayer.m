//
//  ApplifierImpactViewStateDefaultVideoPlayer.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/4/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewStateDefaultVideoPlayer.h"

#import "../ApplifierImpactWebView/ApplifierImpactWebAppController.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"
#import "../ApplifierImpactCampaign/ApplifierImpactRewardItem.h"
#import "../ApplifierImpactView/ApplifierImpactMainViewController.h"
#import "../ApplifierImpactProperties/ApplifierImpactShowOptionsParser.h"
#import "../ApplifierImpact.h"

@interface ApplifierImpactViewStateDefaultVideoPlayer ()
  @property (nonatomic, strong) ApplifierImpactVideoViewController *videoController;
@end


@implementation ApplifierImpactViewStateDefaultVideoPlayer

- (ApplifierImpactViewStateType)getStateType {
  return kApplifierImpactViewStateTypeVideoPlayer;
}

- (void)willBeShown {
  [super willBeShown];
  
  if ([[ApplifierImpactShowOptionsParser sharedInstance] noOfferScreen]) {
    [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];
    
    [[ApplifierImpactCampaignManager sharedInstance] setSelectedCampaign:nil];
    
    ApplifierImpactCampaign *campaign = [[[ApplifierImpactCampaignManager sharedInstance] getViewableCampaigns] objectAtIndex:0];
    
    if (campaign != nil) {
      [[ApplifierImpactCampaignManager sharedInstance] setSelectedCampaign:campaign];
    }
  }
}

- (void)wasShown {
  [super wasShown];
}

- (void)enterState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  
  [super enterState:options];
  
  BOOL checkIfWatched = YES;
  if ([options objectForKey:kApplifierImpactWebViewEventDataRewatchKey] != nil && [[options valueForKey:kApplifierImpactWebViewEventDataRewatchKey] boolValue] == true) {
    checkIfWatched = NO;
  }
  
  [self showPlayerAndPlaySelectedVideo:checkIfWatched];
}

- (void)exitState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  [super exitState:options];
  [self _dismissVideoController];
}

- (void)applyOptions:(NSDictionary *)options {
  [super applyOptions:options];
  
  if (options != nil) {
    if ([options objectForKey:kApplifierImpactNativeEventForceStopVideoPlayback] != nil) {
      [self _destroyVideoController];
    }
  }
}


#pragma mark - Video

- (void)videoPlayerStartedPlaying {
  AILOG_DEBUG(@"");
  
  if (self.delegate != nil) {
    [self.delegate stateNotification:kApplifierImpactStateActionVideoStartedPlaying];
  }
  
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventHideSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];

  // Set completed view for the webview right away, so we don't get flickering after videoplay from start->end
  [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeCompleted data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIActionVideoStartedPlaying, kApplifierImpactItemKeyKey:[[ApplifierImpactCampaignManager sharedInstance] getCurrentRewardItem].key, kApplifierImpactWebViewEventDataCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
  
  [[ApplifierImpactMainViewController sharedInstance] presentViewController:self.videoController animated:NO completion:nil];
}

- (void)videoPlayerEncounteredError {
  AILOG_DEBUG(@"");
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventHideSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventVideoCompleted data:@{kApplifierImpactNativeEventCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowError data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyVideoPlaybackError}];
  
  [self _dismissVideoController];
}

- (void)videoPlayerPlaybackEnded {
  if (self.delegate != nil) {
    [self.delegate stateNotification:kApplifierImpactStateActionVideoPlaybackEnded];
  }
  
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventVideoCompleted data:@{kApplifierImpactNativeEventCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
  [[ApplifierImpactMainViewController sharedInstance] changeState:kApplifierImpactViewStateTypeEndScreen withOptions:nil];
}

- (void)showPlayerAndPlaySelectedVideo:(BOOL)checkIfWatched {
	AILOG_DEBUG(@"");
  
  if ([[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].viewed && checkIfWatched) {
    AILOG_DEBUG(@"Trying to watch a campaign that is already viewed!");
    return;
  }
  
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];
  
  [self _createVideoController];
  [self.videoController playCampaign:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign]];
}

- (void)_createVideoController {
  self.videoController = [[ApplifierImpactVideoViewController alloc] initWithNibName:nil bundle:nil];
  self.videoController.delegate = self;
}

- (void)_destroyVideoController {
  if (self.videoController != nil) {
    [self.videoController forceStopVideoPlayer];
    self.videoController.delegate = nil;
  }
  
  self.videoController = nil;
}

- (void)_dismissVideoController {
  if ([[[ApplifierImpactMainViewController sharedInstance] presentedViewController] isEqual:self.videoController])
    [[[ApplifierImpactMainViewController sharedInstance] presentedViewController] dismissViewControllerAnimated:NO completion:nil];
  
  [self _destroyVideoController];
}

@end
