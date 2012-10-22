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

NSString * const kApplifierImpactVersion = @"1.0";

@interface ApplifierImpactiOS4 () <ApplifierImpactCampaignManagerDelegate, UIWebViewDelegate, UIScrollViewDelegate, ApplifierImpactViewManagerDelegate>
@property (nonatomic, strong) ApplifierImpactCampaignManager *campaignManager;
@property (nonatomic, strong) ApplifierImpactAnalyticsUploader *analyticsUploader;
@property (nonatomic, strong) ApplifierImpactRewardItem *rewardItem;
@property (nonatomic, strong) NSString *applifierID;
@property (nonatomic, strong) NSString *campaignJSON;
@property (nonatomic, strong) NSString *machineName;
@property (nonatomic, strong) NSString *md5AdvertisingIdentifier;
@property (nonatomic, strong) NSString *md5MACAddress;
@property (nonatomic, strong) NSString *md5OpenUDID;
@property (nonatomic, strong) NSString *campaignQueryString;
@property (nonatomic, strong) NSString *gamerID;
@property (nonatomic, strong) NSString *connectionType;
@property (nonatomic, strong) NSThread *backgroundThread;
@property (nonatomic, strong) NSArray *campaigns;
@property (nonatomic, assign) BOOL webViewInitialized;
@property (nonatomic, assign) dispatch_queue_t queue;
@end

@implementation ApplifierImpactiOS4

#pragma mark - Private

- (NSString *)_queryString
{
	NSString *advertisingIdentifier = self.md5AdvertisingIdentifier != nil ? self.md5AdvertisingIdentifier : @"";
  NSString *deviceId = self.md5AdvertisingIdentifier != nil ? self.md5AdvertisingIdentifier : self.md5OpenUDID;

	NSString *queryParams = [NSString stringWithFormat:@"?openUdid=%@&macAddress=%@&iosVersion=%@&device=%@&sdkVersion=%@&gameId=%@&type=ios&connection=%@", self.md5OpenUDID, self.md5MACAddress, [[UIDevice currentDevice] systemVersion], self.machineName, kApplifierImpactVersion, self.applifierID, self.connectionType];

  if (self.md5AdvertisingIdentifier != nil)
    queryParams = [NSString stringWithFormat:@"%@&advertisingTrackingId=%@", queryParams, advertisingIdentifier];

  queryParams = [NSString stringWithFormat:@"%@&deviceId=%@&platform=%@", queryParams, deviceId, @"ios"];

  if ([ApplifierImpactDevice canUseTracking])
    queryParams = [NSString stringWithFormat:@"%@&softwareVersion=%@&hardwareVersion=%@&deviceType=%@&apiVersion=%@&connectionType=%@", queryParams, [[UIDevice currentDevice] systemVersion], @"unknown", self.machineName, kApplifierImpactVersion, self.connectionType];

  return queryParams;
}

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
	AIAssert(self.campaignManager != nil);
	
	self.campaignManager.queryString = self.campaignQueryString;
	[self.campaignManager updateCampaigns];
}

- (void)_startCampaignManager
{
	AIAssert( ! [NSThread isMainThread]);
	
	self.campaignManager = [[ApplifierImpactCampaignManager alloc] init];
	self.campaignManager.delegate = self;
	[self _refreshCampaignManager];
}

- (void)_startAnalyticsUploader
{
	AIAssert( ! [NSThread isMainThread]);
	
	self.analyticsUploader = [[ApplifierImpactAnalyticsUploader alloc] init];
	[self.analyticsUploader retryFailedUploads];
}

