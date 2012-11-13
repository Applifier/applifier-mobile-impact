//
//  ApplifierImpactWebAppController.m
//  ApplifierImpact
//
//  Created by bluesun on 10/23/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactWebAppController.h"
#import "../ApplifierImpact.h"
#import "../ApplifierImpactUtils/ApplifierImpactUtils.h"
#import "../ApplifierImpactURLProtocol/ApplifierImpactURLProtocol.h"
#import "../ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "../ApplifierImpactSBJSON/ApplifierImpactSBJsonWriter.h"
#import "../ApplifierImpactSBJSON/NSObject+ApplifierImpactSBJson.h"



@interface ApplifierImpactWebAppController ()
  @property (nonatomic, strong) NSDictionary* webAppInitalizationParams;
@end

@implementation ApplifierImpactWebAppController

- (ApplifierImpactWebAppController *)init {
  
  self.WEBVIEW_PREFIX = @"applifierimpact.";
  self.WEBVIEW_JS_INIT = @"init";
  self.WEBVIEW_JS_CHANGEVIEW = @"setView";
  self.WEBVIEW_API_PLAYVIDEO = @"playVideo";
  self.WEBVIEW_API_NAVIGATETO = @"navigateTo";
  self.WEBVIEW_API_INITCOMPLETE = @"initComplete";
  self.WEBVIEW_API_CLOSE = @"close";
  self.WEBVIEW_API_APPSTORE = @"appstore";
  
  return [super init];
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

- (void)setWebViewCurrentView:(NSString *)view data:(NSString *)data
{
  [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@%@(\"%@\", %@);", self.WEBVIEW_PREFIX, self.WEBVIEW_JS_CHANGEVIEW, view, data]];
}

#pragma mark - WebView

- (void)initWebAppWithValues:(NSDictionary *)values {
  
  /*
  NSMutableDictionary *deviceInformation = [[NSMutableDictionary init] alloc];
  [deviceInformation setValue:[values valueForKey:@"deviceId"] forKey:@"deviceId"];
  AILOG_DEBUG(@"%@", [deviceInformation JSONRepresentation]);*/
  
  
  
  //NSString *escapedJSON = [ApplifierImpactUtils escapedStringFromString:[values valueForKey:@"campaignJSON"]];
	
  /*
  NSString *deviceInformation = nil;
  NSString *md5AdvertisingTrackingID = [values valueForKey:@"advertisingTrackingID"];
  NSString *iOSVersion = [values valueForKey:@"iOSVersion"];
  NSString *deviceType = [values valueForKey:@"deviceType"];
  NSString *deviceId = [values valueForKey:@"deviceId"];
  NSString *md5OpenUDID = [values valueForKey:@"openUdid"];
  NSString *md5MACAddress = [values valueForKey:@"macAddress"];
	*/
  
  /*
  if (md5AdvertisingTrackingID != nil) {
		//deviceInformation = [NSString stringWithFormat:@"{\"deviceId\":\"%@\",\"advertisingTrackingID\":\"%@\",\"iOSVersion\":\"%@\",\"deviceType\":\"%@\"}",  deviceId, md5AdvertisingTrackingID, iOSVersion, deviceType];
  }
	else {
		//deviceInformation = [NSString stringWithFormat:@"{\"deviceId\":\"%@\",\"iOSVersion\":\"%@\",\"deviceType\":\"%@\",\"macAddress\":\"%@\",\"openUdid\":\"%@\"}", deviceId, [[UIDevice currentDevice] systemVersion], deviceType, md5MACAddress, md5OpenUDID];
  }
	*/
  
	NSString *js = [NSString stringWithFormat:@"%@%@(%@);", self.WEBVIEW_PREFIX, self.WEBVIEW_JS_INIT, [values JSONRepresentation]];
  AILOG_DEBUG(@"%@", js);
	[self.webView stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = [request URL];
	AILOG_DEBUG(@"url %@", url);
	
  if ([[url scheme] isEqualToString:@"itms-apps"])
	{
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
	AILOG_DEBUG(@"%@", _webAppInitalizationParams);
	
	self.webViewLoaded = YES;
	
	if (!self.webViewInitialized)
		[self initWebAppWithValues:_webAppInitalizationParams];
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
