//
//  ApplifierImpactWebAppController.h
//  ApplifierImpact
//
//  Created by bluesun on 10/23/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ApplifierImpactWebAppController : NSObject <UIWebViewDelegate, UIScrollViewDelegate>
@property (nonatomic, assign) NSString* WEBVIEW_URL;
@property (nonatomic, assign) NSString* WEBVIEW_PREFIX;
@property (nonatomic, assign) NSString* WEBVIEW_JS_INIT;
@property (nonatomic, assign) NSString* WEBVIEW_JS_CHANGEVIEW;
@property (nonatomic, assign) NSString* WEBVIEW_API_PLAYVIDEO;
@property (nonatomic, assign) NSString* WEBVIEW_API_CLOSE;
@property (nonatomic, assign) NSString* WEBVIEW_API_NAVIGATETO;
@property (nonatomic, assign) NSString* WEBVIEW_API_INITCOMPLETE;
@property (nonatomic, assign) NSString* WEBVIEW_API_APPSTORE;

@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic, assign) BOOL webViewLoaded;
@property (nonatomic, assign) BOOL webViewInitialized;

- (void)setWebViewCurrentView:(NSString *)view data:(NSString *)data;
- (void)setup:(CGRect)frame webAppParams:(NSDictionary *)webAppParams;
@end
