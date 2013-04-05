//
//  ApplifierImpactDefaultInitializer.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/5/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactDefaultInitializer.h"

#import "../ApplifierImpactData/ApplifierImpactAnalyticsUploader.h"
#import "../ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "../ApplifierImpact.h"

@implementation ApplifierImpactDefaultInitializer

- (void)init:(NSDictionary *)options {
  [super init:options];
  
  [self performSelector:@selector(_initCampaignManager) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
  [self performSelector:@selector(_initAnalyticsUploader) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
}

#pragma mark - Private initalization

- (void)_initCampaignManager {
	AIAssert(![NSThread isMainThread]);
	AILOG_DEBUG(@"");
  [[ApplifierImpactCampaignManager sharedInstance] setDelegate:self];
	[self _refreshCampaignManager];
}

- (void)_refreshCampaignManager {
	AIAssert(![NSThread isMainThread]);
	[[ApplifierImpactProperties sharedInstance] refreshCampaignQueryString];
	[[ApplifierImpactCampaignManager sharedInstance] updateCampaigns];
}

- (void)_initAnalyticsUploader {
	AIAssert(![NSThread isMainThread]);
	AILOG_DEBUG(@"");
	[[ApplifierImpactAnalyticsUploader sharedInstance] retryFailedUploads];
}


#pragma mark - ApplifierImpactCampaignManagerDelegate

- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager updatedWithCampaigns:(NSArray *)campaigns rewardItem:(ApplifierImpactRewardItem *)rewardItem gamerID:(NSString *)gamerID {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	//[self _notifyDelegateOfCampaignAvailability];
}

- (void)campaignManagerCampaignDataReceived {
  AIAssert([NSThread isMainThread]);
  AILOG_DEBUG(@"Campaign data received.");
  /*
  if ([[ApplifierImpactCampaignManager sharedInstance] campaignData] != nil) {
    [[ApplifierImpactWebAppController sharedInstance] setWebViewInitialized:NO];
  }
  
  if (![[ApplifierImpactWebAppController sharedInstance] webViewInitialized]) {
    [[ApplifierImpactWebAppController sharedInstance] initWebApp];
  }*/
}

- (void)campaignManagerCampaignDataFailed {
  AIAssert([NSThread isMainThread]);
  AILOG_DEBUG(@"Campaign data failed.");
  /*
  if ([self.delegate respondsToSelector:@selector(applifierImpactCampaignsFetchFailed:)])
		[self.delegate applifierImpactCampaignsFetchFailed:self];*/
  
  if (self.delegate != nil) {
    [self.delegate initFailed];
  }
}

@end
