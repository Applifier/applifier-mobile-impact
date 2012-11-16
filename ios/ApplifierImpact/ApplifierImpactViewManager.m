//
//  ApplifierImpactViewManager.m
//  ImpactProto
//
//  Created by Johan Halin on 9/20/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "ApplifierImpactViewManager.h"
#import "ApplifierImpact.h"
#import "ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "ApplifierImpactVideo/ApplifierImpactVideo.h"
#import "ApplifierImpactWebView/ApplifierImpactWebAppController.h"
#import "ApplifierImpactDevice/ApplifierImpactDevice.h"
#import "ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"

@interface ApplifierImpactViewManager () <UIWebViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIView *adContainerView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) ApplifierImpactVideo *player;
@property (nonatomic, assign) UIViewController *storePresentingViewController;
@end

@implementation ApplifierImpactViewManager

#pragma mark - Private

- (void)closeAdView {
	[self.delegate viewManagerWillCloseAdView];
	[[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeStart data:@{}];
	[self.window addSubview:[[ApplifierImpactWebAppController sharedInstance] webView]];
	[self.adContainerView removeFromSuperview];
}

- (BOOL)_canOpenStoreProductViewController {
	Class storeProductViewControllerClass = NSClassFromString(@"SKStoreProductViewController");
	return [storeProductViewControllerClass instancesRespondToSelector:@selector(loadProductWithParameters:completionBlock:)];
}

- (Float64)_currentVideoDuration {
	CMTime durationTime = self.player.currentItem.asset.duration;
	Float64 duration = CMTimeGetSeconds(durationTime);
	
	return duration;
}

- (void)_updateTimeRemainingLabelWithTime:(CMTime)currentTime {
	Float64 duration = [self _currentVideoDuration];
	Float64 current = CMTimeGetSeconds(currentTime);
	NSString *descriptionText = [NSString stringWithFormat:NSLocalizedString(@"This video ends in %.0f seconds.", nil), duration - current];
	self.progressLabel.text = descriptionText;
}

- (void)_displayProgressLabel
{
	CGFloat padding = 10.0;
	CGFloat height = 30.0;
	CGRect labelFrame = CGRectMake(padding, self.adContainerView.frame.size.height - height, self.adContainerView.frame.size.width - (padding * 2.0), height);
	self.progressLabel.frame = labelFrame;
	self.progressLabel.hidden = NO;
	[self.adContainerView bringSubviewToFront:self.progressLabel];
}

- (NSValue *)_valueWithDuration:(Float64)duration
{
	CMTime time = CMTimeMakeWithSeconds(duration, NSEC_PER_SEC);
	return [NSValue valueWithCMTime:time];
}

- (void)openAppStoreWithGameId:(NSString *)gameId
{
	if (gameId == nil || [gameId length] == 0)
	{
		AILOG_DEBUG(@"Game ID not set or empty.");
		return;
	}
	
	if ( ! [self _canOpenStoreProductViewController])
	{
		AILOG_DEBUG(@"Cannot open store product view controller, falling back to click URL.");
		[[ApplifierImpactWebAppController sharedInstance] openExternalUrl:[[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].clickURL absoluteString]];
		return;
	}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1
	SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
	storeController.delegate = (id)self;
	NSDictionary *productParameters = @{ SKStoreProductParameterITunesItemIdentifier : gameId};
	[storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
		if (result)
		{
			self.storePresentingViewController = [self.delegate viewControllerForPresentingViewControllersForViewManager:self];
			[self.storePresentingViewController presentModalViewController:storeController animated:YES];
		}
		else
			AILOG_DEBUG(@"Loading product information failed: %@", error);
	}];
#endif
}


#pragma mark - Public

static ApplifierImpactViewManager *sharedImpactViewManager = nil;

+ (id)sharedInstance
{
	@synchronized(self)
	{
		if (sharedImpactViewManager == nil)
				sharedImpactViewManager = [[ApplifierImpactViewManager alloc] init];
	}
	
	return sharedImpactViewManager;
}

