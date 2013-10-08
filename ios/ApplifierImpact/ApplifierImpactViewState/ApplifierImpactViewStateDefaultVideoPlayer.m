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
#import "../ApplifierImpactItem/ApplifierImpactRewardItem.h"
#import "../ApplifierImpactData/ApplifierImpactInstrumentation.h"

#import "../ApplifierImpactZone/ApplifierImpactZoneManager.h"
#import "../ApplifierImpactZone/ApplifierImpactIncentivizedZone.h"
#import "../ApplifierImpactItem/ApplifierImpactRewardItemManager.h"

@interface ApplifierImpactViewStateDefaultVideoPlayer ()
@end

@implementation ApplifierImpactViewStateDefaultVideoPlayer

- (ApplifierImpactViewStateType)getStateType {
  return kApplifierImpactViewStateTypeVideoPlayer;
}

- (void)willBeShown {
  [super willBeShown];
  
  id currentZone = [[ApplifierImpactZoneManager sharedInstance] getCurrentZone];
  if ([currentZone noOfferScreen]) {
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
    [[[ApplifierImpactWebAppController sharedInstance] webView] removeFromSuperview];
    [self.videoController.view addSubview:[[ApplifierImpactWebAppController sharedInstance] webView]];
    [[[ApplifierImpactWebAppController sharedInstance] webView] setFrame:self.videoController.view.bounds];
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
  
  if ([[ApplifierImpactWebAppController sharedInstance] webView].superview != nil) {
    [[[ApplifierImpactWebAppController sharedInstance] webView] removeFromSuperview];
    [[[ApplifierImpactMainViewController sharedInstance] view] addSubview:[[ApplifierImpactWebAppController sharedInstance] webView]];
    [[[ApplifierImpactWebAppController sharedInstance] webView] setFrame:[[ApplifierImpactMainViewController sharedInstance] view].bounds];
  }
  
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventHideSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];

  // Set completed view for the webview right away, so we don't get flickering after videoplay from start->end
  id currentZone = [[ApplifierImpactZoneManager sharedInstance] getCurrentZone];
  if([currentZone isIncentivized]) {
    id itemManager = [((ApplifierImpactIncentivizedZone *)currentZone) itemManager];
    [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeCompleted data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIActionVideoStartedPlaying, kApplifierImpactItemKeyKey:[itemManager getCurrentItem].key, kApplifierImpactWebViewEventDataCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
  } else {
    [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeCompleted data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIActionVideoStartedPlaying, kApplifierImpactWebViewEventDataCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
  }
  
  if (!self.waitingToBeShown && [[ApplifierImpactMainViewController sharedInstance] presentedViewController] != self.videoController) {
    AILOG_DEBUG(@"Placing videoview to hierarchy");
    [[ApplifierImpactMainViewController sharedInstance] presentViewController:self.videoController animated:NO completion:nil];
  }
}

- (void)videoPlayerEncounteredError {
  AILOG_DEBUG(@"");
  [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].viewed = YES;

  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventHideSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventVideoCompleted data:@{kApplifierImpactNativeEventCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
  
  id currentZone = [[ApplifierImpactZoneManager sharedInstance] getCurrentZone];
  if([currentZone isIncentivized]) {
    id itemManager = [((ApplifierImpactIncentivizedZone *)currentZone) itemManager];
    [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeCompleted data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIActionVideoPlaybackError, kApplifierImpactItemKeyKey:[itemManager getCurrentItem].key, kApplifierImpactWebViewEventDataCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
  } else {
    [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeCompleted data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIActionVideoPlaybackError, kApplifierImpactWebViewEventDataCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
  }

  [[ApplifierImpactMainViewController sharedInstance] changeState:kApplifierImpactViewStateTypeEndScreen withOptions:nil];
  
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowError data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyVideoPlaybackError}];
  
  if ([[ApplifierImpactWebAppController sharedInstance] webView].superview != nil) {
    [[[ApplifierImpactWebAppController sharedInstance] webView] removeFromSuperview];
    [[[ApplifierImpactMainViewController sharedInstance] view] addSubview:[[ApplifierImpactWebAppController sharedInstance] webView]];
    [[[ApplifierImpactWebAppController sharedInstance] webView] setFrame:[[ApplifierImpactMainViewController sharedInstance] view].bounds];
  }
}

- (void)videoPlayerPlaybackEnded:(BOOL)skipped {
  AILOG_DEBUG(@"");
  if (self.delegate != nil) {
    if(skipped) {
      [self.delegate stateNotification:kApplifierImpactStateActionVideoPlaybackSkipped];
    } else {
      [self.delegate stateNotification:kApplifierImpactStateActionVideoPlaybackEnded];
    }
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
  if ([[ApplifierImpactMainViewController sharedInstance] isOpen]) {
    AILOG_DEBUG(@"");
    
    if (![self canViewSelectedCampaign]) return;
    
    [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];
    
    [self startVideoPlayback:true withDelegate:self];
  }
}

@end