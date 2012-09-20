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
#import "ApplifierImpactCampaign.h"

// FIXME: this is (obviously) NOT the final URL!
NSString * const kApplifierImpactTestWebViewURL = @"https://dl.dropbox.com/u/3542608/protos/impact-mobile-proto/index.html";
NSString * const kApplifierImpactWebViewAPINativeInit = @"impactInit";
NSString * const kApplifierImpactWebViewAPINativeShow = @"impactShow";
NSString * const kApplifierImpactWebViewAPINativeVideoComplete = @"impactVideoComplete";
NSString * const kApplifierImpactWebViewAPIPlayVideo = @"playvideo";
NSString * const kApplifierImpactWebViewAPIClose = @"close";
NSString * const kApplifierImpactWebViewAPINavigateTo = @"navigateto";
NSString * const kApplifierImpactWebViewAPIInitComplete = @"initcomplete";

@interface ApplifierImpactViewManager () <UIWebViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView *adContainerView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, assign) BOOL webViewLoaded;
@property (nonatomic, assign) BOOL webViewInitialized;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) id analyticsTimeObserver;
@property (nonatomic, assign) VideoAnalyticsPosition videoPosition;
@end

@implementation ApplifierImpactViewManager

#pragma mark - Private

- (void)_closeAdView
{
	[self.delegate viewManagerWillCloseAdView:self];
	
	[self.window addSubview:self.webView];
	[self.adContainerView removeFromSuperview];
}

- (void)_selectCampaignWithID:(NSString *)campaignID
{
	self.selectedCampaign = nil;
	
	if (campaignID == nil)
	{
		AILOG_DEBUG(@"Input is nil.");
		return;
	}

	ApplifierImpactCampaign *campaign = [self.delegate viewManager:self campaignWithID:campaignID];
	
	if (campaign != nil)
	{
		self.selectedCampaign = campaign;
		[self _playVideo];
	}
	else
		AILOG_DEBUG(@"No campaign with id '%@' found.", campaignID);
}

- (void)_processWebViewResponseWithHost:(NSString *)host query:(NSString *)query
{
	if (host == nil)
		return;
	
	NSString *command = [host lowercaseString];
	NSArray *queryComponents = nil;
	if (query != nil)
		queryComponents = [query componentsSeparatedByString:@"="];
	
	if ([command isEqualToString:kApplifierImpactWebViewAPIPlayVideo] || [command isEqualToString:kApplifierImpactWebViewAPINavigateTo])
	{
		if (queryComponents == nil)
		{
			AILOG_DEBUG(@"No parameters given.");
			return;
		}
		
		NSString *parameter = [queryComponents objectAtIndex:0];
		NSString *value = [queryComponents objectAtIndex:1];
		
		if ([queryComponents count] > 2)
		{
			for (NSInteger i = 2; i < [queryComponents count]; i++)
				value = [value stringByAppendingFormat:@"=%@", [queryComponents objectAtIndex:i]];
		}
		
		if ([command isEqualToString:kApplifierImpactWebViewAPIPlayVideo])
		{
			if ([parameter isEqualToString:@"campaignID"])
				[self _selectCampaignWithID:value];
		}
		else if ([command isEqualToString:kApplifierImpactWebViewAPINavigateTo])
		{
			if ([parameter isEqualToString:@"url"])
				[self _openURL:value];
		}
	}
	else if ([command isEqualToString:kApplifierImpactWebViewAPIClose])
	{
		[self _closeAdView];
	}
	else if ([command isEqualToString:kApplifierImpactWebViewAPIInitComplete])
	{
		[self _webViewInitComplete];
	}
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

- (NSString *)_escapedStringFromString:(NSString *)string
{
	if (string == nil)
	{
		AILOG_DEBUG(@"Input is nil.");
		return nil;
	}
	
	NSString *escapedString = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
	escapedString = [escapedString stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
	
	return escapedString;
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

- (void)_logVideoAnalytics
{
	self.videoPosition++;
	
	[self.delegate viewManager:self loggedVideoPosition:self.videoPosition campaign:self.selectedCampaign];
}

- (void)_playVideo
{
	NSURL *videoURL = [self.delegate viewManager:self videoURLForCampaign:self.selectedCampaign];
	if (videoURL == nil)
	{
		AILOG_DEBUG(@"Video not found!");
		return;
	}
	
	AVPlayerItem *item = [AVPlayerItem playerItemWithURL:videoURL];
	self.player = [AVPlayer playerWithPlayerItem:item];
	self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
	self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	self.playerLayer.frame = self.adContainerView.bounds;
	[self.adContainerView.layer addSublayer:self.playerLayer];
	
	[self _displayProgressLabel];
	
	__block ApplifierImpactViewManager *blockSelf = self;
	self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
		[blockSelf _updateTimeRemainingLabelWithTime:time];
	}];
	
	self.videoPosition = kVideoAnalyticsPositionUnplayed;
	Float64 duration = [self _currentVideoDuration];
	NSMutableArray *analyticsTimeValues = [NSMutableArray array];
	[analyticsTimeValues addObject:[self _valueWithDuration:duration * .25]];
	[analyticsTimeValues addObject:[self _valueWithDuration:duration * .5]];
	[analyticsTimeValues addObject:[self _valueWithDuration:duration * .75]];
	self.analyticsTimeObserver = [self.player addBoundaryTimeObserverForTimes:analyticsTimeValues queue:nil usingBlock:^{
		[blockSelf _logVideoAnalytics];
	}];
	
	[self.player play];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoPlaybackEnded:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
	
	[self.delegate viewManagerStartedPlayingVideo:self];
	
	[self _logVideoAnalytics];
}

- (void)_videoPlaybackEnded:(NSNotification *)notification
{
	[self.delegate viewManagerVideoEnded:self];
	
	[self _logVideoAnalytics];
	
	[self.player removeTimeObserver:self.timeObserver];
	self.timeObserver = nil;
	[self.player removeTimeObserver:self.analyticsTimeObserver];
	self.analyticsTimeObserver = nil;
	
	self.progressLabel.hidden = YES;
	
	[self.playerLayer removeFromSuperlayer];
	self.playerLayer = nil;
	self.player = nil;
	
	[self _webViewVideoComplete];
	
	self.selectedCampaign.viewed = YES;
}

- (void)_openStoreViewControllerWithGameID:(NSString *)gameID
{
	if (gameID == nil || [gameID length] == 0)
	{
		AILOG_DEBUG(@"Game ID not set or empty.");
		return;
	}
	
	Class storeProductViewControllerClass = NSClassFromString(@"SKStoreProductViewController");
	if ([storeProductViewControllerClass instancesRespondToSelector:@selector(loadProductWithParameters:completionBlock:)])
	{
		__block ApplifierImpactViewManager *blockSelf = self;
		__block id storeController = [[[storeProductViewControllerClass class] alloc] init];
		NSDictionary *productParameters = @{ SKStoreProductParameterITunesItemIdentifier : gameID };
		[storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
			if (result)
				[blockSelf.delegate viewManager:blockSelf wantsToPresentProductViewController:storeController];
			else
				AILOG_DEBUG(@"Loading product information failed: %@", error);
		}];
	}
	else
		AILOG_DEBUG(@"Not supported on older versions of iOS.");
}

