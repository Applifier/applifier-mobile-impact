//
//  ApplifierImpactiOS4.m
//  ImpactProto
//
//  Created by Johan Halin on 9/4/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <CommonCrypto/CommonDigest.h>

#import <AVFoundation/AVFoundation.h>
#import "ApplifierImpactiOS4.h"
#import "ApplifierImpactCampaignManager.h"
#import "ApplifierImpactCampaign.h"
#import "ApplifierImpactRewardItem.h"
#import "ApplifierImpactOpenUDID.h"
#import "ApplifierImpactAnalyticsUploader.h"

// FIXME: this is (obviously) NOT the final URL!
NSString * const kApplifierImpactTestWebViewURL = @"https://dl.dropbox.com/u/16969980/protos/impact-mobile-proto/index.html";

NSString * const kApplifierImpactWebViewAPINativeInit = @"impactInit";
NSString * const kApplifierImpactWebViewAPINativeShow = @"impactShow";
NSString * const kApplifierImpactWebViewAPINativeVideoComplete = @"impactVideoComplete";
NSString * const kApplifierImpactWebViewAPIPlayVideo = @"playvideo";
NSString * const kApplifierImpactWebViewAPIClose = @"close";
NSString * const kApplifierImpactWebViewAPINavigateTo = @"navigateto";

typedef enum
{
	kVideoAnalyticsPositionUnplayed = -1,
	kVideoAnalyticsPositionStart = 0,
	kVideoAnalyticsPositionFirstQuartile = 1,
	kVideoAnalyticsPositionMidPoint = 2,
	kVideoAnalyticsPositionThirdQuartile = 3,
	kVideoAnalyticsPositionEnd = 4,
} VideoAnalyticsPosition;

@interface ApplifierImpactiOS4 () <ApplifierImpactCampaignManagerDelegate, UIWebViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) NSString *applifierID;
@property (nonatomic, strong) NSThread *cacheThread;
@property (nonatomic, strong) NSThread *analyticsThread;
@property (nonatomic, strong) ApplifierImpactCampaignManager *campaignManager;
@property (nonatomic, strong) UIWindow *applifierWindow;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSArray *campaigns;
@property (nonatomic, strong) ApplifierImpactRewardItem *rewardItem;
@property (nonatomic, strong) UIView *adView;
@property (nonatomic, strong) ApplifierImpactCampaign *selectedCampaign;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) id analyticsTimeObserver;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, assign) VideoAnalyticsPosition videoPosition;
@property (nonatomic, strong) ApplifierImpactAnalyticsUploader *analyticsUploader;
@property (nonatomic, assign) BOOL webViewLoaded;
@property (nonatomic, assign) BOOL webViewInitialized;
@property (nonatomic, strong) NSString *campaignJSON;
@end

@implementation ApplifierImpactiOS4

@synthesize applifierID = _applifierID;
@synthesize cacheThread = _cacheThread;
@synthesize analyticsThread = _analyticsThread;
@synthesize campaignManager = _campaignManager;
@synthesize applifierWindow = _applifierWindow;
@synthesize webView = _webView;
@synthesize campaigns = _campaigns;
@synthesize rewardItem = _rewardItem;
@synthesize adView = _adView;
@synthesize selectedCampaign = _selectedCampaign;
@synthesize player = _player;
@synthesize playerLayer = _playerLayer;
@synthesize timeObserver = _timeObserver;
@synthesize analyticsTimeObserver = _analyticsTimeObserver;
@synthesize progressLabel = _progressLabel;
@synthesize videoPosition = _videoPosition;
@synthesize analyticsUploader = _analyticsUploader;
@synthesize webViewLoaded = _webViewLoaded;
@synthesize webViewInitialized = _webViewInitialized;
@synthesize campaignJSON = _campaignJSON;

#pragma mark - Private

