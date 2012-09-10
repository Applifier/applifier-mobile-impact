//
//  ApplifierImpactiOS4.m
//  ImpactProto
//
//  Created by Johan Halin on 9/4/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactiOS4.h"
#import "ApplifierImpactCampaignManager.h"
#import "ApplifierImpactCampaign.h"
#import "ApplifierImpactRewardItem.h"

NSString * const kApplifierImpactTestWebViewURL = @"http://quake.everyplay.fi/~bluesun/impact/webapp.html";

@interface ApplifierImpactiOS4 () <ApplifierImpactCampaignManagerDelegate, UIWebViewDelegate>
@property (nonatomic, strong) NSString *applifierID;
@property (nonatomic, strong) NSThread *backgroundThread;
@property (nonatomic, strong) ApplifierImpactCampaignManager *campaignManager;
@property (nonatomic, strong) UIWindow *applifierWindow;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSArray *campaigns;
@property (nonatomic, strong) ApplifierImpactRewardItem *rewardItem;
@end

@implementation ApplifierImpactiOS4

@synthesize applifierID = _applifierID;
@synthesize backgroundThread = _backgroundThread;
@synthesize campaignManager = _campaignManager;
@synthesize applifierWindow = _applifierWindow;
@synthesize webView = _webView;

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

#pragma mark - Public

- (void)startWithApplifierID:(NSString *)applifierID
{
	if (self.campaignManager != nil)
		return;
	
	self.applifierID = applifierID;
	self.backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(_backgroundRunLoop:) object:nil];
	[self.backgroundThread start];
	
	[self performSelector:@selector(_startCampaignManager) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
	
	self.applifierWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.webView = [[UIWebView alloc] initWithFrame:self.applifierWindow.bounds];
	self.webView.delegate = self;
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kApplifierImpactTestWebViewURL]]];
	[self.applifierWindow addSubview:self.webView];
}

- (BOOL)showImpact
{
	return YES;
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
	
	NSLog(@"updatedWithCampaigns");
	
	self.campaigns = campaigns;
	self.rewardItem = rewardItem;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
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
