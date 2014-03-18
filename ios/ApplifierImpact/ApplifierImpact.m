//
//  ApplifierImpact.m
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpact.h"
#import "ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "ApplifierImpactItem/ApplifierImpactRewardItem.h"
#import "ApplifierImpactData/ApplifierImpactAnalyticsUploader.h"
#import "ApplifierImpactDevice/ApplifierImpactDevice.h"
#import "ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "ApplifierImpactView/ApplifierImpactMainViewController.h"
#import "ApplifierImpactZone/ApplifierImpactZoneManager.h"
#import "ApplifierImpactZone/ApplifierImpactIncentivizedZone.h"

#import "ApplifierImpactInitializer/ApplifierImpactDefaultInitializer.h"

NSString * const kApplifierImpactRewardItemPictureKey = @"picture";
NSString * const kApplifierImpactRewardItemNameKey = @"name";

NSString * const kApplifierImpactOptionNoOfferscreenKey = @"noOfferScreen";
NSString * const kApplifierImpactOptionOpenAnimatedKey = @"openAnimated";
NSString * const kApplifierImpactOptionGamerSIDKey = @"sid";
NSString * const kApplifierImpactOptionMuteVideoSounds = @"muteVideoSounds";
NSString * const kApplifierImpactOptionVideoUsesDeviceOrientation = @"useDeviceOrientationForVideo";

@interface ApplifierImpact () <ApplifierImpactInitializerDelegate, ApplifierImpactMainViewControllerDelegate>
  @property (nonatomic, strong) ApplifierImpactInitializer *initializer;
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

- (void)setTestDeveloperId:(NSString *)developerId {
  [[ApplifierImpactProperties sharedInstance] setDeveloperId:developerId];
}

- (void)setTestOptionsId:(NSString *)optionsId {
  [[ApplifierImpactProperties sharedInstance] setOptionsId:optionsId];
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


#pragma mark - Init delegates

- (void)initComplete {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
  
	[self notifyDelegateOfCampaignAvailability];
}

- (void)initFailed {
	AIAssert([NSThread isMainThread]);
  AILOG_DEBUG(@"");
  if (self.delegate != nil && [self.delegate respondsToSelector:@selector(applifierImpactCampaignsFetchFailed:)])
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
  
  self.initializer = [[ApplifierImpactDefaultInitializer alloc] init];
  
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

- (BOOL)setZone:(NSString *)zoneId {
  if (![[ApplifierImpactMainViewController sharedInstance] mainControllerVisible]) {
    return [[ApplifierImpactZoneManager sharedInstance] setCurrentZone:zoneId];
  }
  return FALSE;
}

- (BOOL)setZone:(NSString *)zoneId withRewardItem:(NSString *)rewardItemKey {
  if([self setZone:zoneId]) {
    return [self setRewardItemKey:rewardItemKey];
  }
  return FALSE;
}

- (BOOL)showImpact:(NSDictionary *)options {
  AIAssertV([NSThread mainThread], false);
  if (![ApplifierImpact isSupported]) return false;
  if (![self canShowImpact]) return false;
  
  ApplifierImpactViewStateType state = kApplifierImpactViewStateTypeOfferScreen;
  
  id currentZone = [[ApplifierImpactZoneManager sharedInstance] getCurrentZone];
  if(currentZone) {
    [currentZone mergeOptions:options];
    
    if ([currentZone noOfferScreen]) {
      if (![self canShowCampaigns]) return false;
      state = kApplifierImpactViewStateTypeVideoPlayer;
    }
    
    [[ApplifierImpactMainViewController sharedInstance] openImpact:[currentZone openAnimated] inState:state withOptions:options];
    
    return true;
  } else {
    return false;
  }
}

- (BOOL)showImpact {
  return [self showImpact:nil];
}

- (BOOL)hasMultipleRewardItems {
  id currentZone = [[ApplifierImpactZoneManager sharedInstance] getCurrentZone];
  if(currentZone && [currentZone isIncentivized]) {
    id rewardManager = [((ApplifierImpactIncentivizedZone *)currentZone) itemManager];
    if(rewardManager != nil && [rewardManager itemCount] > 1) {
      return TRUE;
    }
  }
  return FALSE;
}

- (NSArray *)getRewardItemKeys {
  id currentZone = [[ApplifierImpactZoneManager sharedInstance] getCurrentZone];
  if(currentZone && [currentZone isIncentivized]) {
    return [[((ApplifierImpactIncentivizedZone *)currentZone) itemManager] allItems];
  }
  return nil;
}

- (NSString *)getDefaultRewardItemKey {
  id currentZone = [[ApplifierImpactZoneManager sharedInstance] getCurrentZone];
  if(currentZone && [currentZone isIncentivized]) {
    return [[((ApplifierImpactIncentivizedZone *)currentZone) itemManager] getDefaultItem].key;
  }
  return nil;
}

- (NSString *)getCurrentRewardItemKey {
  id currentZone = [[ApplifierImpactZoneManager sharedInstance] getCurrentZone];
  if(currentZone && [currentZone isIncentivized]) {
    return [[((ApplifierImpactIncentivizedZone *)currentZone) itemManager] getCurrentItem].key;
  }
  return nil;

}

- (BOOL)setRewardItemKey:(NSString *)rewardItemKey {
  if (![[ApplifierImpactMainViewController sharedInstance] mainControllerVisible]) {
    id currentZone = [[ApplifierImpactZoneManager sharedInstance] getCurrentZone];
    if(currentZone && [currentZone isIncentivized]) {
      return [[((ApplifierImpactIncentivizedZone *)currentZone) itemManager] setCurrentItem:rewardItemKey];
    }
  }
  return false;
}

- (void)setDefaultRewardItemAsRewardItem {
  if (![[ApplifierImpactMainViewController sharedInstance] mainControllerVisible]) {
    id currentZone = [[ApplifierImpactZoneManager sharedInstance] getCurrentZone];
    if(currentZone && [currentZone isIncentivized]) {
      id itemManager = [((ApplifierImpactIncentivizedZone *)currentZone) itemManager];
      [itemManager setCurrentItem:[itemManager getDefaultItem].key];
    }
  }
}

- (NSDictionary *)getRewardItemDetailsWithKey:(NSString *)rewardItemKey {
  id currentZone = [[ApplifierImpactZoneManager sharedInstance] getCurrentZone];
  if(currentZone && [currentZone isIncentivized]) {
    id itemManager = [((ApplifierImpactIncentivizedZone *)currentZone) itemManager];
    id item = [itemManager getItem:rewardItemKey];
    if(item != nil) {
      return [item getDetails];
    }
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
  } else {
    if([[ApplifierImpactMainViewController sharedInstance] isOpen]) {
      [[ApplifierImpactMainViewController sharedInstance] closeImpact:YES withAnimations:NO withOptions:nil];
    }
  }
  
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
  if ([[ApplifierImpactCampaignManager sharedInstance] campaigns] != nil && [[[ApplifierImpactCampaignManager sharedInstance] campaigns] count] > 0 && self.initializer != nil && [self.initializer initWasSuccessfull]) {
		return true;
  }
  return false;
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
	
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(applifierImpactWillClose:)])
		[self.delegate applifierImpactWillClose:self];
}

