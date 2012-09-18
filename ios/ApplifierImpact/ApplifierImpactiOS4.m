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
NSString * const kApplifierImpactTestWebViewURL = @"https://dl.dropbox.com/u/3542608/protos/impact-mobile-proto/index.html";

NSString * const kApplifierImpactWebViewAPINativeInit = @"impactInit";
NSString * const kApplifierImpactWebViewAPINativeShow = @"impactShow";
NSString * const kApplifierImpactWebViewAPINativeVideoComplete = @"impactVideoComplete";
NSString * const kApplifierImpactWebViewAPIPlayVideo = @"playvideo";
NSString * const kApplifierImpactWebViewAPIClose = @"close";
NSString * const kApplifierImpactWebViewAPINavigateTo = @"navigateto";
NSString * const kApplifierImpactWebViewAPIInitComplete = @"initcomplete";

NSString * const kApplifierImpactVersion = @"1.0";

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
@property (nonatomic, strong) NSThread *backgroundThread;
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
@synthesize backgroundThread = _backgroundThread;
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

- (NSString *)_machineName
{
	size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *answer = malloc(size);
	sysctlbyname("hw.machine", answer, &size, NULL, 0);
	NSString *result = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	free(answer);
	
	return result;
}

- (NSString *)_substringOfString:(NSString *)string toIndex:(NSInteger)index
{
	if (index > [string length])
		return nil;
	
	return [string substringToIndex:index];
}

- (NSString *)_analyticsMachineName
{
	NSString *machine = [self _machineName];
	if ([machine isEqualToString:@"iPhone1,1"])
		return @"iphone";
	else if ([machine isEqualToString:@"iPhone1,2"])
		return @"iphone3g";
	else if ([machine isEqualToString:@"iPhone2,1"])
		return @"iphone3gs";
	else if ([[self _substringOfString:machine toIndex:7] isEqualToString:@"iPhone3"])
		return @"iphone4";
	else if ([[self _substringOfString:machine toIndex:7] isEqualToString:@"iPhone4"])
		return @"iphone4s";
	else if ([[self _substringOfString:machine toIndex:7] isEqualToString:@"iPhone5"])
		return @"iphone5";
	else if ([machine isEqualToString:@"iPod1,1"])
		return @"ipodtouch1gen";
	else if ([machine isEqualToString:@"iPod2,1"])
		return @"ipodtouch2gen";
	else if ([machine isEqualToString:@"iPod3,1"])
		return @"ipodtouch3gen";
	else if ([machine isEqualToString:@"iPod4,1"])
		return @"ipodtouch4gen";
	else if ([[self _substringOfString:machine toIndex:5] isEqualToString:@"iPad1"])
		return @"ipad1";
	else if ([[self _substringOfString:machine toIndex:5] isEqualToString:@"iPad2"])
		return @"ipad2";
	else if ([[self _substringOfString:machine toIndex:5] isEqualToString:@"iPad3"])
		return @"ipad3";
    
	return @"iosUnknown";
}

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
		AILOG_DEBUG(@"Couldn't get MAC address for interface '%@', if_nametoindex failed.", interface);
		return nil;
	}
	
	size_t length;
	
	// Get the size of the data available (store in len)
	if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
	{
		AILOG_DEBUG(@"Couldn't get MAC address for interface '%@', sysctl for mgmtInfoBase length failed.", interface);
		return nil;
	}
	
	// Alloc memory based on above call
	if ((msgBuffer = malloc(length)) == NULL)
	{
		AILOG_DEBUG(@"Couldn't get MAC address for interface '%@', malloc for %zd bytes failed.", interface, length);
		return nil;
	}
	
	// Get system information, store in buffer
	if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
	{
		free(msgBuffer);
		
		AILOG_DEBUG(@"Couldn't get MAC address for interface '%@', sysctl for mgmtInfoBase data failed.", interface);
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

- (NSString *)_currentConnectionType
{
	// FIXME: find out where to get this
	return @"TODO";
}

- (NSString *)_queryString
{
	return [NSString stringWithFormat:@"?openUdid=%@&macAddress=%@&iosVersion=%@&device=%@&sdkVersion=%@&gameId=%@&type=ios&connection=%@", [self _md5OpenUDIDString], [self _md5MACAddressString], [[UIDevice currentDevice] systemVersion], [self _analyticsMachineName], kApplifierImpactVersion, self.applifierID, [self _currentConnectionType]];
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
	{
		scrollView.delegate = self;
		scrollView.showsVerticalScrollIndicator = NO;
	}
	
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kApplifierImpactTestWebViewURL]]];
	[self.applifierWindow addSubview:self.webView];
}