- (void)_logVideoAnalyticsWithPosition:(VideoAnalyticsPosition)videoPosition campaign:(ApplifierImpactCampaign *)campaign
{
	if (campaign == nil)
	{
		AILOG_DEBUG(@"Campaign is nil.");
		return;
	}
	
	dispatch_async(self.queue, ^{
		NSString *positionString = nil;
		NSString *trackingString = nil;
		if (videoPosition == kVideoAnalyticsPositionStart)
		{
			positionString = @"video_start";
			trackingString = @"start";
		}
		else if (videoPosition == kVideoAnalyticsPositionFirstQuartile)
			positionString = @"first_quartile";
		else if (videoPosition == kVideoAnalyticsPositionMidPoint)
			positionString = @"mid_point";
		else if (videoPosition == kVideoAnalyticsPositionThirdQuartile)
			positionString = @"third_quartile";
		else if (videoPosition == kVideoAnalyticsPositionEnd)
		{
			positionString = @"video_end";
			trackingString = @"view";
		}
		
		NSString *query = [NSString stringWithFormat:@"applicationId=%@&type=%@&trackingId=%@&providerId=%@", self.applifierID, positionString, self.gamerID, campaign.id];
		
		[self.analyticsUploader performSelector:@selector(sendViewReportWithQueryString:) onThread:self.backgroundThread withObject:query waitUntilDone:NO];
		
		if (trackingString != nil)
		{
			NSString *trackingQuery = [NSString stringWithFormat:@"%@/%@/%@?gameId=%@", self.gamerID, trackingString, campaign.id, self.applifierID];
			[self.analyticsUploader performSelector:@selector(sendTrackingCallWithQueryString:) onThread:self.backgroundThread withObject:trackingQuery waitUntilDone:NO];
		}
	});
}

- (BOOL)_adViewCanBeShown
{
	if (self.campaigns != nil && [self.campaigns count] > 0 && self.rewardItem != nil && self.webViewInitialized)
		return YES;
	else
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
	if (self.applifierID == nil)
	{
		AILOG_ERROR(@"Applifier Impact has not been started properly. Launch with -startWithApplifierID: first.");
		return;
	}
	
	dispatch_async(self.queue, ^{
		NSString *queryString = [NSString stringWithFormat:@"%@/install", self.applifierID];
		NSString *bodyString = [NSString stringWithFormat:@"openUdid=%@&macAddress=%@", self.md5OpenUDID, self.md5MACAddress];
		NSDictionary *queryDictionary = @{ kApplifierImpactQueryDictionaryQueryKey : queryString, kApplifierImpactQueryDictionaryBodyKey : bodyString };
		
		[self.analyticsUploader performSelector:@selector(sendInstallTrackingCallWithQueryDictionary:) onThread:self.backgroundThread withObject:queryDictionary waitUntilDone:NO];
	});
}