- (void)_webViewInitComplete
{
	self.webViewInitialized = YES;
	
	[self.delegate viewManagerWebViewInitialized:self];
}

- (void)_webViewInit
{
	if (self.campaignJSON == nil || !self.webViewLoaded)
	{
		AILOG_DEBUG(@"JSON or web view has not been loaded yet.");
		return;
	}
	
	AILOG_DEBUG(@"");
	
	NSString *escapedJSON = [self _escapedStringFromString:self.campaignJSON];
	NSString *deviceInformation = nil;
	if (self.md5AdvertisingIdentifier != nil)
		deviceInformation = [NSString stringWithFormat:@"{\"advertisingTrackingID\":\"%@\",\"iOSVersion\":\"%@\",\"deviceType\":\"%@\"}", self.md5AdvertisingIdentifier, [[UIDevice currentDevice] systemVersion], self.machineName];
	else
		deviceInformation = [NSString stringWithFormat:@"{\"openUdid\":\"%@\",\"macAddress\":\"%@\",\"iOSVersion\":\"%@\",\"deviceType\":\"%@\"}", self.md5OpenUDID, self.md5MACAddress, [[UIDevice currentDevice] systemVersion], self.machineName];
	
	NSString *js = [NSString stringWithFormat:@"%@(\"%@\",\"%@\");", kApplifierImpactWebViewAPINativeInit, escapedJSON, [self _escapedStringFromString:deviceInformation]];
	
	[self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)_webViewShow
{
	[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@();", kApplifierImpactWebViewAPINativeShow]];
}

- (void)_webViewVideoComplete
{
	NSString *js = [NSString stringWithFormat:@"%@(%@);", kApplifierImpactWebViewAPINativeVideoComplete, self.selectedCampaign.id];
	
	[self.webView stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark - Public

- (id)init
{
	if ((self = [super init]))
	{
		_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		_webView = [[UIWebView alloc] initWithFrame:_window.bounds];
		_webView.delegate = self;
		_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		UIScrollView *scrollView = nil;
		if ([_webView respondsToSelector:@selector(scrollView)])
			scrollView = _webView.scrollView;
		else
		{
			UIView *view = [_webView.subviews lastObject];
			if ([view isKindOfClass:[UIScrollView class]])
				scrollView = (UIScrollView *)view;
		}
		
		if (scrollView != nil)
		{
			scrollView.delegate = self;
			scrollView.showsVerticalScrollIndicator = NO;
		}
		
		[_window addSubview:_webView];
	}
	
	return self;
}

- (void)start
{
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kApplifierImpactTestWebViewURL]]];
}

- (UIView *)adView
{
	if (self.webViewInitialized)
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
		
		if (self.webView.superview != self.adContainerView)
		{
			self.webView.bounds = self.adContainerView.bounds;
			[self.adContainerView addSubview:self.webView];
		}
		
		return self.adContainerView;
	}
	else
	{
		AILOG_DEBUG(@"Web view not initialized.");
		return nil;
	}
}

- (void)setCampaignJSON:(NSString *)campaignJSON
{
	_campaignJSON = campaignJSON;
	
	if (self.webViewLoaded)
		[self _webViewInit];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = [request URL];
	AILOG_DEBUG(@"url %@", url);
	if ([[url scheme] isEqualToString:@"applifier-impact"])
	{
		[self _processWebViewResponseWithHost:[url host] query:[url query]];
		
		return NO;
	}
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	AILOG_DEBUG(@"");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	AILOG_DEBUG(@"");
	
	self.webViewLoaded = YES;
	
	if ( ! self.webViewInitialized)
		[self _webViewInit];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	AILOG_DEBUG(@"%@", error);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
}

@end
