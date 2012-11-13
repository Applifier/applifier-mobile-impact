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
#import "ApplifierImpactURLProtocol/ApplifierImpactURLProtocol.h"
#import "ApplifierImpactVideo/ApplifierImpactVideo.h"
#import "ApplifierImpactWebView/ApplifierImpactWebAppController.h"
#import "ApplifierImpactUtils/ApplifierImpactUtils.h"
#import "ApplifierImpactDevice/ApplifierImpactDevice.h"
#import "ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"

@interface ApplifierImpactViewManager () <UIWebViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) ApplifierImpactWebAppController *webApp;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView *adContainerView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, assign) BOOL webViewLoaded;
@property (nonatomic, assign) BOOL webViewInitialized;
@property (nonatomic, strong) ApplifierImpactVideo *player;
@property (nonatomic, assign) UIViewController *storePresentingViewController;

@end

@implementation ApplifierImpactViewManager

#pragma mark - Private

- (void)_closeAdView
{
	[self.delegate viewManagerWillCloseAdView:self];
	
	[self.window addSubview:_webApp.webView];
	[self.adContainerView removeFromSuperview];
}

- (void)_selectCampaignWithID:(NSString *)campaignId
{
	[[ApplifierImpactCampaignManager sharedInstance] setSelectedCampaign:nil];
  //self.selectedCampaign = nil;
	
	if (campaignId == nil)
	{
		AILOG_DEBUG(@"Input is nil.");
		return;
	}

	ApplifierImpactCampaign *campaign = [[ApplifierImpactCampaignManager sharedInstance] getCampaignWithId:campaignId];
	
	if (campaign != nil)
	{
		[[ApplifierImpactCampaignManager sharedInstance] setSelectedCampaign:campaign];
    //self.selectedCampaign = campaign;
		[self _playVideo];
	}
	else
		AILOG_DEBUG(@"No campaign with id '%@' found.", campaignId);
}

- (BOOL)_canOpenStoreProductViewController
{
	Class storeProductViewControllerClass = NSClassFromString(@"SKStoreProductViewController");
	return [storeProductViewControllerClass instancesRespondToSelector:@selector(loadProductWithParameters:completionBlock:)];
}