- (NSString *)_macAddress
{
	NSString *interface = @"en0";
	int mgmtInfoBase[6];
	char *msgBuffer = NULL;
	
	// Setup the management Information Base (mib)
	mgmtInfoBase[0] = CTL_NET; // Request network subsystem
	mgmtInfoBase[1] = AF_ROUTE; // Routing table info
	mgmtInfoBase[2] = 0;
	mgmtInfoBase[3] = AF_LINK; // Request link layer information
	mgmtInfoBase[4] = NET_RT_IFLIST; // Request all configured interfaces
	
	// With all configured interfaces requested, get handle index
	if ((mgmtInfoBase[5] = if_nametoindex([interface UTF8String])) == 0)
	{
		NSLog(@"Couldn't get MAC address for interface '%@', if_nametoindex failed.", interface);
		return nil;
	}
	
	size_t length;
	
	// Get the size of the data available (store in len)
	if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
	{
		NSLog(@"Couldn't get MAC address for interface '%@', sysctl for mgmtInfoBase length failed.", interface);
		return nil;
	}
	
	// Alloc memory based on above call
	if ((msgBuffer = malloc(length)) == NULL)
	{
		NSLog(@"Couldn't get MAC address for interface '%@', malloc for %zd bytes failed.", interface, length);
		return nil;
	}
	
	// Get system information, store in buffer
	if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
	{
		free(msgBuffer);
		
		NSLog(@"Couldn't get MAC address for interface '%@', sysctl for mgmtInfoBase data failed.", interface);
		return nil;
	}
	
	// Map msgbuffer to interface message structure
	struct if_msghdr *interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
	
	// Map to link-level socket structure
	struct sockaddr_dl *socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
	
	// Copy link layer address data in socket structure to an array
	unsigned char macAddress[6];
	memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
	
	// Read from char array into a string object, into MAC address format
	NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
	
	// Release the buffer memory
	free(msgBuffer);
	
	return macAddressString;
}

- (NSString *)_md5StringFromString:(NSString *)string
{
	const char *ptr = [string UTF8String];
	unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
	CC_MD5(ptr, strlen(ptr), md5Buffer);
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x",md5Buffer[i]];
	
	return output;
}

- (NSString *)_md5OpenUDIDString
{
	return [self _md5StringFromString:[ApplifierImpactOpenUDID value]];
}

- (NSString *)_md5MACAddressString
{
	return [self _md5StringFromString:[self _macAddress]];
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

- (void)_startCampaignManager
{
	self.campaignManager = [[ApplifierImpactCampaignManager alloc] init];
	self.campaignManager.delegate = self;
	[self.campaignManager updateCampaigns];
}

- (void)_selectCampaignWithID:(NSString *)campaignID
{
	for (ApplifierImpactCampaign *campaign in self.campaigns)
	{
		if ([campaign.id isEqualToString:campaignID])
		{
			self.selectedCampaign = campaign;
			break;
		}
	}
	
	if (self.selectedCampaign != nil)
		[self _playVideo];
}

- (void)_configureWebView
{
	self.webViewLoaded = NO;
	self.applifierWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.webView = [[UIWebView alloc] initWithFrame:self.applifierWindow.bounds];
	self.webView.delegate = self;
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	UIScrollView *scrollView = nil;
	if ([self.webView respondsToSelector:@selector(scrollView)])
		scrollView = self.webView.scrollView;
	else
	{
		UIView *view = [self.webView.subviews lastObject];
		if ([view isKindOfClass:[UIScrollView class]])
			scrollView = (UIScrollView *)view;
	}
	
	if (scrollView != nil)
		scrollView.delegate = self;
	
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kApplifierImpactTestWebViewURL]]];
	[self.applifierWindow addSubview:self.webView];
}

