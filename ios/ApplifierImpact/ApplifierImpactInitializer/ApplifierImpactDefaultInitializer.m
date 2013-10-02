//
//  ApplifierImpactDefaultInitializer.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/5/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactDefaultInitializer.h"

#import "../ApplifierImpactWebView/ApplifierImpactWebAppController.h"
#import "../ApplifierImpactViewState/ApplifierImpactViewStateDefaultOffers.h"
#import "../ApplifierImpactViewState/ApplifierImpactViewStateDefaultVideoPlayer.h"
#import "../ApplifierImpactViewState/ApplifierImpactViewStateDefaultEndScreen.h"
#import "../ApplifierImpactViewState/ApplifierImpactViewStateDefaultSpinner.h"

#import "../ApplifierImpactZone/ApplifierImpactZoneManager.h"
#import "../ApplifierImpactZone/ApplifierImpactIncentivizedZone.h"

@implementation ApplifierImpactDefaultInitializer

- (void)initImpact:(NSDictionary *)options {
	AILOG_DEBUG(@"");
  [super initImpact:options];
  
  [[ApplifierImpactMainViewController sharedInstance] applyViewStateHandler:[[ApplifierImpactViewStateDefaultOffers alloc] init]];
  [[ApplifierImpactMainViewController sharedInstance] applyViewStateHandler:[[ApplifierImpactViewStateDefaultVideoPlayer alloc] init]];
  [[ApplifierImpactMainViewController sharedInstance] applyViewStateHandler:[[ApplifierImpactViewStateDefaultEndScreen alloc] init]];
  [[ApplifierImpactMainViewController sharedInstance] applyViewStateHandler:[[ApplifierImpactViewStateDefaultSpinner alloc] init]];
  
  [ApplifierImpactWebAppController sharedInstance];
  [[ApplifierImpactWebAppController sharedInstance] setDelegate:self];
  
  [self performSelector:@selector(initCampaignManager) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
  [self performSelector:@selector(initAnalyticsUploader) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
}

- (BOOL)initWasSuccessfull {
  if ([[ApplifierImpactWebAppController sharedInstance] webViewInitialized]) {
    return YES;
  }
  return NO;
}

- (void)reInitialize {
  dispatch_async(self.queue, ^{
    [[ApplifierImpactWebAppController sharedInstance] setWebViewInitialized:NO];
		[[ApplifierImpactProperties sharedInstance] refreshCampaignQueryString];
		[self performSelector:@selector(refreshCampaignManager) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
    [self performSelector:@selector(initAnalyticsUploader) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
	});
}


#pragma mark - Private initalization

- (void)initCampaignManager {
	AIAssert(![NSThread isMainThread]);
	AILOG_DEBUG(@"");
  [[ApplifierImpactCampaignManager sharedInstance] setDelegate:self];
  [super initCampaignManager];
}


#pragma mark - ApplifierImpactCampaignManagerDelegate

- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager updatedWithCampaigns:(NSArray *)campaigns gamerID:(NSString *)gamerID {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
}

- (void)campaignManagerCampaignDataReceived {
  AIAssert([NSThread isMainThread]);
  AILOG_DEBUG(@"Campaign data received.");
  
  if ([[ApplifierImpactCampaignManager sharedInstance] campaignData] != nil) {
    [[ApplifierImpactWebAppController sharedInstance] setWebViewInitialized:NO];
  }
  
  if (![[ApplifierImpactWebAppController sharedInstance] webViewInitialized]) {
    [[ApplifierImpactWebAppController sharedInstance] initWebApp];
  }
}

- (void)campaignManagerCampaignDataFailed {
  AIAssert([NSThread isMainThread]);
  AILOG_DEBUG(@"Campaign data failed.");
  
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.delegate != nil) {
      [self.delegate initFailed];
  }});
}


#pragma mark - WebAppController

- (void)webAppReady {
  AILOG_DEBUG(@"webAppReady");
  dispatch_async(dispatch_get_main_queue(), ^{
    [self checkForVersionAndShowAlertDialog];
    
    id currentZone = [[ApplifierImpactZoneManager sharedInstance] getCurrentZone];
    if([currentZone isIncentivized]) {
      id itemManager = [((ApplifierImpactIncentivizedZone *)currentZone) itemManager];
      [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeNone data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIInitComplete, kApplifierImpactItemKeyKey:[itemManager getCurrentItem].key}];
    } else {
      [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeNone data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIInitComplete}];
    }    
    
    if (self.delegate != nil) {
      [self.delegate initComplete];
    }
  });
}

@end
