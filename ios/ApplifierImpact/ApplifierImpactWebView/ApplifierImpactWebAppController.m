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
#import "../ApplifierImpactSBJSON/ApplifierImpactSBJsonWriter.h"
#import "../ApplifierImpactSBJSON/NSObject+ApplifierImpactSBJson.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "../ApplifierImpactDevice/ApplifierImpactDevice.h"
#import "../ApplifierImpactView/ApplifierImpactMainViewController.h"
#import "../ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"
#import "../ApplifierImpactZone/ApplifierImpactZoneManager.h"

@interface ApplifierImpactWebAppController ()
  @property (nonatomic, strong) NSDictionary* webAppInitalizationParams;
@end

@implementation ApplifierImpactWebAppController

- (ApplifierImpactWebAppController *)init {
  if (self = [super init]) {
  }
  return self;
}

static ApplifierImpactWebAppController *sharedImpactWebAppController = nil;

+ (id)sharedInstance {
	@synchronized(self) {
		if (sharedImpactWebAppController == nil) {
      sharedImpactWebAppController = [[ApplifierImpactWebAppController alloc] init];
      [sharedImpactWebAppController setWebViewInitialized:NO];
      [sharedImpactWebAppController setWebViewLoaded:NO];
    }
	}
	
	return sharedImpactWebAppController;
}

- (void)loadWebApp:(NSDictionary *)webAppParams {
	self.webViewLoaded = NO;
	self.webViewInitialized = NO;
  _webAppInitalizationParams = webAppParams;
  [NSURLProtocol registerClass:[ApplifierImpactURLProtocol class]];
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[ApplifierImpactProperties sharedInstance] webViewBaseUrl]]]];
}

- (void)setupWebApp:(CGRect)frame {  
  if (self.webView == nil) {
    self.webView = [[UIWebView alloc] initWithFrame:frame];
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.scalesPageToFit = NO;
    [self.webView setBackgroundColor:[UIColor blackColor]];
    UIScrollView *scrollView = nil;
    
    if ([self.webView respondsToSelector:@selector(scrollView)]) {
      scrollView = self.webView.scrollView;
    }
    else {
      UIView *view = [self.webView.subviews lastObject];
      if ([view isKindOfClass:[UIScrollView class]])
        scrollView = (UIScrollView *)view;
    }
    
    if (scrollView != nil) {
      scrollView.delegate = self;
      scrollView.showsVerticalScrollIndicator = NO;
    }
  }
}

- (void)setWebViewCurrentView:(NSString *)view data:(NSDictionary *)data {
	NSString *js = [NSString stringWithFormat:@"%@%@(\"%@\", %@);", kApplifierImpactWebViewJSPrefix, kApplifierImpactWebViewJSChangeView, view, [data JSONRepresentation]];
  
  AILOG_DEBUG(@"");
  [self runJavascriptDependingOnPlatform:js];
}

- (void)sendNativeEventToWebApp:(NSString *)eventType data:(NSDictionary *)data {
 	NSString *js = [NSString stringWithFormat:@"%@%@(\"%@\", %@);", kApplifierImpactWebViewJSPrefix, kApplifierImpactWebViewJSHandleNativeEvent, eventType, [data JSONRepresentation]];
  
  AILOG_DEBUG(@"");
  [self runJavascriptDependingOnPlatform:js];
}

