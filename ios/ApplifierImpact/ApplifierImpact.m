//
//  ApplifierImpact.m
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpact.h"
#import "ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "ApplifierImpactCampaign/ApplifierImpactRewardItem.h"
#import "ApplifierImpactData/ApplifierImpactAnalyticsUploader.h"
#import "ApplifierImpactDevice/ApplifierImpactDevice.h"
#import "ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "ApplifierImpactView/ApplifierImpactMainViewController.h"
#import "ApplifierImpactProperties/ApplifierImpactShowOptionsParser.h"

NSString * const kApplifierImpactRewardItemPictureKey = @"picture";
NSString * const kApplifierImpactRewardItemNameKey = @"name";
NSString * const kApplifierImpactOptionNoOfferscreenKey = @"noOfferScreen";
NSString * const kApplifierImpactOptionOpenAnimatedKey = @"openAnimated";
NSString * const kApplifierImpactOptionGamerSIDKey = @"sid";

@interface ApplifierImpact () <ApplifierImpactCampaignManagerDelegate, UIWebViewDelegate, UIScrollViewDelegate, ApplifierImpactMainViewControllerDelegate>
@property (nonatomic, strong) NSThread *backgroundThread;
@property (nonatomic, assign) dispatch_queue_t queue;
@property (nonatomic, assign) Boolean debug;
@end

@implementation ApplifierImpact


#pragma mark - Static accessors

+ (BOOL)isSupported {
  if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_5_0) {
    return NO;
  }
  
  return YES;
}

+ (NSString *)getSDKVersion {
  return [[ApplifierImpactProperties sharedInstance] impactVersion];
}

- (void)setDebugMode:(BOOL)debugMode {
  self.debug = debugMode;
}

- (BOOL)isDebugMode {
  return self.debug;
}

static ApplifierImpact *sharedImpact = nil;

+ (ApplifierImpact *)sharedInstance {
	@synchronized(self) {
		if (sharedImpact == nil) {
      sharedImpact = [[ApplifierImpact alloc] init];
      sharedImpact.debug = NO;
		}
	}
	
	return sharedImpact;
}


#pragma mark - Public

- (void)setTestMode:(BOOL)testModeEnabled {
  if (![ApplifierImpact isSupported]) return;
  [[ApplifierImpactProperties sharedInstance] setTestModeEnabled:testModeEnabled];
}

- (BOOL)startWithGameId:(NSString *)gameId {
  if (![ApplifierImpact isSupported]) return false;
  return [self startWithGameId:gameId andViewController:nil];
}

- (BOOL)startWithGameId:(NSString *)gameId andViewController:(UIViewController *)viewController {
  AILOG_DEBUG(@"");
  if (![ApplifierImpact isSupported]) return false;
  if ([[ApplifierImpactProperties sharedInstance] impactGameId] != nil) return false;
	if (gameId == nil || [gameId length] == 0) return false;
  
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
  
  return true;
}

- (BOOL)canShowAds {
  if ([self canShowImpact] && [[[ApplifierImpactCampaignManager sharedInstance] getViewableCampaigns] count] > 0) {
    return YES;
  }
  
  return NO;
}

- (BOOL)canShowImpact {
	AIAssertV([NSThread mainThread], NO);
  if (![ApplifierImpact isSupported]) return NO;
	return [self _adViewCanBeShown];
}

- (BOOL)showImpact:(NSDictionary *)options {
  AIAssertV([NSThread mainThread], NO);
  if (![ApplifierImpact isSupported]) return NO;
  if (![self canShowImpact]) return NO;
  
  ApplifierImpactViewStateType state = kApplifierImpactViewStateTypeOfferScreen;
  [[ApplifierImpactShowOptionsParser sharedInstance] parseOptions:options];
  
  if ([[ApplifierImpactShowOptionsParser sharedInstance] noOfferScreen]) {
    if (![self canShowAds]) return NO;
    state = kApplifierImpactViewStateTypeVideoPlayer;
  }
  
  [[ApplifierImpactMainViewController sharedInstance] openImpact:[[ApplifierImpactShowOptionsParser sharedInstance] openAnimated] inState:state withOptions:options];
  
  return YES;
}

- (BOOL)showImpact {
  AIAssertV([NSThread mainThread], NO);
  if (![ApplifierImpact isSupported]) return NO;
  if (![self canShowImpact]) return NO;
  [[ApplifierImpactMainViewController sharedInstance] openImpact:YES inState:kApplifierImpactViewStateTypeOfferScreen withOptions:nil];
  return YES;
}

- (BOOL)hasMultipleRewardItems {
  if ([[ApplifierImpactCampaignManager sharedInstance] rewardItems] != nil && [[[ApplifierImpactCampaignManager sharedInstance] rewardItems] count] > 0) {
    return YES;
  }
  
  return NO;
}

- (NSArray *)getRewardItemKeys {
  return [[ApplifierImpactCampaignManager sharedInstance] rewardItemKeys];
}

- (NSString *)getDefaultRewardItemKey {
  return [[ApplifierImpactCampaignManager sharedInstance] defaultRewardItem].key;
}