- (void)_refresh
{
	if (self.applifierID == nil)
	{
		AILOG_ERROR(@"Applifier Impact has not been started properly. Launch with -startWithApplifierID: first.");
		return;
	}
	
	AILOG_DEBUG(@"");
	
	dispatch_async(self.queue, ^{
		self.connectionType = [ApplifierImpactDevice currentConnectionType];
		self.campaignQueryString = [self _queryString];
		
		[self performSelector:@selector(_refreshCampaignManager) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
		[self.analyticsUploader performSelector:@selector(retryFailedUploads) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
	});
}

#pragma mark - Public

- (void)startWithApplifierID:(NSString *)applifierID
{
	AIAssert([NSThread isMainThread]);
	
	if (applifierID == nil || [applifierID length] == 0)
	{
		AILOG_ERROR(@"Applifier ID empty or not set.");
		return;
	}
	
	if (self.applifierID != nil)
		return;
	
	self.applifierID = applifierID;
	self.queue = dispatch_queue_create("com.applifier.impact", NULL);
	
	dispatch_async(self.queue, ^{
		self.machineName = [ApplifierImpactDevice analyticsMachineName];
		self.md5AdvertisingIdentifier = [ApplifierImpactDevice md5AdvertisingIdentifierString];
		self.md5MACAddress = [ApplifierImpactDevice md5MACAddressString];
		self.md5OpenUDID = [ApplifierImpactDevice md5OpenUDIDString];
		self.connectionType = [ApplifierImpactDevice currentConnectionType];
		self.campaignQueryString = [self _queryString];
		
		self.backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(_backgroundRunLoop:) object:nil];
		[self.backgroundThread start];

		[self performSelector:@selector(_startCampaignManager) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
		[self performSelector:@selector(_startAnalyticsUploader) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
		
    dispatch_sync(dispatch_get_main_queue(), ^{
      [[ApplifierImpactViewManager sharedInstance] setDelegate:self];
      [[ApplifierImpactViewManager sharedInstance] setMachineName:self.machineName];
      [[ApplifierImpactViewManager sharedInstance] setMd5AdvertisingIdentifier:self.md5AdvertisingIdentifier];
      [[ApplifierImpactViewManager sharedInstance] setMd5MACAddress:self.md5MACAddress];
      [[ApplifierImpactViewManager sharedInstance] setMd5OpenUDID:self.md5OpenUDID];
      [[ApplifierImpactViewManager sharedInstance] loadWebView];
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
	
	[self.campaignManager performSelector:@selector(cancelAllDownloads) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
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
	self.campaignManager.delegate = nil;
	[[ApplifierImpactViewManager sharedInstance] setDelegate:nil];
	
	dispatch_release(self.queue);
}

#pragma mark - ApplifierImpactCampaignManagerDelegate

- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager updatedWithCampaigns:(NSArray *)campaigns rewardItem:(ApplifierImpactRewardItem *)rewardItem gamerID:(NSString *)gamerID
{
	AIAssert([NSThread isMainThread]);
	
	AILOG_DEBUG(@"");
	
	self.campaigns = campaigns;
	self.rewardItem = rewardItem;
	self.gamerID = gamerID;
	
	[self _notifyDelegateOfCampaignAvailability];
}

- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager updatedJSON:(NSString *)json
{
	AIAssert([NSThread isMainThread]);
	
  // If the view manager already has campaign JSON data, it means that
	// campaigns were updated, and we might want to update the webapp.
	if ([[ApplifierImpactViewManager sharedInstance] campaignJSON] != nil)
	{
		self.webViewInitialized = NO;
    [[ApplifierImpactViewManager sharedInstance] loadWebView];
	}
  
  [[ApplifierImpactViewManager sharedInstance] setCampaignJSON:json];
}

#pragma mark - ApplifierImpactViewManagerDelegate

-(ApplifierImpactCampaign *)viewManager:(ApplifierImpactViewManager *)viewManager campaignWithID:(NSString *)campaignID
{
	AIAssertV([NSThread isMainThread], nil);
	
	ApplifierImpactCampaign *foundCampaign = nil;
	
	for (ApplifierImpactCampaign *campaign in self.campaigns)
	{
		if ([campaign.id isEqualToString:campaignID])
		{
			foundCampaign = campaign;
			break;
		}
	}
	
	AILOG_DEBUG(@"");
	
	return foundCampaign;
}

-(NSURL *)viewManager:(ApplifierImpactViewManager *)viewManager videoURLForCampaign:(ApplifierImpactCampaign *)campaign
{
	AIAssertV([NSThread isMainThread], nil);
	AILOG_DEBUG(@"");
	
	return [self.campaignManager videoURLForCampaign:campaign];
}

- (void)viewManagerStartedPlayingVideo:(ApplifierImpactViewManager *)viewManager
{
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
	if ([self.delegate respondsToSelector:@selector(applifierImpactVideoStarted:)])
		[self.delegate applifierImpactVideoStarted:self];
}

- (void)viewManagerVideoEnded:(ApplifierImpactViewManager *)viewManager
{
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
	[self.delegate applifierImpact:self completedVideoWithRewardItemKey:self.rewardItem.key];
}

- (void)viewManager:(ApplifierImpactViewManager *)viewManager loggedVideoPosition:(VideoAnalyticsPosition)videoPosition campaign:(ApplifierImpactCampaign *)campaign
{
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
	[self _logVideoAnalyticsWithPosition:videoPosition campaign:campaign];
}

- (UIViewController *)viewControllerForPresentingViewControllersForViewManager:(ApplifierImpactViewManager *)viewManager
{
	AIAssertV([NSThread isMainThread], nil);
	AILOG_DEBUG(@"");
	
	return [self.delegate viewControllerForPresentingViewControllersForImpact:self];
}

- (void)viewManagerWillCloseAdView:(ApplifierImpactViewManager *)viewManager
{
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
	if ([self.delegate respondsToSelector:@selector(applifierImpactWillClose:)])
		[self.delegate applifierImpactWillClose:self];
}

- (void)viewManagerWebViewInitialized:(ApplifierImpactViewManager *)viewManager
{
	AIAssert([NSThread isMainThread]);	
	AILOG_DEBUG(@"");
	
	self.webViewInitialized = YES;
	
	[self _notifyDelegateOfCampaignAvailability];
}

@end