- (void)handleWebEvent:(NSString *)type data:(NSDictionary *)data {
  AILOG_DEBUG(@"Gotevent: %@ withData: %@", type, data);
  
  if ([type isEqualToString:kApplifierImpactWebViewAPIPlayVideo] || [type isEqualToString:kApplifierImpactWebViewAPINavigateTo] || [type isEqualToString:kApplifierImpactWebViewAPIAppStore])
	{
		if ([type isEqualToString:kApplifierImpactWebViewAPIPlayVideo]) {
      if ([data objectForKey:kApplifierImpactWebViewEventDataCampaignIdKey] != nil) {
        if ([[[ApplifierImpactMainViewController sharedInstance] getCurrentViewState] getStateType] != kApplifierImpactViewStateTypeVideoPlayer &&
            ![[ApplifierImpactMainViewController sharedInstance] isClosing]) {
          [self _selectCampaignWithID:[data objectForKey:kApplifierImpactWebViewEventDataCampaignIdKey]];
          [[ApplifierImpactMainViewController sharedInstance] changeState:kApplifierImpactViewStateTypeVideoPlayer withOptions:data];
        }
        else {
           AILOG_DEBUG(@"Cannot start video: %i, %i", [[ApplifierImpactMainViewController sharedInstance] isClosing], [[[ApplifierImpactMainViewController sharedInstance] getCurrentViewState] getStateType]);
        }
      }
		}
		else if ([type isEqualToString:kApplifierImpactWebViewAPINavigateTo]) {
      if ([data objectForKey:kApplifierImpactWebViewEventDataClickUrlKey] != nil) {
        [self openExternalUrl:[data objectForKey:kApplifierImpactWebViewEventDataClickUrlKey]];
      }
    
		}
		else if ([type isEqualToString:kApplifierImpactWebViewAPIAppStore]) {
      if ([data objectForKey:kApplifierImpactWebViewEventDataClickUrlKey] != nil) {
        [[ApplifierImpactMainViewController sharedInstance] applyOptionsToCurrentState:data];
      }    
		}
	}
	else if ([type isEqualToString:kApplifierImpactWebViewAPIClose]) {
    if ([[[ApplifierImpactMainViewController sharedInstance] getCurrentViewState] getStateType] != kApplifierImpactViewStateTypeVideoPlayer &&
        ![[ApplifierImpactMainViewController sharedInstance] isClosing]) {
      [[ApplifierImpactMainViewController sharedInstance] closeImpact:YES withAnimations:YES withOptions:nil];
    }
    else {
      AILOG_DEBUG(@"Preventing sending close from WebView: %i, %i", [[ApplifierImpactMainViewController sharedInstance] isClosing], [[[ApplifierImpactMainViewController sharedInstance] getCurrentViewState] getStateType]);
    }
	}
	else if ([type isEqualToString:kApplifierImpactWebViewAPIInitComplete]) {
    self.webViewInitialized = YES;
    
    if (self.delegate != nil) {
      [self.delegate webAppReady];
    }
	}
}

- (void)runJavascriptDependingOnPlatform:(NSString *)javaScriptString {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self runJavascript:javaScriptString];
    });
}

- (void)runJavascript:(NSString *)javaScriptString {
  NSString *returnValue = nil;
  
  if (javaScriptString != nil) {
    AILOG_DEBUG(@"Running JavaScriptString: %@", javaScriptString);
    returnValue = [self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
  }
  
  if (returnValue != nil) {
    if ([returnValue isEqualToString:@"true"]) {
      AILOG_DEBUG(@"JavaScript call successfull.");
    }
    else {
      AILOG_DEBUG(@"Got unexpected response when running javascript: %@", returnValue);
    }
  }
  else {
    AILOG_DEBUG(@"JavaScript call failed!");
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
	else {
    AILOG_DEBUG(@"No campaign with id '%@' found.", campaignId);
  }		
}

- (void)openExternalUrl:(NSString *)urlString {
	if (urlString == nil) {
		AILOG_DEBUG(@"No URL set.");
		return;
	}
	
  dispatch_async(dispatch_get_main_queue(), ^{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
  });
}


- (void)initWebApp {
  AIAssert([NSThread isMainThread]);
    
  NSMutableDictionary * webAppValues = [[NSMutableDictionary alloc] init];
    
  [webAppValues setValue: [[ApplifierImpactCampaignManager sharedInstance] campaignData] forKey:kApplifierImpactWebViewDataParamCampaignDataKey];
  [webAppValues setValue: @"ios"                                                         forKey:kApplifierImpactWebViewDataParamPlatformKey];
  [webAppValues setValue: [ApplifierImpactDevice md5DeviceId]                            forKey:kApplifierImpactWebViewDataParamDeviceIdKey];
  [webAppValues setValue: [ApplifierImpactDevice md5MACAddressString]                    forKey:kApplifierImpactWebViewDataParamMacAddressKey];
  [webAppValues setValue: [[ApplifierImpactProperties sharedInstance] impactVersion]     forKey:kApplifierImpactWebViewDataParamSdkVersionKey];
  [webAppValues setValue: [[ApplifierImpactProperties sharedInstance] impactGameId]      forKey:kApplifierImpactWebViewDataParamGameIdKey];
  [webAppValues setValue: [ApplifierImpactDevice softwareVersion]                        forKey:kApplifierImpactWebViewDataParamIosVersionKey];
  [webAppValues setValue: [ApplifierImpactDevice analyticsMachineName]                   forKey:kApplifierImpactWebViewDataParamDeviceTypeKey];
    
  [self setupWebApp:[[UIScreen mainScreen] bounds]];
  [self loadWebApp:webAppValues];
}

#pragma mark - WebView

- (void)initWebAppWithValues:(NSDictionary *)values {
	NSString *js = [NSString stringWithFormat:@"%@%@(%@);", kApplifierImpactWebViewJSPrefix, kApplifierImpactWebViewJSInit, [values JSONRepresentation]];
  AILOG_DEBUG(@"");
  [self runJavascript:js];
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
	AILOG_DEBUG(@"");
	
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