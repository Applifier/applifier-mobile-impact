//
//  ApplifierImpactNoWebViewInitializer.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/10/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactNoWebViewInitializer.h"

#import "../ApplifierImpactViewState/ApplifierImpactViewStateNoWebViewVideoPlayer.h"
#import "../ApplifierImpactViewState/ApplifierImpactViewStateNoWebViewEndScreen.h"

@interface ApplifierImpactNoWebViewInitializer ()
  @property (nonatomic, assign) BOOL campaignDataReceived;
@end

@implementation ApplifierImpactNoWebViewInitializer

- (void)initImpact:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  self.campaignDataReceived = false;
  
  [super initImpact:options];
  
  [[ApplifierImpactMainViewController sharedInstance] applyViewStateHandler:[[ApplifierImpactViewStateNoWebViewVideoPlayer alloc] init]];
  [[ApplifierImpactMainViewController sharedInstance] applyViewStateHandler:[[ApplifierImpactViewStateNoWebViewEndScreen alloc] init]];
  
  [self performSelector:@selector(initCampaignManager) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
  [self performSelector:@selector(initAnalyticsUploader) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
}


- (void)reInitialize {
  self.campaignDataReceived = false;
  dispatch_async(self.queue, ^{
		[[ApplifierImpactProperties sharedInstance] refreshCampaignQueryString];
		[self performSelector:@selector(refreshCampaignManager) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
    [self performSelector:@selector(initAnalyticsUploader) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
	});
}

- (BOOL)initWasSuccessfull {
  if ([[ApplifierImpactCampaignManager sharedInstance] campaigns] != nil &&
      [[[ApplifierImpactCampaignManager sharedInstance] campaigns] count] > 0 &&
      self.campaignDataReceived) {
    AILOG_DEBUG(@"");
    return YES;
  }
  return NO;
}

#pragma mark - Private initalization

- (void)initCampaignManager {
	AIAssert(![NSThread isMainThread]);
	AILOG_DEBUG(@"");
  [[ApplifierImpactCampaignManager sharedInstance] setDelegate:self];
  [super initCampaignManager];
}


#pragma mark - ApplifierImpactCampaignManagerDelegate

- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager updatedWithCampaigns:(NSArray *)campaigns rewardItem:(ApplifierImpactRewardItem *)rewardItem gamerID:(NSString *)gamerID {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
}

- (void)campaignManagerCampaignDataReceived {
  AIAssert([NSThread isMainThread]);
  AILOG_DEBUG(@"Campaign data received.");
  
  self.campaignDataReceived = true;
  [self checkForVersionAndShowAlertDialog];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.delegate != nil) {
      [self.delegate initComplete];
    }});
  
}

- (void)campaignManagerCampaignDataFailed {
  AIAssert([NSThread isMainThread]);
  AILOG_DEBUG(@"Campaign data failed.");
  
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.delegate != nil) {
      [self.delegate initFailed];
    }});
}

@end
