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

#import "ApplifierImpactInitializer/ApplifierImpactDefaultInitializer.h"
#import "ApplifierImpactInitializer/ApplifierImpactNoWebViewInitializer.h"

NSString * const kApplifierImpactRewardItemPictureKey = @"picture";
NSString * const kApplifierImpactRewardItemNameKey = @"name";
NSString * const kApplifierImpactOptionNoOfferscreenKey = @"noOfferScreen";
NSString * const kApplifierImpactOptionOpenAnimatedKey = @"openAnimated";
NSString * const kApplifierImpactOptionGamerSIDKey = @"sid";
NSString * const kApplifierImpactOptionMuteVideoSounds = @"muteVideoSounds";
NSString * const kApplifierImpactOptionVideoUsesDeviceOrientation = @"useDeviceOrientationForVideo";

@interface ApplifierImpact () <ApplifierImpactInitializerDelegate, ApplifierImpactMainViewControllerDelegate>
  @property (nonatomic, strong) ApplifierImpactInitializer *initializer;
  @property (nonatomic, assign) ApplifierImpactMode mode;
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

- (void)setImpactMode:(ApplifierImpactMode)impactMode {
  self.mode = impactMode;
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


#pragma mark - Init delegates

- (void)initComplete {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
  
	[self notifyDelegateOfCampaignAvailability];
}

- (void)initFailed {
	AIAssert([NSThread isMainThread]);
  AILOG_DEBUG(@"");
  if ([self.delegate respondsToSelector:@selector(applifierImpactCampaignsFetchFailed:)])
    [self.delegate applifierImpactCampaignsFetchFailed:self];
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
  if (self.initializer != nil) return false;
  
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter addObserver:self selector:@selector(notificationHandler:) name:UIApplicationWillEnterForegroundNotification object:nil];
  
  [[ApplifierImpactProperties sharedInstance] setCurrentViewController:viewController];
	[[ApplifierImpactProperties sharedInstance] setImpactGameId:gameId];
  [[ApplifierImpactMainViewController sharedInstance] setDelegate:self];
  
  self.initializer = [self selectInitializerFromMode:self.mode];
  
  if (self.initializer != nil) {
    [self.initializer setDelegate:self];
    [self.initializer initImpact:nil];
  }
  else {
    AILOG_DEBUG(@"Initializer is null, cannot start Impact");
    return false;
  }
  
  return true;
}

- (BOOL)canShowCampaigns {
  if ([self canShowImpact] && [[[ApplifierImpactCampaignManager sharedInstance] getViewableCampaigns] count] > 0) {
    return YES;
  }
  
  return NO;
}

- (BOOL)canShowImpact {
	AIAssertV([NSThread mainThread], NO);
  if (![ApplifierImpact isSupported]) return NO;
	return [self impactCanBeShown];
}

- (BOOL)showImpact:(NSDictionary *)options {
  AIAssertV([NSThread mainThread], false);
  if (![ApplifierImpact isSupported]) return false;
  if (![self canShowImpact]) return false;
  
  ApplifierImpactViewStateType state = kApplifierImpactViewStateTypeOfferScreen;
  [[ApplifierImpactShowOptionsParser sharedInstance] parseOptions:options];
  
  // If Impact is in "No WebView" -mode, always skip offerscreen
  if (self.mode == kApplifierImpactModeNoWebView)
    [[ApplifierImpactShowOptionsParser sharedInstance] setNoOfferScreen:true];
  
  if ([[ApplifierImpactShowOptionsParser sharedInstance] noOfferScreen]) {
    if (![self canShowCampaigns]) return false;
    state = kApplifierImpactViewStateTypeVideoPlayer;
  }
  
  [[ApplifierImpactMainViewController sharedInstance] openImpact:[[ApplifierImpactShowOptionsParser sharedInstance] openAnimated] inState:state withOptions:options];
  
  return true;
}

- (BOOL)showImpact {
  return [self showImpact:nil];
}

- (BOOL)hasMultipleRewardItems {
  if ([[ApplifierImpactCampaignManager sharedInstance] rewardItems] != nil && [[[ApplifierImpactCampaignManager sharedInstance] rewardItems] count] > 0) {
    return true;
  }
  
  return false;
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
  
  return false;
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
  AIAssertV([NSThread mainThread], false);
  if (![ApplifierImpact isSupported]) false;
  return [[ApplifierImpactMainViewController sharedInstance] closeImpact:YES withAnimations:YES withOptions:nil];
}

- (void)setViewController:(UIViewController *)viewController showImmediatelyInNewController:(BOOL)applyImpact {
	AIAssert([NSThread isMainThread]);
  if (![ApplifierImpact isSupported]) return;
  
  BOOL openAnimated = false;
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
  if (self.initializer != nil) {
    [self.initializer deInitialize];
  }
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [[ApplifierImpactCampaignManager sharedInstance] setDelegate:nil];
  [[ApplifierImpactMainViewController sharedInstance] setDelegate:nil];
  
  if (self.initializer != nil) {
    [self.initializer setDelegate:nil];
  }
}


#pragma mark - Private uncategorized

- (void)notificationHandler:(id)notification {
  NSString *name = [notification name];
  AILOG_DEBUG(@"Got notification from notificationCenter: %@", name);
  
  if ([name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
    AIAssert([NSThread isMainThread]);
    
    if ([[ApplifierImpactMainViewController sharedInstance] mainControllerVisible]) {
      AILOG_DEBUG(@"Ad view visible, not refreshing.");
    }
    else {
      [self refreshImpact];
    }
  }
}

- (BOOL)impactCanBeShown {
  if ([[ApplifierImpactCampaignManager sharedInstance] campaigns] != nil && [[[ApplifierImpactCampaignManager sharedInstance] campaigns] count] > 0 && [[ApplifierImpactCampaignManager sharedInstance] getCurrentRewardItem] != nil && self.initializer != nil && [self.initializer initWasSuccessfull]) {
		return true;
  }
  
  return false;
}

- (ApplifierImpactInitializer *)selectInitializerFromMode:(ApplifierImpactMode)mode {
  switch (mode) {
    case kApplifierImpactModeDefault:
      return [[ApplifierImpactDefaultInitializer alloc] init];
    case kApplifierImpactModeNoWebView:
      return [[ApplifierImpactNoWebViewInitializer alloc] init];
  }
  
  return nil;
}

#pragma mark - Private data refreshing

- (void)refreshImpact {
	if ([[ApplifierImpactProperties sharedInstance] impactGameId] == nil) {
		AILOG_ERROR(@"Applifier Impact has not been started properly. Launch with -startWithApplifierID: first.");
		return;
	}
	
  if (self.initializer != nil) {
    [self.initializer reInitialize];
  }
}


#pragma mark - ApplifierImpactViewManagerDelegate

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

- (void)notifyDelegateOfCampaignAvailability {
	if ([self impactCanBeShown]) {
		if ([self.delegate respondsToSelector:@selector(applifierImpactCampaignsAreAvailable:)])
			[self.delegate applifierImpactCampaignsAreAvailable:self];
	}
}

@end