- (void)mainControllerDidClose {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
  
  if (self.delegate != nil && [self.delegate respondsToSelector:@selector(applifierImpactDidClose:)])
		[self.delegate applifierImpactDidClose:self];
}

- (void)mainControllerWillOpen {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
  
  if (self.delegate != nil && [self.delegate respondsToSelector:@selector(applifierImpactWillOpen:)])
		[self.delegate applifierImpactWillOpen:self];
}

- (void)mainControllerDidOpen {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
  
  if (self.delegate != nil && [self.delegate respondsToSelector:@selector(applifierImpactDidOpen:)])
		[self.delegate applifierImpactDidOpen:self];
}

- (void)mainControllerStartedPlayingVideo {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(applifierImpactVideoStarted:)])
		[self.delegate applifierImpactVideoStarted:self];
}

- (void)mainControllerVideoEnded {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
  if (![[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].viewed) {
    [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].viewed = YES;
    
    if (self.delegate != nil) {
      NSString *key = nil;
      id currentZone = [[ApplifierImpactZoneManager sharedInstance] getCurrentZone];
      if([currentZone isIncentivized]) {
        id itemManager = [((ApplifierImpactIncentivizedZone *)currentZone) itemManager];
        key = [itemManager getCurrentItem].key;
      }
      [self.delegate applifierImpact:self completedVideoWithRewardItemKey:key videoWasSkipped:FALSE];
    }
  }
}

- (void)mainControllerVideoSkipped {
  AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
	
  if (![[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].viewed) {
    [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].viewed = YES;
    
    if (self.delegate != nil) {
      NSString *key = nil;
      id currentZone = [[ApplifierImpactZoneManager sharedInstance] getCurrentZone];
      if([currentZone isIncentivized]) {
        id itemManager = [((ApplifierImpactIncentivizedZone *)currentZone) itemManager];
        key = [itemManager getCurrentItem].key;
      }
      [self.delegate applifierImpact:self completedVideoWithRewardItemKey:key videoWasSkipped:TRUE];
    }
  }
}

- (void)mainControllerWillLeaveApplication {
	AIAssert([NSThread isMainThread]);
	AILOG_DEBUG(@"");
  
  if (self.delegate != nil && [self.delegate respondsToSelector:@selector(applifierImpactWillLeaveApplication:)])
		[self.delegate applifierImpactWillLeaveApplication:self];
}


#pragma mark - ApplifierImpactDelegate calling methods

- (void)notifyDelegateOfCampaignAvailability {
	if ([self impactCanBeShown]) {
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(applifierImpactCampaignsAreAvailable:)])
			[self.delegate applifierImpactCampaignsAreAvailable:self];
	}
}

@end