- (UIView *)_adView
{
	if (self.adView == nil)
	{
		self.adView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		self.webView.bounds = self.adView.bounds;
		[self.adView addSubview:self.webView];

		self.progressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		self.progressLabel.backgroundColor = [UIColor clearColor];
		self.progressLabel.textColor = [UIColor whiteColor];
		self.progressLabel.font = [UIFont systemFontOfSize:12.0];
		self.progressLabel.textAlignment = UITextAlignmentRight;
		self.progressLabel.shadowColor = [UIColor blackColor];
		self.progressLabel.shadowOffset = CGSizeMake(0, 1.0);
		self.progressLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
		[self.adView addSubview:self.progressLabel];
	}
	
	return self.adView;
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
	CGRect labelFrame = CGRectMake(padding, self.adView.frame.size.height - height, self.adView.frame.size.width - (padding * 2.0), height);
	self.progressLabel.frame = labelFrame;
	self.progressLabel.hidden = NO;
	[self.adView bringSubviewToFront:self.progressLabel];
}

- (NSValue *)_valueWithDuration:(Float64)duration
{
	CMTime time = CMTimeMakeWithSeconds(duration, NSEC_PER_SEC);
	return [NSValue valueWithCMTime:time];
}

- (void)_logPositionString:(NSString *)string
{
	[self.analyticsUploader sendViewReportForCampaign:self.selectedCampaign positionString:string];
}

- (void)_logVideoAnalytics
{
	self.videoPosition++;
	NSString *positionString = nil;
	if (self.videoPosition == kVideoAnalyticsPositionStart)
		positionString = @"start";
	else if (self.videoPosition == kVideoAnalyticsPositionFirstQuartile)
		positionString = @"first_quartile";
	else if (self.videoPosition == kVideoAnalyticsPositionMidPoint)
		positionString = @"mid_point";
	else if (self.videoPosition == kVideoAnalyticsPositionThirdQuartile)
		positionString = @"third_quartile";
	else if (self.videoPosition == kVideoAnalyticsPositionEnd)
		positionString = @"end";
	
	[self performSelector:@selector(_logPositionString:) onThread:self.analyticsThread withObject:positionString waitUntilDone:NO];
}

- (void)_playVideo
{
	NSURL *videoURL = [self.campaignManager videoURLForCampaign:self.selectedCampaign];
	if (videoURL == nil)
	{
		NSLog(@"Video not found!");
		return;
	}
	
	AVPlayerItem *item = [AVPlayerItem playerItemWithURL:videoURL];
	self.player = [AVPlayer playerWithPlayerItem:item];
	self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
	self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	self.playerLayer.frame = self.adView.bounds;
	[self.adView.layer addSublayer:self.playerLayer];
	
	[self _displayProgressLabel];
	
	__block ApplifierImpactiOS4 *blockSelf = self;
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
	
	if ([self.delegate respondsToSelector:@selector(applifierImpactVideoStarted:)])
		[self.delegate applifierImpactVideoStarted:self];

	[self _logVideoAnalytics];
}

- (void)_videoPlaybackEnded:(NSNotification *)notification
{
	if ([self.delegate respondsToSelector:@selector(applifierImpactVideoCompleted:)])
		[self.delegate applifierImpactVideoCompleted:self];

	[self _logVideoAnalytics];
	
	[self.player removeTimeObserver:self.timeObserver];
	self.timeObserver = nil;
	[self.player removeTimeObserver:self.analyticsTimeObserver];
	self.analyticsTimeObserver = nil;
	
	self.progressLabel.hidden = YES;
	
	[self.playerLayer removeFromSuperlayer];

	[self _webViewVideoComplete];
}

- (void)_closeAdView
{
	if ([self.delegate respondsToSelector:@selector(applifierImpactWillClose:)])
		[self.delegate applifierImpactWillClose:self];

	[self.applifierWindow addSubview:self.webView];
	[self.adView removeFromSuperview];
	
	self.selectedCampaign = nil;
}

- (void)_startAnalyticsUploader
{
	self.analyticsUploader = [[ApplifierImpactAnalyticsUploader alloc] init];
	[self.analyticsUploader retryFailedUploads];
}