- (NSString *)getCurrentRewardItemKey {
  return [[ApplifierImpactCampaignManager sharedInstance] currentRewardItemKey];
}

- (BOOL)setRewardItemKey:(NSString *)rewardItemKey {
  if (![[ApplifierImpactMainViewController sharedInstance] mainControllerVisible]) {
    return [[ApplifierImpactCampaignManager sharedInstance] setSelectedRewardItemKey:rewardItemKey];
  }
  
  return NO;
}

- (void)setDefaultRewardItemAsRewardItem {
  [[ApplifierImpactCampaignManager sharedInstance] setSelectedRewardItemKey:[self getDefaultRewardItemKey]];
}

- (NSDictionary *)getRewardItemDetailsWithKey:(NSString *)rewardItemKey {
  if ([self hasMultipleRewardItems] && rewardItemKey != nil) {
    return [[ApplifierImpactCampaignManager sharedInstance] getPublicRewardItemDetails:rewardItemKey];
  }
  
  return nil;
}


- (BOOL)hideImpact {
  AIAssertV([NSThread mainThread], NO);
  if (![ApplifierImpact isSupported]) NO;
  return [[ApplifierImpactMainViewController sharedInstance] closeImpact:YES withAnimations:YES withOptions:nil];
}

- (void)setViewController:(UIViewController *)viewController showImmediatelyInNewController:(BOOL)applyImpact {
	AIAssert([NSThread isMainThread]);
  if (![ApplifierImpact isSupported]) return;
  
  BOOL openAnimated = NO;
  if ([[ApplifierImpactProperties sharedInstance] currentViewController] == nil) {
    openAnimated = YES;
  }
  
  [[ApplifierImpactMainViewController sharedInstance] closeImpact:YES withAnimations:NO withOptions:nil];
  [[ApplifierImpactProperties sharedInstance] setCurrentViewController:viewController];
  
  if (applyImpact && [self canShowImpact]) {
    [[ApplifierImpactMainViewController sharedInstance] openImpact:openAnimated inState:kApplifierImpactViewStateTypeOfferScreen withOptions:nil];
  }
}

- (void)stopAll{
	AIAssert([NSThread isMainThread]);
  if (![ApplifierImpact isSupported]) return;
  [[ApplifierImpactCampaignManager sharedInstance] performSelector:@selector(cancelAllDownloads) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
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
  if ([[ApplifierImpactCampaignManager sharedInstance] campaigns] != nil && [[[ApplifierImpactCampaignManager sharedInstance] campaigns] count] > 0 && [[ApplifierImpactCampaignManager sharedInstance] getCurrentRewardItem] != nil && [[ApplifierImpactWebAppController sharedInstance] webViewInitialized])
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

- (void)campaignManagerCampaignDataFailed {
  AIAssert([NSThread isMainThread]);
  AILOG_DEBUG(@"Campaign data failed.");
  
  if ([self.delegate respondsToSelector:@selector(applifierImpactCampaignsFetchFailed:)])
		[self.delegate applifierImpactCampaignsFetchFailed:self];
}


#pragma mark - ApplifierImpactViewManagerDelegate

- (void)mainControllerWebViewInitialized {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
  
	[self _notifyDelegateOfCampaignAvailability];
}

- (void)mainControllerWillClose {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
	if ([self.delegate respondsToSelector:@selector(applifierImpactWillClose:)])
		[self.delegate applifierImpactWillClose:self];
}

- (void)mainControllerDidClose {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
  
  if ([self.delegate respondsToSelector:@selector(applifierImpactDidClose:)])
		[self.delegate applifierImpactDidClose:self];
}

- (void)mainControllerWillOpen {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
  
  if ([self.delegate respondsToSelector:@selector(applifierImpactWillOpen:)])
		[self.delegate applifierImpactWillOpen:self];
}

- (void)mainControllerDidOpen {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
  
  if ([self.delegate respondsToSelector:@selector(applifierImpactDidOpen:)])
		[self.delegate applifierImpactDidOpen:self];
}

- (void)mainControllerStartedPlayingVideo {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
	if ([self.delegate respondsToSelector:@selector(applifierImpactVideoStarted:)])
		[self.delegate applifierImpactVideoStarted:self];
}

- (void)mainControllerVideoEnded {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
  if (![[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].viewed) {
    [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].viewed = YES;
    [self.delegate applifierImpact:self completedVideoWithRewardItemKey:[[ApplifierImpactCampaignManager sharedInstance] getCurrentRewardItem].key];
  }
}

- (void)mainControllerWillLeaveApplication {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
  
  if ([self.delegate respondsToSelector:@selector(applifierImpactWillLeaveApplication:)])
		[self.delegate applifierImpactWillLeaveApplication:self];
}

#pragma mark - ApplifierImpactDelegate calling methods

- (void)_notifyDelegateOfCampaignAvailability {
	if ([self _adViewCanBeShown]) {
		if ([self.delegate respondsToSelector:@selector(applifierImpactCampaignsAreAvailable:)])
			[self.delegate applifierImpactCampaignsAreAvailable:self];
	}
}

@end