//
//  ApplifierImpactViewStateDefaultVideoPlayer.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/4/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewStateDefaultVideoPlayer.h"

#import "../ApplifierImpactWebView/ApplifierImpactWebAppController.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"
#import "../ApplifierImpactCampaign/ApplifierImpactRewardItem.h"
#import "../ApplifierImpactProperties/ApplifierImpactShowOptionsParser.h"
#import "../ApplifierImpactData/ApplifierImpactInstrumentation.h"

@interface ApplifierImpactViewStateDefaultVideoPlayer ()
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
  
  if (![[[[ApplifierImpactWebAppController sharedInstance] webView] superview] isEqual:[[ApplifierImpactMainViewController sharedInstance] view]]) {
    [[[ApplifierImpactMainViewController sharedInstance] view] addSubview:[[ApplifierImpactWebAppController sharedInstance] webView]];
    [[[ApplifierImpactWebAppController sharedInstance] webView] setFrame:[[ApplifierImpactMainViewController sharedInstance] view].bounds];
    
    [[[ApplifierImpactMainViewController sharedInstance] view] bringSubviewToFront:[[ApplifierImpactWebAppController sharedInstance] webView]];
  }
}

- (void)exitState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  [super exitState:options];
}

- (void)applyOptions:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  if (options != nil) {
    if ([options objectForKey:@"sendAbortInstrumentation"] != nil && [[options objectForKey:@"sendAbortInstrumentation"] boolValue] == true) {
      NSString *eventType = nil;
      
      if ([options objectForKey:@"type"] != nil) {
        
        eventType = [options objectForKey:@"type"];
        [ApplifierImpactInstrumentation gaInstrumentationVideoAbort:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign] withValuesFrom:@{kApplifierImpactGoogleAnalyticsEventValueKey:eventType, kApplifierImpactGoogleAnalyticsEventBufferingDurationKey:@([[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign] geBufferingDuration])}];
      }
    }
  }
  
  [super applyOptions:options];
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
  
  if (!self.waitingToBeShown && [[ApplifierImpactMainViewController sharedInstance] presentedViewController] != self.videoController) {
    [[ApplifierImpactMainViewController sharedInstance] presentViewController:self.videoController animated:NO completion:nil];
  }
}

- (void)videoPlayerEncounteredError {
  AILOG_DEBUG(@"");
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventHideSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventVideoCompleted data:@{kApplifierImpactNativeEventCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowError data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyVideoPlaybackError}];
  
  [self dismissVideoController];
}

- (void)videoPlayerPlaybackEnded {
  AILOG_DEBUG(@"");
  if (self.delegate != nil) {
    [self.delegate stateNotification:kApplifierImpactStateActionVideoPlaybackEnded];
  }
  
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventVideoCompleted data:@{kApplifierImpactNativeEventCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
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
  
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];

  [self startVideoPlayback:true withDelegate:self];
}

@end