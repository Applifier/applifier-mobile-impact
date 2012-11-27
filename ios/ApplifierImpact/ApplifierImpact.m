//
//  ApplifierImpact.m
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpact.h"
#import "ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "ApplifierImpactCampaign/ApplifierImpactRewardItem.h"
#import "ApplifierImpactOpenUDID/ApplifierImpactOpenUDID.h"
#import "ApplifierImpactData/ApplifierImpactAnalyticsUploader.h"
#import "ApplifierImpactDevice/ApplifierImpactDevice.h"
#import "ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "ApplifierImpactMainViewController.h"

@interface ApplifierImpact () <ApplifierImpactCampaignManagerDelegate, UIWebViewDelegate, UIScrollViewDelegate, ApplifierImpactMainViewControllerDelegate>
@property (nonatomic, strong) NSThread *backgroundThread;
@property (nonatomic, assign) dispatch_queue_t queue;
@end

@implementation ApplifierImpact


#pragma mark - Static accessors

+ (BOOL)isSupported {
  if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_5_0) {
    return NO;
  }
  
  return YES;
}

static ApplifierImpact *sharedImpact = nil;

+ (ApplifierImpact *)sharedInstance {
	@synchronized(self) {
		if (sharedImpact == nil) {
      sharedImpact = [[ApplifierImpact alloc] init];
		}
	}
	
	return sharedImpact;
}


#pragma mark - Public

- (void)setTestMode:(BOOL)testModeEnabled {
  if (![ApplifierImpact isSupported]) return;
  [[ApplifierImpactProperties sharedInstance] setTestModeEnabled:testModeEnabled];
}

- (void)startWithGameId:(NSString *)gameId {
  if (![ApplifierImpact isSupported]) return;
  [self startWithGameId:gameId andViewController:nil];
}

- (void)startWithGameId:(NSString *)gameId andViewController:(UIViewController *)viewController {
  AIAssert([NSThread isMainThread]);
  AILOG_DEBUG(@"");
  if (![ApplifierImpact isSupported]) return;
  if ([[ApplifierImpactProperties sharedInstance] impactGameId]) return;
	if (gameId == nil || [gameId length] == 0) return;
  
  [[ApplifierImpactProperties sharedInstance] setCurrentViewController:viewController];
  
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter addObserver:self selector:@selector(_notificationHandler:) name:UIApplicationWillEnterForegroundNotification object:nil];
	[[ApplifierImpactProperties sharedInstance] setImpactGameId:gameId];
	
  self.queue = dispatch_queue_create("com.applifier.impact", NULL);
	 
	dispatch_async(self.queue, ^{
    self.backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(_backgroundRunLoop:) object:nil];
		[self.backgroundThread start];

		[self performSelector:@selector(_startCampaignManager) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
		[self performSelector:@selector(_startAnalyticsUploader) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
		
    dispatch_sync(dispatch_get_main_queue(), ^{
      [[ApplifierImpactMainViewController sharedInstance] setDelegate:self];
		});
	});
}

- (BOOL)canShowImpact {
	AIAssertV([NSThread mainThread], NO);
  if (![ApplifierImpact isSupported]) return NO;
	return [self _adViewCanBeShown];
}

- (BOOL)showImpact {
  AIAssertV([NSThread mainThread], NO);
  if (![ApplifierImpact isSupported]) return NO;
  [[ApplifierImpactMainViewController sharedInstance] openImpact];
  return YES;
}

- (BOOL)hideImpact {
  AIAssertV([NSThread mainThread], NO);
  if (![ApplifierImpact isSupported]) NO;
  return [[ApplifierImpactMainViewController sharedInstance] closeImpact];
}

- (void)setViewController:(UIViewController *)viewController showImmediatelyInNewController:(BOOL)applyImpact {
	AIAssert([NSThread isMainThread]);
  if (![ApplifierImpact isSupported]) return;
  [[ApplifierImpactMainViewController sharedInstance] closeImpact];
  [[ApplifierImpactProperties sharedInstance] setCurrentViewController:viewController];
  
  if (applyImpact) {
    [[ApplifierImpactMainViewController sharedInstance] openImpact];
  }
}

