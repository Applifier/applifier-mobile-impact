//
//  ApplifierImpactiOS4.m
//  ImpactProto
//
//  Created by Johan Halin on 9/4/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ApplifierImpactiOS4.h"
#import "ApplifierImpactCampaignManager.h"
#import "ApplifierImpactCampaign.h"
#import "ApplifierImpactRewardItem.h"

NSString * const kApplifierImpactTestWebViewURL = @"http://quake.everyplay.fi/~bluesun/impact/webapp.html";

typedef enum
{
	kVideoAnalyticsPositionStart = 0,
	kVideoAnalyticsPositionFirstQuartile,
	kVideoAnalyticsPositionMidPoint,
	kVideoAnalyticsPositionThirdQuartile,
	kVideoAnalyticsPositionEnd,
} VideoAnalyticsPosition;

@interface ApplifierImpactiOS4 () <ApplifierImpactCampaignManagerDelegate, UIWebViewDelegate>
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

#pragma mark - Private

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

- (void)_selectCampaign:(ApplifierImpactCampaign *)campaign
{
	if (campaign == nil)
		return;
	
	self.selectedCampaign = campaign;
	
	NSString *js = [NSString stringWithFormat:@"selectCampaign(%@);", campaign.id];
	
	[self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)_configureWebView
{
	self.applifierWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.webView = [[UIWebView alloc] initWithFrame:self.applifierWindow.bounds];
	self.webView.delegate = self;
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
	
	NSLog(@"TODO ViewReport: %@", positionString);
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
	
	self.videoPosition = -1;
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
	
	[self.player removeTimeObserver:self.timeObserver];
	self.timeObserver = nil;
	[self.player removeTimeObserver:self.analyticsTimeObserver];
	self.analyticsTimeObserver = nil;
	
	self.progressLabel.hidden = YES;
	
	[self.playerLayer removeFromSuperlayer];
	// FIXME: use the actual API
	[self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('videoStart').style.display = 'none';"];
	[self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('videoCompleted').style.display = 'block';"];
}

- (void)_closeAdView
{
	if ([self.delegate respondsToSelector:@selector(applifierImpactWillClose:)])
		[self.delegate applifierImpactWillClose:self];

	[self.applifierWindow addSubview:self.webView];
	[self.adView removeFromSuperview];
}

#pragma mark - Public

- (void)startWithApplifierID:(NSString *)applifierID
{
	if (self.campaignManager != nil)
		return;
	
	self.applifierID = applifierID;
	self.backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(_backgroundRunLoop:) object:nil];
	[self.backgroundThread start];
	
	[self performSelector:@selector(_startCampaignManager) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];

	[self _configureWebView];
}

- (BOOL)showImpact
{
	// FIXME: probably not the best way to accomplish this
	
	if ([self.campaigns count] > 0)
	{
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
	
	[self _selectCampaign:[self.campaigns lastObject]];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	// FIXME: this is test code
	NSString *urlString = [[request URL] absoluteString];
	if ([[urlString substringFromIndex:[urlString length] - 1] isEqualToString:@"#"])
	{
		[self _playVideo];
		return NO;
	}
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

@end