- (id)init
{
	AIAssertV([NSThread isMainThread], nil);
	
	if ((self = [super init]))
	{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(notificationHandler:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [ApplifierImpactWebAppController sharedInstance];
    [_window addSubview:[[ApplifierImpactWebAppController sharedInstance] webView]];
	}
	
	return self;
}

#pragma mark - Notification receiver

- (void)notificationHandler: (id) notification {
  NSString *name = [notification name];
  
  AILOG_DEBUG(@"notification: %@", name);
  
  if ([name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
    [[ApplifierImpactWebAppController sharedInstance] webView].userInteractionEnabled = YES;
    [self hidePlayer];
    [self closeAdView];
  }
}


- (void)loadWebView
{
	AIAssert([NSThread isMainThread]);
  //[_webApp setup:_window.bounds webAppParams:valueDictionary];
}

// FIX: Rename this method to something more descriptive
- (UIView *)adView
{
	AIAssertV([NSThread isMainThread], nil);
	
	if ([[ApplifierImpactWebAppController sharedInstance] webViewInitialized])
	{
    [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeStart data:@{}];
		
		if (self.adContainerView == nil)
		{
			self.adContainerView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
      [self.adContainerView setBackgroundColor:[UIColor blackColor]];
			
			self.progressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
			self.progressLabel.backgroundColor = [UIColor clearColor];
			self.progressLabel.textColor = [UIColor whiteColor];
			self.progressLabel.font = [UIFont systemFontOfSize:12.0];
			self.progressLabel.textAlignment = UITextAlignmentRight;
			self.progressLabel.shadowColor = [UIColor blackColor];
			self.progressLabel.shadowOffset = CGSizeMake(0, 1.0);
			self.progressLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
			[self.adContainerView addSubview:self.progressLabel];
		}
		
		if ([[ApplifierImpactWebAppController sharedInstance] webView].superview != self.adContainerView)
		{
			[[[ApplifierImpactWebAppController sharedInstance] webView] setBounds:self.adContainerView.bounds];
			[self.adContainerView addSubview:[[ApplifierImpactWebAppController sharedInstance] webView]];
		}
		
		return self.adContainerView;
	}
	else
	{
		AILOG_DEBUG(@"Web view not initialized.");
		return nil;
	}
}

- (void)initWebApp {
	AIAssert([NSThread isMainThread]);
 
  NSDictionary *persistingData = @{@"campaignData":[[ApplifierImpactCampaignManager sharedInstance] campaignData], @"platform":@"ios", @"deviceId":[ApplifierImpactDevice md5DeviceId]};
  
  NSDictionary *trackingData = @{@"iOSVersion":[ApplifierImpactDevice softwareVersion], @"deviceType":[ApplifierImpactDevice analyticsMachineName]};
  NSMutableDictionary *webAppValues = [NSMutableDictionary dictionaryWithDictionary:persistingData];
  
  if ([ApplifierImpactDevice canUseTracking]) {
    [webAppValues addEntriesFromDictionary:trackingData];
  }
  
  [[ApplifierImpactWebAppController sharedInstance] setDelegate:self];
  [[ApplifierImpactWebAppController sharedInstance] setupWebApp:_window.bounds];
  [[ApplifierImpactWebAppController sharedInstance] loadWebApp:webAppValues];
}

- (BOOL)adViewVisible
{
	AIAssertV([NSThread isMainThread], NO);
	
	if ([[ApplifierImpactWebAppController sharedInstance] webView].superview == self.window)
		return NO;
	else
		return YES;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
	[self.storePresentingViewController dismissViewControllerAnimated:YES completion:nil];

	self.storePresentingViewController = nil;
}


#pragma mark - ApplifierImpactVideoDelegate

- (void)videoPositionChanged:(CMTime)time {
  [self _updateTimeRemainingLabelWithTime:time];
}

- (void)videoPlaybackStarted {
  [self _displayProgressLabel];
  [self.delegate viewManagerStartedPlayingVideo];
  [[ApplifierImpactWebAppController sharedInstance] webView].userInteractionEnabled = NO;
}

- (void)videoPlaybackEnded {
  [[ApplifierImpactWebAppController sharedInstance] webView].userInteractionEnabled = YES;
	[self.delegate viewManagerVideoEnded];
	[self hidePlayer];
	
  NSDictionary *data = @{@"campaignId":[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id};
  
  [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeCompleted data:data];
	[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].viewed = YES;
}


#pragma mark - Video

- (void)hidePlayer {
  if (self.player != nil) {
    self.progressLabel.hidden = YES;
    [self.player.playerLayer removeFromSuperlayer];
    self.player.playerLayer = nil;
    self.player = nil;
  }
}

- (void)showPlayerAndPlaySelectedVideo {
	AILOG_DEBUG(@"");
  
	NSURL *videoURL = [[ApplifierImpactCampaignManager sharedInstance] getVideoURLForCampaign:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign]];
	if (videoURL == nil)
	{
		AILOG_DEBUG(@"Video not found!");
		return;
	}
	
	AVPlayerItem *item = [AVPlayerItem playerItemWithURL:videoURL];
  
  self.player = [[ApplifierImpactVideo alloc] initWithPlayerItem:item];
  self.player.delegate = self;
  [self.player createPlayerLayer];
  self.player.playerLayer.frame = self.adContainerView.bounds;
	[self.adContainerView.layer addSublayer:self.player.playerLayer];
  [self.player playSelectedVideo];
}


#pragma mark - WebAppController

- (void)webAppReady {
  _webViewInitialized = YES;
  [self.delegate viewManagerWebViewInitialized];
}

@end
