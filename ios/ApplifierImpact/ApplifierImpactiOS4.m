//
//  ApplifierImpactiOS4.m
//  ImpactProto
//
//  Created by Johan Halin on 9/4/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactiOS4.h"
#import "ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "ApplifierImpactCampaign/ApplifierImpactRewardItem.h"
#import "ApplifierImpactOpenUDID/ApplifierImpactOpenUDID.h"
#import "ApplifierImpactData/ApplifierImpactAnalyticsUploader.h"
#import "ApplifierImpactViewManager.h"
#import "ApplifierImpactDevice/ApplifierImpactDevice.h"
#import "ApplifierImpactProperties/ApplifierImpactProperties.h"

@interface ApplifierImpactiOS4 () <ApplifierImpactCampaignManagerDelegate, UIWebViewDelegate, UIScrollViewDelegate, ApplifierImpactViewManagerDelegate>
@property (nonatomic, strong) NSThread *backgroundThread;
@property (nonatomic, assign) dispatch_queue_t queue;
@end

@implementation ApplifierImpactiOS4


#pragma mark - Private

- (void)_backgroundRunLoop:(id)dummy
{
	@autoreleasepool
	{
		NSPort *port = [[NSPort alloc] init];
		[port scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		while([[NSThread currentThread] isCancelled] == NO)
		{
			@autoreleasepool
			{
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
			}
		}
	}
}

- (void)_refreshCampaignManager
{
	AIAssert( ! [NSThread isMainThread]);
	[[ApplifierImpactProperties sharedInstance] refreshCampaignQueryString];
	[[ApplifierImpactCampaignManager sharedInstance] updateCampaigns];
}

- (void)_startCampaignManager
{
	AIAssert( ! [NSThread isMainThread]);
	
  [[ApplifierImpactCampaignManager sharedInstance] setDelegate:self];
	[self _refreshCampaignManager];
}

- (void)_startAnalyticsUploader
{
	AIAssert( ! [NSThread isMainThread]);
	[[ApplifierImpactAnalyticsUploader sharedInstance] retryFailedUploads];
}

- (BOOL)_adViewCanBeShown
{
  if ([[ApplifierImpactCampaignManager sharedInstance] campaigns] != nil && [[[ApplifierImpactCampaignManager sharedInstance] campaigns] count] > 0 && [[ApplifierImpactCampaignManager sharedInstance] rewardItem] != nil && [[ApplifierImpactViewManager sharedInstance] webViewInitialized])
		return YES;
	else
		return NO;
  
  return NO;
}

- (void)_notifyDelegateOfCampaignAvailability
{
	if ([self _adViewCanBeShown])
	{
		if ([self.delegate respondsToSelector:@selector(applifierImpactCampaignsAreAvailable:)])
			[self.delegate applifierImpactCampaignsAreAvailable:self];
	}
}

- (void)_trackInstall
{
	if ([[ApplifierImpactProperties sharedInstance] impactGameId] == nil)
	{
		AILOG_ERROR(@"Applifier Impact has not been started properly. Launch with -startWithApplifierID: first.");
		return;
	}
	
	dispatch_async(self.queue, ^{
    // FIX
    NSString *queryString = [NSString stringWithFormat:@"%@/install", [[ApplifierImpactProperties sharedInstance] impactGameId]];
    NSString *bodyString = [NSString stringWithFormat:@"deviceId=%@", [ApplifierImpactDevice md5DeviceId]];
		NSDictionary *queryDictionary = @{ kApplifierImpactQueryDictionaryQueryKey : queryString, kApplifierImpactQueryDictionaryBodyKey : bodyString };
    [[ApplifierImpactAnalyticsUploader sharedInstance] performSelector:@selector(sendInstallTrackingCallWithQueryDictionary:) onThread:self.backgroundThread withObject:queryDictionary waitUntilDone:NO];
	});
}

- (void)_refresh
{
	if ([[ApplifierImpactProperties sharedInstance] impactGameId] == nil)
	{
		AILOG_ERROR(@"Applifier Impact has not been started properly. Launch with -startWithApplifierID: first.");
		return;
	}
	
	AILOG_DEBUG(@"");
	
	dispatch_async(self.queue, ^{
		[[ApplifierImpactProperties sharedInstance] refreshCampaignQueryString];
    
		[self performSelector:@selector(_refreshCampaignManager) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
    [[ApplifierImpactAnalyticsUploader sharedInstance] performSelector:@selector(retryFailedUploads) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
	});
}

#pragma mark - Public

- (void)setTestMode:(BOOL)testModeEnabled {
  [[ApplifierImpactProperties sharedInstance] setTestModeEnabled:testModeEnabled];
}

- (void)startWithGameId:(NSString *)gameId
{
  AIAssert([NSThread isMainThread]);
	
	if (gameId == nil || [gameId length] == 0)
	{
		AILOG_ERROR(@"Applifier ID empty or not set.");
		return;
	}
  
	if ([[ApplifierImpactProperties sharedInstance] impactGameId] != nil)
		return;
	  
	[[ApplifierImpactProperties sharedInstance] setImpactGameId:gameId];
	
  self.queue = dispatch_queue_create("com.applifier.impact", NULL);
	
	dispatch_async(self.queue, ^{
		self.backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(_backgroundRunLoop:) object:nil];
		[self.backgroundThread start];

		[self performSelector:@selector(_startCampaignManager) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
		[self performSelector:@selector(_startAnalyticsUploader) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
		
    dispatch_sync(dispatch_get_main_queue(), ^{
      [[ApplifierImpactViewManager sharedInstance] setDelegate:self];
		});
	});
}

- (UIView *)impactAdView
{
	AIAssertV([NSThread mainThread], nil);
	
	if ([self _adViewCanBeShown])
	{
		UIView *adView = [[ApplifierImpactViewManager sharedInstance] adView];
		if (adView != nil)
		{
			if ([self.delegate respondsToSelector:@selector(applifierImpactWillOpen:)])
				[self.delegate applifierImpactWillOpen:self];

			return adView;
		}
	}
	
	return nil;
}

- (BOOL)canShowImpact
{
	AIAssertV([NSThread mainThread], NO);
	return [self _adViewCanBeShown];
}

- (void)stopAll
{
	AIAssert([NSThread isMainThread]);
  [[ApplifierImpactCampaignManager sharedInstance] performSelector:@selector(cancelAllDownloads) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
}

- (void)trackInstall
{
	AIAssert([NSThread isMainThread]);
	[self _trackInstall];
}

- (void)refresh
{
	AIAssert([NSThread isMainThread]);
	
	if ([[ApplifierImpactViewManager sharedInstance] adViewVisible])
		AILOG_DEBUG(@"Ad view visible, not refreshing.");
	else
		[self _refresh];
}

- (void)dealloc
{
  [[ApplifierImpactCampaignManager sharedInstance] setDelegate:nil];
	[[ApplifierImpactViewManager sharedInstance] setDelegate:nil];
  [[ApplifierImpactWebAppController sharedInstance] setDelegate:nil];
	
	dispatch_release(self.queue);
}

#pragma mark - ApplifierImpactCampaignManagerDelegate

- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager updatedWithCampaigns:(NSArray *)campaigns rewardItem:(ApplifierImpactRewardItem *)rewardItem gamerID:(NSString *)gamerID
{
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
	[[ApplifierImpactProperties sharedInstance] setRewardItem:rewardItem];
	[self _notifyDelegateOfCampaignAvailability];
}


//- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager campaignData:(NSDictionary *)data
//{
//	AIAssert([NSThread isMainThread]);

  // If the view manager already has campaign JSON data, it means that
	// campaigns were updated, and we might want to update the webapp.
//	if ([[ApplifierImpactViewManager sharedInstance] campaignJSON] != nil) {
//		self.webViewInitialized = NO;
//	}
  
//  if (self.webViewInitialized == NO) {
//    [[ApplifierImpactViewManager sharedInstance] loadWebView];
//  }
  
  // FIX (SHOULD NOT EVEN SET THE CAMPAIGN DATA)
//  [[ApplifierImpactViewManager sharedInstance] setCampaignJSON:data];
//}

- (void)campaignManagerCampaignDataReceived {
  // FIX (remember the "update campaigns")
  AIAssert([NSThread isMainThread]);
  AILOG_DEBUG(@"CAMPAIGN DATA RECEIVED");
  
  if ([[ApplifierImpactCampaignManager sharedInstance] campaignData] != nil) {
    [[ApplifierImpactWebAppController sharedInstance] setWebViewInitialized:NO];
  }
  
  if (![[ApplifierImpactWebAppController sharedInstance] webViewInitialized]) {
    [[ApplifierImpactViewManager sharedInstance] initWebApp];
  }
}

 
#pragma mark - ApplifierImpactViewManagerDelegate

- (UIViewController *)viewControllerForPresentingViewControllersForViewManager:(ApplifierImpactViewManager *)viewManager
{
	AIAssertV([NSThread isMainThread], nil);
	AILOG_DEBUG(@"");
	
	return [self.delegate viewControllerForPresentingViewControllersForImpact:self];
}

- (void)viewManagerStartedPlayingVideo {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
	if ([self.delegate respondsToSelector:@selector(applifierImpactVideoStarted:)])
		[self.delegate applifierImpactVideoStarted:self];
}

- (void)viewManagerVideoEnded {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
	[self.delegate applifierImpact:self completedVideoWithRewardItemKey:[[ApplifierImpactProperties sharedInstance] rewardItem].key];
}

- (void)viewManagerWillCloseAdView {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
	if ([self.delegate respondsToSelector:@selector(applifierImpactWillClose:)])
		[self.delegate applifierImpactWillClose:self];
}

- (void)viewManagerWebViewInitialized {
	AIAssert([NSThread isMainThread]);	
	AILOG_DEBUG(@"");

	[self _notifyDelegateOfCampaignAvailability];
}

@end