- (void)_openURL:(NSString *)urlString
{
	if (urlString == nil)
	{
		AILOG_DEBUG(@"No URL set.");
		return;
	}
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (Float64)_currentVideoDuration
{
	CMTime durationTime = self.player.currentItem.asset.duration;
	Float64 duration = CMTimeGetSeconds(durationTime);
	
	return duration;
}

- (void)_updateTimeRemainingLabelWithTime:(CMTime)currentTime
{
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

- (void)_openStoreViewControllerWithGameID:(NSString *)gameID
{
	if (gameID == nil || [gameID length] == 0)
	{
		AILOG_DEBUG(@"Game ID not set or empty.");
		return;
	}
	
	if ( ! [self _canOpenStoreProductViewController])
	{
		AILOG_DEBUG(@"Cannot open store product view controller, falling back to click URL.");
		[self _openURL:[[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].clickURL absoluteString]];
    //[self _openURL:[self.selectedCampaign.clickURL absoluteString]];
		return;
	}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1
	SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
	storeController.delegate = (id)self;
	NSDictionary *productParameters = @{ SKStoreProductParameterITunesItemIdentifier : gameID };
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

- (void)_webViewInitComplete
{
	_webApp.webViewInitialized = YES;
	[self.delegate viewManagerWebViewInitialized:self];
}

- (void)_webViewShow
{
  [_webApp setWebViewCurrentView:@"start" data:@""];
}

- (void)_webViewVideoComplete
{
	NSString *data = [NSString stringWithFormat:@"{\"campaignId\":\"%@\"}", [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id];
  
  // FIX
 // [_webApp setWebViewCurrentView:@"completed" data:[ApplifierImpactUtils escapedStringFromString:data]];
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

- (void)handleWebEvent:(NSString *)type data:(NSDictionary *)data
{
  AILOG_DEBUG(@"Gotevent: %@  widthData: %@", type, data);
  
  if ([type isEqualToString:_webApp.WEBVIEW_API_PLAYVIDEO] || [type isEqualToString:_webApp.WEBVIEW_API_NAVIGATETO] || [type isEqualToString:_webApp.WEBVIEW_API_APPSTORE])
	{
		if ([type isEqualToString:_webApp.WEBVIEW_API_PLAYVIDEO])
		{
      if ([data objectForKey:@"campaignId"] != nil)
        [self _selectCampaignWithID:[data objectForKey:@"campaignId"]];
		}
		else if ([type isEqualToString:_webApp.WEBVIEW_API_NAVIGATETO])
		{
        if ([data objectForKey:@"clickUrl"] != nil)
          [self _openURL:[data objectForKey:@"clickUrl"]];
		}
		else if ([type isEqualToString:_webApp.WEBVIEW_API_APPSTORE])
		{
          if ([data objectForKey:@"clickUrl"] != nil)
            [self _openStoreViewControllerWithGameID:[data objectForKey:@"clickUrl"]];
		}
	}
	else if ([type isEqualToString:_webApp.WEBVIEW_API_CLOSE])
	{
		[self _closeAdView];
	}
	else if ([type isEqualToString:_webApp.WEBVIEW_API_INITCOMPLETE])
	{
    [self _webViewInitComplete];
	}
}

- (id)init
{
	AIAssertV([NSThread isMainThread], nil);
	
	if ((self = [super init]))
	{
		_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		_webApp = [[ApplifierImpactWebAppController alloc] init];

		[_window addSubview:_webApp.webView];
	}
	
	return self;
}

- (void)loadWebView
{
	AIAssert([NSThread isMainThread]);
  //[_webApp setup:_window.bounds webAppParams:valueDictionary];
}

- (UIView *)adView
{
	AIAssertV([NSThread isMainThread], nil);
	
	if (_webApp.webViewInitialized)
	{
		[self _webViewShow];
		
		if (self.adContainerView == nil)
		{
			self.adContainerView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
			
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
		
		if (_webApp.webView.superview != self.adContainerView)
		{
			_webApp.webView.bounds = self.adContainerView.bounds;
			[self.adContainerView addSubview:_webApp.webView];
		}
		
		return self.adContainerView;
	}
	else
	{
		AILOG_DEBUG(@"Web view not initialized.");
		return nil;
	}
}

// FIX

/*
- (void)setCampaignJSON:(NSDictionary *)campaignJSON
{
	AIAssert([NSThread isMainThread]);
	
	_campaignJSON = campaignJSON;
  
  NSDictionary *values = @{@"advertisingTrackingId":self.md5AdvertisingIdentifier, @"iOSVersion":[ApplifierImpactDevice softwareVersion], @"deviceType":self.machineName, @"deviceId":self.md5DeviceId, @"macAddress":self.md5MACAddress, @"openUdid":self.md5OpenUDID, @"campaignData":_campaignJSON};
 
  [_webApp setup:_window.bounds webAppParams:values];
}*/

- (void)campaignDataReceived {
	AIAssert([NSThread isMainThread]);
	
	//_campaignJSON = campaignJSON;
  
  NSDictionary *values = @{@"advertisingTrackingId":[ApplifierImpactDevice md5AdvertisingIdentifierString], @"iOSVersion":[ApplifierImpactDevice softwareVersion], @"deviceType":[ApplifierImpactDevice machineName], @"deviceId":[ApplifierImpactDevice md5DeviceId], @"macAddress":[ApplifierImpactDevice md5MACAddressString], @"openUdid":[ApplifierImpactDevice md5OpenUDIDString], @"campaignData":[[ApplifierImpactCampaignManager sharedInstance] campaignData]};
  
  [_webApp setup:_window.bounds webAppParams:values];
}

- (BOOL)adViewVisible
{
	AIAssertV([NSThread isMainThread], NO);
	
	if (_webApp.webView.superview == self.window)
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

- (void)videoAnalyticsPositionReached:(VideoAnalyticsPosition)analyticsPosition {
  [self.delegate viewManager:self loggedVideoPosition:analyticsPosition campaign:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign]];
}

- (void)videoPositionChanged:(CMTime)time {
  [self _updateTimeRemainingLabelWithTime:time];
}

- (void)videoPlaybackStarted {
  [self _displayProgressLabel];
  [self.delegate viewManagerStartedPlayingVideo:self];
}

- (void)videoPlaybackEnded {
	[self.delegate viewManagerVideoEnded:self];
	
	self.progressLabel.hidden = YES;
	
	[self.player.playerLayer removeFromSuperlayer];
	self.player.playerLayer = nil;
	self.player = nil;
	
	[self _webViewVideoComplete];
	
	[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].viewed = YES;
}

#pragma mark - Video

- (void)_playVideo
{
	AILOG_DEBUG(@"");
	
	NSURL *videoURL = [[ApplifierImpactCampaignManager sharedInstance] videoURLForCampaign:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign]];
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

@end
