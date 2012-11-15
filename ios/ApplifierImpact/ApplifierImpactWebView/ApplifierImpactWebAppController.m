//
//  ApplifierImpactWebAppController.m
//  ApplifierImpact
//
//  Created by bluesun on 10/23/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactWebAppController.h"
#import "../ApplifierImpact.h"
#import "../ApplifierImpactURLProtocol/ApplifierImpactURLProtocol.h"
#import "../ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "../ApplifierImpactSBJSON/ApplifierImpactSBJsonWriter.h"
#import "../ApplifierImpactSBJSON/NSObject+ApplifierImpactSBJson.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "../ApplifierImpactViewManager.h"

NSString * const kApplifierImpactWebViewPrefix = @"applifierimpact.";
NSString * const kApplifierImpactWebViewJSInit = @"init";
NSString * const kApplifierImpactWebViewJSChangeView = @"setView";
NSString * const kApplifierImpactWebViewAPIPlayVideo = @"playVideo";
NSString * const kApplifierImpactWebViewAPINavigateTo = @"navigateTo";
NSString * const kApplifierImpactWebViewAPIInitComplete = @"initComplete";
NSString * const kApplifierImpactWebViewAPIClose = @"close";
NSString * const kApplifierImpactWebViewAPIAppStore = @"appStore";

NSString * const kApplifierImpactWebViewViewTypeCompleted = @"completed";
NSString * const kApplifierImpactWebViewViewTypeStart = @"start";

@interface ApplifierImpactWebAppController ()
  @property (nonatomic, strong) NSDictionary* webAppInitalizationParams;
@end

@implementation ApplifierImpactWebAppController

- (ApplifierImpactWebAppController *)init {
  return [super init];
}

static ApplifierImpactWebAppController *sharedImpactWebAppController = nil;

+ (id)sharedInstance {
	@synchronized(self) {
		if (sharedImpactWebAppController == nil)
      sharedImpactWebAppController = [[ApplifierImpactWebAppController alloc] init];
	}
	
	return sharedImpactWebAppController;
}

- (void)setup:(CGRect)frame webAppParams:(NSDictionary *)webAppParams {
  _webAppInitalizationParams = webAppParams;
  self.webView = [[UIWebView alloc] initWithFrame:frame];
  self.webView.delegate = self;
  self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
	self.webViewLoaded = NO;
	self.webViewInitialized = NO;

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
  
  [NSURLProtocol registerClass:[ApplifierImpactURLProtocol class]];
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[ApplifierImpactProperties sharedInstance] webViewBaseUrl]]]];
}

- (void)setWebViewCurrentView:(NSString *)view data:(NSDictionary *)data
{
  [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@%@(\"%@\", %@);", kApplifierImpactWebViewPrefix, kApplifierImpactWebViewJSChangeView, view, [data JSONRepresentation]]];
}

- (void)handleWebEvent:(NSString *)type data:(NSDictionary *)data {
  AILOG_DEBUG(@"Gotevent: %@  widthData: %@", type, data);
  
  if ([type isEqualToString:kApplifierImpactWebViewAPIPlayVideo] || [type isEqualToString:kApplifierImpactWebViewAPINavigateTo] || [type isEqualToString:kApplifierImpactWebViewAPIAppStore])
	{
		if ([type isEqualToString:kApplifierImpactWebViewAPIPlayVideo]) {
      if ([data objectForKey:@"campaignId"] != nil) {
        [self _selectCampaignWithID:[data objectForKey:@"campaignId"]];
        [[ApplifierImpactViewManager sharedInstance] showPlayerAndPlaySelectedVideo];
      }
		}
		else if ([type isEqualToString:kApplifierImpactWebViewAPINavigateTo]) {
      if ([data objectForKey:@"clickUrl"] != nil) {
        [self openExternalUrl:[data objectForKey:@"clickUrl"]];
      }
    
		}
		else if ([type isEqualToString:kApplifierImpactWebViewAPIAppStore]) {
      if ([data objectForKey:@"clickUrl"] != nil) {
        [[ApplifierImpactViewManager sharedInstance] openAppStoreWithGameId:[data objectForKey:@"clickUrl"]];
      }    
		}
	}
	else if ([type isEqualToString:kApplifierImpactWebViewAPIClose]) {
    [[ApplifierImpactViewManager sharedInstance] closeAdView];
	}
	else if ([type isEqualToString:kApplifierImpactWebViewAPIInitComplete]) {
    self.webViewInitialized = YES;
    
    if (self.delegate != nil) {
      [self.delegate webAppReady];
    }
	}
}

- (void)_selectCampaignWithID:(NSString *)campaignId {
	[[ApplifierImpactCampaignManager sharedInstance] setSelectedCampaign:nil];
	
	if (campaignId == nil) {
		AILOG_DEBUG(@"Input is nil.");
		return;
	}
  
	ApplifierImpactCampaign *campaign = [[ApplifierImpactCampaignManager sharedInstance] getCampaignWithId:campaignId];
	
	if (campaign != nil) {
		[[ApplifierImpactCampaignManager sharedInstance] setSelectedCampaign:campaign];
	}
	else
		AILOG_DEBUG(@"No campaign with id '%@' found.", campaignId);
}

- (void)openExternalUrl:(NSString *)urlString {
	if (urlString == nil) {
		AILOG_DEBUG(@"No URL set.");
		return;
	}
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}


#pragma mark - WebView

- (void)initWebAppWithValues:(NSDictionary *)values {
	NSString *js = [NSString stringWithFormat:@"%@%@(%@);", kApplifierImpactWebViewPrefix, kApplifierImpactWebViewJSInit, [values JSONRepresentation]];
  AILOG_DEBUG(@"%@", js);
	[self.webView stringByEvaluatingJavaScriptFromString:js];
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *url = [request URL];
	AILOG_DEBUG(@"url %@", url);
	
  if ([[url scheme] isEqualToString:@"itms-apps"]) {
		return NO;
	}
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	AILOG_DEBUG(@"");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	AILOG_DEBUG(@"%@", _webAppInitalizationParams);
	
	self.webViewLoaded = YES;
	
	if (!self.webViewInitialized)
		[self initWebAppWithValues:_webAppInitalizationParams];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	AILOG_DEBUG(@"%@", error);
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
}

@end