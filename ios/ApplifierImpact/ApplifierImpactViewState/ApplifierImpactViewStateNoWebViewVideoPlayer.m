//
//  ApplifierImpactViewStateNoWebViewVideoPlayer.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/11/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewStateNoWebViewVideoPlayer.h"


@implementation ApplifierImpactViewStateNoWebViewVideoPlayer

- (ApplifierImpactViewStateType)getStateType {
  return kApplifierImpactViewStateTypeVideoPlayer;
}

- (void)willBeShown {
  [super willBeShown];
  
  // FIX: Show native spinner
  
  [[ApplifierImpactCampaignManager sharedInstance] setSelectedCampaign:nil];
  ApplifierImpactCampaign *campaign = [[[ApplifierImpactCampaignManager sharedInstance] getViewableCampaigns] objectAtIndex:0];
  
  if (campaign != nil) {
    [[ApplifierImpactCampaignManager sharedInstance] setSelectedCampaign:campaign];
  }

  /*
  if ([[ApplifierImpactShowOptionsParser sharedInstance] noOfferScreen]) {
    [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];
    
    [[ApplifierImpactCampaignManager sharedInstance] setSelectedCampaign:nil];
    
    ApplifierImpactCampaign *campaign = [[[ApplifierImpactCampaignManager sharedInstance] getViewableCampaigns] objectAtIndex:0];
    
    if (campaign != nil) {
      [[ApplifierImpactCampaignManager sharedInstance] setSelectedCampaign:campaign];
    }
  }*/
}

- (void)wasShown {
  [super wasShown];
  if (self.videoController.parentViewController == nil && [[ApplifierImpactMainViewController sharedInstance] presentedViewController] != self.videoController) {
    [[ApplifierImpactMainViewController sharedInstance] presentViewController:self.videoController animated:NO completion:nil];
  }
}

- (void)enterState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  [super enterState:options];
  [self createVideoController:self];
  
  if (!self.waitingToBeShown) {
    [self showPlayerAndPlaySelectedVideo];
  }
}

- (void)exitState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  [super exitState:options];
}

- (void)applyOptions:(NSDictionary *)options {
  [super applyOptions:options];
}


#pragma mark - Video

- (void)videoPlayerStartedPlaying {
  AILOG_DEBUG(@"");
  
  if (self.delegate != nil) {
    [self.delegate stateNotification:kApplifierImpactStateActionVideoStartedPlaying];
  }
  
  /*
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventHideSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];
  
  // Set completed view for the webview right away, so we don't get flickering after videoplay from start->end
  [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeCompleted data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIActionVideoStartedPlaying, kApplifierImpactItemKeyKey:[[ApplifierImpactCampaignManager sharedInstance] getCurrentRewardItem].key, kApplifierImpactWebViewEventDataCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
  */
  
  //[[ApplifierImpactMainViewController sharedInstance] presentViewController:self.videoController animated:NO completion:nil];
  
  //if (![[ApplifierImpactMainViewController sharedInstance] isBeingPresented]) {
  //  [[ApplifierImpactMainViewController sharedInstance] presentViewController:self.videoController animated:NO completion:nil];
  //}
  
  if (!self.waitingToBeShown && [[ApplifierImpactMainViewController sharedInstance] presentedViewController] != self.videoController) {
    [[ApplifierImpactMainViewController sharedInstance] presentViewController:self.videoController animated:NO completion:nil];
  }
}

- (void)videoPlayerEncounteredError {
  AILOG_DEBUG(@"");
  
  /*
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventHideSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventVideoCompleted data:@{kApplifierImpactNativeEventCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowError data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyVideoPlaybackError}];
  */
  
  [self dismissVideoController];
}

- (void)videoPlayerPlaybackEnded {
  if (self.delegate != nil) {
    [self.delegate stateNotification:kApplifierImpactStateActionVideoPlaybackEnded];
  }
  
  /*
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventVideoCompleted data:@{kApplifierImpactNativeEventCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
   */
  [[ApplifierImpactMainViewController sharedInstance] changeState:kApplifierImpactViewStateTypeEndScreen withOptions:nil];
}

- (void)videoPlayerReady {
	AILOG_DEBUG(@"");
  if (![self.videoController isPlaying])
    [self showPlayerAndPlaySelectedVideo];
}


- (void)showPlayerAndPlaySelectedVideo {
	AILOG_DEBUG(@"");
  
  if (![self canViewSelectedCampaign]) return;
  
  
  /*
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];
  */
  
  [self startVideoPlayback:true withDelegate:self];

}



@end