- (void)stopAll{
	AIAssert([NSThread isMainThread]);
  if (![ApplifierImpact isSupported]) return;
  [[ApplifierImpactCampaignManager sharedInstance] performSelector:@selector(cancelAllDownloads) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
}

- (void)trackInstall{
	AIAssert([NSThread isMainThread]);
  if (![ApplifierImpact isSupported]) return;
	[[ApplifierImpactAnalyticsUploader sharedInstance] sendManualInstallTrackingCall];
}

- (void)dealloc {
  [[ApplifierImpactCampaignManager sharedInstance] setDelegate:nil];
  [[ApplifierImpactMainViewController sharedInstance] setDelegate:nil];
  [[ApplifierImpactWebAppController sharedInstance] setDelegate:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	dispatch_release(self.queue);
}


#pragma mark - Private uncategorized

- (void)_notificationHandler: (id) notification {
  NSString *name = [notification name];
  AILOG_DEBUG(@"Got notification from notificationCenter: %@", name);
  
  if ([name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
    AIAssert([NSThread isMainThread]);
    
    if ([[ApplifierImpactMainViewController sharedInstance] mainControllerVisible]) {
      AILOG_DEBUG(@"Ad view visible, not refreshing.");
    }
    else {
      [self _refresh];
    }
  }
}

- (void)_backgroundRunLoop:(id)dummy {
	@autoreleasepool {
		NSPort *port = [[NSPort alloc] init];
		[port scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		while([[NSThread currentThread] isCancelled] == NO) {
			@autoreleasepool {
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
			}
		}
	}
}

- (BOOL)_adViewCanBeShown {
  if ([[ApplifierImpactCampaignManager sharedInstance] campaigns] != nil && [[[ApplifierImpactCampaignManager sharedInstance] campaigns] count] > 0 && [[ApplifierImpactCampaignManager sharedInstance] rewardItem] != nil && [[ApplifierImpactWebAppController sharedInstance] webViewInitialized])
		return YES;
	else
		return NO;
  
  return NO;
}


#pragma mark - Private initalization

- (void)_startCampaignManager {
	AIAssert(![NSThread isMainThread]);
	AILOG_DEBUG(@"");
  [[ApplifierImpactCampaignManager sharedInstance] setDelegate:self];
	[self _refreshCampaignManager];
}

- (void)_startAnalyticsUploader {
	AIAssert(![NSThread isMainThread]);
	AILOG_DEBUG(@"");
	[[ApplifierImpactAnalyticsUploader sharedInstance] retryFailedUploads];
}


#pragma mark - Private data refreshing

- (void)_refresh {
	if ([[ApplifierImpactProperties sharedInstance] impactGameId] == nil) {
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

- (void)_refreshCampaignManager {
	AIAssert(![NSThread isMainThread]);
	[[ApplifierImpactProperties sharedInstance] refreshCampaignQueryString];
	[[ApplifierImpactCampaignManager sharedInstance] updateCampaigns];
}


#pragma mark - ApplifierImpactCampaignManagerDelegate

- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager updatedWithCampaigns:(NSArray *)campaigns rewardItem:(ApplifierImpactRewardItem *)rewardItem gamerID:(NSString *)gamerID {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	[self _notifyDelegateOfCampaignAvailability];
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

 
#pragma mark - ApplifierImpactViewManagerDelegate

- (void)mainControllerStartedPlayingVideo {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
	if ([self.delegate respondsToSelector:@selector(applifierImpactVideoStarted:)])
		[self.delegate applifierImpactVideoStarted:self];
}

- (void)mainControllerVideoEnded {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
	[self.delegate applifierImpact:self completedVideoWithRewardItemKey:[[ApplifierImpactCampaignManager sharedInstance] rewardItem].key];
}

- (void)mainControllerWillCloseAdView {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
	if ([self.delegate respondsToSelector:@selector(applifierImpactWillClose:)])
		[self.delegate applifierImpactWillClose:self];
}

- (void)mainControllerWebViewInitialized {
	AIAssert([NSThread isMainThread]);	
	AILOG_DEBUG(@"");

	[self _notifyDelegateOfCampaignAvailability];
}


#pragma mark - ApplifierImpactDelegate calling methods

- (void)_notifyDelegateOfCampaignAvailability {
	if ([self _adViewCanBeShown]) {
		if ([self.delegate respondsToSelector:@selector(applifierImpactCampaignsAreAvailable:)])
			[self.delegate applifierImpactCampaignsAreAvailable:self];
	}
}

@end