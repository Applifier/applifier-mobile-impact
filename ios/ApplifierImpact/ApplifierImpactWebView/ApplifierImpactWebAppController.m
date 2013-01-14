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
#import "../ApplifierImpactMainViewController.h"
#import "../ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"

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
        [self _selectCampaignWithID:[data objectForKey:kApplifierImpactWebViewEventDataCampaignIdKey]];
        BOOL checkIfWatched = YES;
        if ([data objectForKey:kApplifierImpactWebViewEventDataRewatchKey] != nil && [[data valueForKey:kApplifierImpactWebViewEventDataRewatchKey] boolValue] == true) {
          checkIfWatched = NO;
        }
        
        [[ApplifierImpactMainViewController sharedInstance] showPlayerAndPlaySelectedVideo:checkIfWatched];
      }
		}
		else if ([type isEqualToString:kApplifierImpactWebViewAPINavigateTo]) {
      if ([data objectForKey:kApplifierImpactWebViewEventDataClickUrlKey] != nil) {
        [self openExternalUrl:[data objectForKey:kApplifierImpactWebViewEventDataClickUrlKey]];
      }
    
		}
		else if ([type isEqualToString:kApplifierImpactWebViewAPIAppStore]) {
      if ([data objectForKey:kApplifierImpactWebViewEventDataClickUrlKey] != nil) {
        [[ApplifierImpactMainViewController sharedInstance] openAppStoreWithData:data];
      }    
		}
	}
	else if ([type isEqualToString:kApplifierImpactWebViewAPIClose]) {
    [[ApplifierImpactMainViewController sharedInstance] closeImpact:YES withAnimations:YES];
	}
	else if ([type isEqualToString:kApplifierImpactWebViewAPIInitComplete]) {
    self.webViewInitialized = YES;
    
    if (self.delegate != nil) {
      [self.delegate webAppReady];
    }
	}
}

- (void)runJavascriptDependingOnPlatform:(NSString *)javaScriptString {
  if (![ApplifierImpactDevice isSimulator]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self runJavascript:javaScriptString];
    });
  }
  else {
    [self runJavascript:javaScriptString];
  }
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
  
  NSDictionary *persistingData = @{kApplifierImpactWebViewDataParamCampaignDataKey:[[ApplifierImpactCampaignManager sharedInstance] campaignData], kApplifierImpactWebViewDataParamPlatformKey:@"ios", kApplifierImpactWebViewDataParamDeviceIdKey:[ApplifierImpactDevice md5DeviceId], kApplifierImpactWebViewDataParamOpenUdidIdKey:[ApplifierImpactDevice md5OpenUDIDString], kApplifierImpactWebViewDataParamMacAddressKey:[ApplifierImpactDevice md5MACAddressString], kApplifierImpactWebViewDataParamSdkVersionKey:[[ApplifierImpactProperties sharedInstance] impactVersion], kApplifierImpactWebViewDataParamGameIdKey:[[ApplifierImpactProperties sharedInstance] impactGameId]};
  
  NSDictionary *trackingData = @{kApplifierImpactWebViewDataParamIosVersionKey:[ApplifierImpactDevice softwareVersion], kApplifierImpactWebViewDataParamDeviceTypeKey:[ApplifierImpactDevice analyticsMachineName]};
  NSMutableDictionary *webAppValues = [NSMutableDictionary dictionaryWithDictionary:persistingData];
  
  if ([ApplifierImpactDevice canUseTracking]) {
    [webAppValues addEntriesFromDictionary:trackingData];
  }
  
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