- (void)_webViewInit
{
	if (self.campaignJSON == nil || !self.webViewLoaded)
	{
		NSLog(@"JSON or web view has not been loaded yet.");
		return;
	}
	
	NSLog(@"init");
	
	NSString *js = [NSString stringWithFormat:@"%@(%@, %@, %@);", kApplifierImpactWebViewAPINativeInit, self.campaignJSON, [self _md5OpenUDIDString], [self _md5MACAddressString]];
	
	[self.webView stringByEvaluatingJavaScriptFromString:js];
	
	self.webViewInitialized = YES;
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
			NSLog(@"No parameters given.");
			return;
		}
		
		if ([queryComponents count] == 2)
		{
			NSString *parameter = [queryComponents objectAtIndex:0];
			NSString *value = [queryComponents objectAtIndex:1];
			
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
	}
	else if ([command isEqualToString:kApplifierImpactWebViewAPIClose])
	{
		[self _closeAdView];
	}
}

- (void)_openURL:(NSString *)urlString
{
	NSLog(@"_openURL: TODO");
}

#pragma mark - Public

- (void)startWithApplifierID:(NSString *)applifierID
{
	if (self.campaignManager != nil)
		return;
	
	self.applifierID = applifierID;
	self.cacheThread = [[NSThread alloc] initWithTarget:self selector:@selector(_backgroundRunLoop:) object:nil];
	[self.cacheThread start];
	self.analyticsThread = [[NSThread alloc] initWithTarget:self selector:@selector(_backgroundRunLoop:) object:nil];
	[self.analyticsThread start];
	
	[self performSelector:@selector(_startCampaignManager) onThread:self.cacheThread withObject:nil waitUntilDone:NO];
	[self performSelector:@selector(_startAnalyticsUploader) onThread:self.analyticsThread withObject:nil waitUntilDone:NO];
	
	[self _configureWebView];
}

- (BOOL)showImpact
{
	// FIXME: probably not the best way to accomplish this
	
	if ([self.campaigns count] > 0 && self.webViewLoaded && self.webView.superview == self.applifierWindow)
	{
		[self _webViewShow];
		
		// merge the following two delegate methods?
		if ([self.delegate respondsToSelector:@selector(applifierImpactWillOpen:)])
			[self.delegate applifierImpactWillOpen:self];
		
		if ([self.delegate respondsToSelector:@selector(applifierImpact:wantsToShowAdView:)])
			[self.delegate applifierImpact:self wantsToShowAdView:[self _adView]];
		
		return YES;
	}
	
	return NO;
}

- (BOOL)hasCampaigns
{
	return ([self.campaigns count] > 0);
}

- (void)stopAll
{
	[self.campaignManager performSelector:@selector(cancelAllDownloads) onThread:self.cacheThread withObject:nil waitUntilDone:NO];
}

- (void)dealloc
{
	self.campaignManager.delegate = nil;
}

#pragma mark - ApplifierImpactCampaignManagerDelegate

- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager updatedWithCampaigns:(NSArray *)campaigns rewardItem:(ApplifierImpactRewardItem *)rewardItem
{
	if ( ! [NSThread isMainThread])
	{
		NSLog(@"Method must be run on main thread.");
		return;
	}
	
	self.campaigns = campaigns;
	self.rewardItem = rewardItem;
	
	if ([self.delegate respondsToSelector:@selector(applifierImpactCampaignsAreAvailable:)])
		[self.delegate applifierImpactCampaignsAreAvailable:self];
}

- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager downloadedJSON:(NSString *)json
{
	self.campaignJSON = json;
	
	if (self.webViewLoaded)
		[self _webViewInit];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = [request URL];
	if ([[url scheme] isEqualToString:@"applifier-impact"])
	{
		[self _processWebViewResponseWithHost:[url host] query:[url query]];
		
		return NO;
	}
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	self.webViewLoaded = YES;
	
	if ( ! self.webViewInitialized)
		[self _webViewInit];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
}

@end