- (UIView *)_adView
{
	if (self.adView == nil)
	{
		self.adView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

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
	
	if (self.webView.superview != self.adView)
	{
		self.webView.bounds = self.adView.bounds;
		[self.adView addSubview:self.webView];
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
		positionString = @"video_start";
	else if (self.videoPosition == kVideoAnalyticsPositionFirstQuartile)
		positionString = @"first_quartile";
	else if (self.videoPosition == kVideoAnalyticsPositionMidPoint)
		positionString = @"mid_point";
	else if (self.videoPosition == kVideoAnalyticsPositionThirdQuartile)
		positionString = @"third_quartile";
	else if (self.videoPosition == kVideoAnalyticsPositionEnd)
		positionString = @"video_end";
	
	[self performSelector:@selector(_logPositionString:) onThread:self.backgroundThread withObject:positionString waitUntilDone:NO];
}

- (void)_playVideo
{
	NSURL *videoURL = [self.campaignManager videoURLForCampaign:self.selectedCampaign];
	if (videoURL == nil)
	{
		AILOG_DEBUG(@"Video not found!");
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

	self.selectedCampaign.viewed = YES;
	self.selectedCampaign = nil;
}

- (void)_closeAdView
{
	if ([self.delegate respondsToSelector:@selector(applifierImpactWillClose:)])
		[self.delegate applifierImpactWillClose:self];

	[self.applifierWindow addSubview:self.webView];
	[self.adView removeFromSuperview];
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
		AILOG_DEBUG(@"JSON or web view has not been loaded yet.");
		return;
	}
	
	AILOG_DEBUG(@"");
	
	NSString *escapedJSON = [self.campaignJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
	escapedJSON = [escapedJSON stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
	NSString *js = [NSString stringWithFormat:@"%@(\"%@\",\"%@\",\"%@\");", kApplifierImpactWebViewAPINativeInit, escapedJSON, [self _md5OpenUDIDString], [self _md5MACAddressString]];
	
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

- (void)_webViewInitComplete
{
	self.webViewInitialized = YES;
	
	[self _notifyDelegateOfCampaignAvailability];
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
		__block ApplifierImpactiOS4 *blockSelf = self;
		__block id storeController = [[[storeProductViewControllerClass class] alloc] init];
		NSDictionary *productParameters = @{ SKStoreProductParameterITunesItemIdentifier : gameID };
		[storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
			if (result)
			{
				if ([blockSelf.delegate respondsToSelector:@selector(applifierImpact:wantsToPresentProductViewController:)])
					[blockSelf.delegate applifierImpact:blockSelf wantsToPresentProductViewController:storeController];
			}
			else
				AILOG_DEBUG(@"Loading product information failed: %@", error);
		}];
	}
	else
		AILOG_DEBUG(@"Not supported on older versions of iOS.");
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
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)_notifyDelegateOfCampaignAvailability
{
	if (self.campaigns != nil && self.rewardItem != nil && self.webViewInitialized)
	{
		if ([self.delegate respondsToSelector:@selector(applifierImpactCampaignsAreAvailable:)])
			[self.delegate applifierImpactCampaignsAreAvailable:self];
	}
}

#pragma mark - Public

- (void)startWithApplifierID:(NSString *)applifierID
{
	if ( ! [NSThread isMainThread])
	{
		AILOG_ERROR(@"-startWithApplifierID: must be run on main thread.");
		return;
	}
	
	if (self.applifierID != nil)
		return;
	
	self.applifierID = applifierID;
	self.backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(_backgroundRunLoop:) object:nil];
	[self.backgroundThread start];
	
	[self performSelector:@selector(_startCampaignManager) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
	[self performSelector:@selector(_startAnalyticsUploader) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
	
	[self _configureWebView];
}

- (BOOL)showImpact
{
	if ( ! [NSThread isMainThread])
	{
		AILOG_ERROR(@"-showImpact must be run on main thread.");
		return NO;
	}
	
	// FIXME: probably not the best way to accomplish this
	
	if ([self.campaigns count] > 0 && self.webViewInitialized && self.webView.superview == self.applifierWindow)
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
	if ( ! [NSThread isMainThread])
	{
		AILOG_ERROR(@"-hasCampaigns must be run on main thread.");
		return NO;
	}

	return ([self.campaigns count] > 0 && self.webViewInitialized);
}

- (void)stopAll
{
	if ( ! [NSThread isMainThread])
	{
		AILOG_ERROR(@"-stopAll must be run on main thread.");
		return;
	}
	
	[self.campaignManager performSelector:@selector(cancelAllDownloads) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
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
		AILOG_ERROR(@"Method must be run on main thread.");
		return;
	}
	
	self.campaigns = campaigns;
	self.rewardItem = rewardItem;

	[self _notifyDelegateOfCampaignAvailability];
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
