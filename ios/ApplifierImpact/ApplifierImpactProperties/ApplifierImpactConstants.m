//
//  ApplifierImpactConstants.m
//  ApplifierImpact
//
//  Created by bluesun on 1/10/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactConstants.h"


/* WebView */

NSString * const kApplifierImpactWebViewJSPrefix = @"applifierimpact.";
NSString * const kApplifierImpactWebViewJSInit = @"init";
NSString * const kApplifierImpactWebViewJSChangeView = @"setView";
NSString * const kApplifierImpactWebViewJSHandleNativeEvent = @"handleNativeEvent";

NSString * const kApplifierImpactWebViewAPIActionKey = @"action";
NSString * const kApplifierImpactWebViewAPIPlayVideo = @"playVideo";
NSString * const kApplifierImpactWebViewAPINavigateTo = @"navigateTo";
NSString * const kApplifierImpactWebViewAPIInitComplete = @"initComplete";
NSString * const kApplifierImpactWebViewAPIClose = @"close";
NSString * const kApplifierImpactWebViewAPIOpen = @"open";
NSString * const kApplifierImpactWebViewAPIDeveloperOptions = @"developerOptions";
NSString * const kApplifierImpactWebViewAPIAppStore = @"appStore";
NSString * const kApplifierImpactWebViewAPIActionVideoStartedPlaying = @"video_started_playing";

NSString * const kApplifierImpactWebViewViewTypeCompleted = @"completed";
NSString * const kApplifierImpactWebViewViewTypeStart = @"start";
NSString * const kApplifierImpactWebViewViewTypeNone = @"none";

NSString * const kApplifierImpactWebViewDataParamCampaignDataKey = @"campaignData";
NSString * const kApplifierImpactWebViewDataParamPlatformKey = @"platform";
NSString * const kApplifierImpactWebViewDataParamDeviceIdKey = @"deviceId";
NSString * const kApplifierImpactWebViewDataParamGameIdKey = @"gameId";
NSString * const kApplifierImpactWebViewDataParamDeviceTypeKey = @"deviceType";
NSString * const kApplifierImpactWebViewDataParamOpenUdidIdKey = @"openUdid";
NSString * const kApplifierImpactWebViewDataParamMacAddressKey = @"macAddress";
NSString * const kApplifierImpactWebViewDataParamSdkVersionKey = @"sdkVersion";
NSString * const kApplifierImpactWebViewDataParamIosVersionKey = @"iOSVersion";

NSString * const kApplifierImpactWebViewEventDataCampaignIdKey = @"campaignId";
NSString * const kApplifierImpactWebViewEventDataRewatchKey = @"rewatch";
NSString * const kApplifierImpactWebViewEventDataClickUrlKey = @"clickUrl";
NSString * const kApplifierImpactWebViewEventDataBypassAppSheetKey = @"bypassAppSheet";


/* Native Events */

NSString * const kApplifierImpactNativeEventHideSpinner = @"hideSpinner";
NSString * const kApplifierImpactNativeEventShowSpinner = @"showSpinner";
NSString * const kApplifierImpactNativeEventShowError = @"showError";
NSString * const kApplifierImpactNativeEventVideoCompleted = @"videoCompleted";
NSString * const kApplifierImpactNativeEventCampaignIdKey = @"campaignId";
NSString * const kApplifierImpactNativeEventForceStopVideoPlayback = @"forceStopVideoPlayback";

/* Native Event Params */

NSString * const kApplifierImpactTextKeyKey = @"textKey";
NSString * const kApplifierImpactTextKeyBuffering = @"buffering";
NSString * const kApplifierImpactTextKeyLoading = @"loading";
NSString * const kApplifierImpactTextKeyVideoPlaybackError = @"videoPlaybackError";
NSString * const kApplifierImpactItemKeyKey = @"itemKey";


/* JSON Data Root */

NSString * const kApplifierImpactJsonDataRootKey = @"data";


/* Campaign JSON Properties */

NSString * const kApplifierImpactCampaignsKey = @"campaigns";
NSString * const kApplifierImpactCampaignEndScreenKey = @"endScreen";
NSString * const kApplifierImpactCampaignEndScreenPortraitKey = @"endScreenPortrait";
NSString * const kApplifierImpactCampaignClickURLKey = @"clickUrl";
NSString * const kApplifierImpactCampaignPictureKey = @"picture";
NSString * const kApplifierImpactCampaignTrailerDownloadableKey = @"trailerDownloadable";
NSString * const kApplifierImpactCampaignTrailerStreamingKey = @"trailerStreaming";
NSString * const kApplifierImpactCampaignGameIconKey = @"gameIcon";
NSString * const kApplifierImpactCampaignGameIDKey = @"gameId";
NSString * const kApplifierImpactCampaignGameNameKey = @"gameName";
NSString * const kApplifierImpactCampaignIDKey = @"id";
NSString * const kApplifierImpactCampaignTaglineKey = @"tagLine";
NSString * const kApplifierImpactCampaignStoreIDKey = @"iTunesId";
NSString * const kApplifierImpactCampaignCacheVideoKey = @"cacheVideo";
NSString * const kApplifierImpactCampaignBypassAppSheet = @"bypassAppSheet";
NSString * const kApplifierImpactCampaignExpectedFileSize = @"trailerSize";
NSString * const kApplifierImpactCampaignAllowVideoSkipKey = @"allowSkipVideoInSeconds";

/* Reward Item JSON Properties */

NSString * const kApplifierImpactRewardItemKeyKey = @"itemKey";
NSString * const kApplifierImpactRewardNameKey = @"name";
NSString * const kApplifierImpactRewardPictureKey = @"picture";
NSString * const kApplifierImpactRewardItemKey = @"item";
NSString * const kApplifierImpactRewardItemsKey = @"items";


/* Gamer JSON Properties */

NSString * const kApplifierImpactGamerIDKey = @"gamerId";


/* Impact Base JSON Properties */

NSString * const kApplifierImpactUrlKey = @"impactUrl";
NSString * const kApplifierImpactWebViewUrlKey = @"webViewUrl";
NSString * const kApplifierImpactAnalyticsUrlKey = @"analyticsUrl";
NSString * const kApplifierImpactSdkVersionKey = @"nativeSdkVersion";


/* Analytics Uploader */

NSString * const kApplifierImpactAnalyticsTrackingPath = @"gamers/";
NSString * const kApplifierImpactAnalyticsInstallTrackingPath = @"games/";
NSString * const kApplifierImpactAnalyticsQueryDictionaryQueryKey = @"kApplifierImpactQueryDictionaryQueryKey";
NSString * const kApplifierImpactAnalyticsQueryDictionaryBodyKey = @"kApplifierImpactQueryDictionaryBodyKey";
NSString * const kApplifierImpactAnalyticsUploaderRequestKey = @"kApplifierImpactAnalyticsUploaderRequestKey";
NSString * const kApplifierImpactAnalyticsUploaderConnectionKey = @"kApplifierImpactAnalyticsUploaderConnectionKey";
NSString * const kApplifierImpactAnalyticsUploaderRetriesKey = @"kApplifierImpactAnalyticsUploaderRetriesKey";
NSString * const kApplifierImpactAnalyticsSavedUploadsKey = @"kApplifierImpactAnalyticsSavedUploadsKey";
NSString * const kApplifierImpactAnalyticsSavedUploadURLKey = @"kApplifierImpactAnalyticsSavedUploadURLKey";
NSString * const kApplifierImpactAnalyticsSavedUploadBodyKey = @"kApplifierImpactAnalyticsSavedUploadBodyKey";
NSString * const kApplifierImpactAnalyticsSavedUploadHTTPMethodKey = @"kApplifierImpactAnalyticsSavedUploadHTTPMethodKey";

NSString * const kApplifierImpactAnalyticsQueryParamGameIdKey = @"gameId";
NSString * const kApplifierImpactAnalyticsQueryParamEventTypeKey = @"type";
NSString * const kApplifierImpactAnalyticsQueryParamTrackingIdKey = @"trackingId";
NSString * const kApplifierImpactAnalyticsQueryParamProviderIdKey = @"providerId";
NSString * const kApplifierImpactAnalyticsQueryParamRewardItemKey = @"rewardItem";
NSString * const kApplifierImpactAnalyticsQueryParamGamerSIDKey = @"sid";

NSString * const kApplifierImpactAnalyticsEventTypeVideoStart = @"video_start";
NSString * const kApplifierImpactAnalyticsEventTypeVideoFirstQuartile = @"first_quartile";
NSString * const kApplifierImpactAnalyticsEventTypeVideoMidPoint = @"mid_point";
NSString * const kApplifierImpactAnalyticsEventTypeVideoThirdQuartile = @"third_quartile";
NSString * const kApplifierImpactAnalyticsEventTypeVideoEnd = @"video_end";
NSString * const kApplifierImpactAnalyticsEventTypeOpenAppStore = @"openAppStore";

NSString * const kApplifierImpactTrackingEventTypeVideoStart = @"start";
NSString * const kApplifierImpactTrackingEventTypeVideoEnd = @"view";


/* Devicetypes */

NSString * const kApplifierImpactDeviceIphone = @"iphone";
NSString * const kApplifierImpactDeviceIphone3g = @"iphone3g";
NSString * const kApplifierImpactDeviceIphone3gs = @"iphone3gs";
NSString * const kApplifierImpactDeviceIphone4 = @"iphone4";
NSString * const kApplifierImpactDeviceIphone4s = @"iphone4s";
NSString * const kApplifierImpactDeviceIphone5 = @"iphone5";
NSString * const kApplifierImpactDeviceIpod = @"ipod";
NSString * const kApplifierImpactDeviceIpodTouch1gen = @"ipodtouch1gen";
NSString * const kApplifierImpactDeviceIpodTouch2gen = @"ipodtouch2gen";
NSString * const kApplifierImpactDeviceIpodTouch3gen = @"ipodtouch3gen";
NSString * const kApplifierImpactDeviceIpodTouch4gen = @"ipodtouch4gen";
NSString * const kApplifierImpactDeviceIpad = @"ipad";
NSString * const kApplifierImpactDeviceIpad1 = @"ipad1";
NSString * const kApplifierImpactDeviceIpad2 = @"ipad2";
NSString * const kApplifierImpactDeviceIpad3 = @"ipad3";
NSString * const kApplifierImpactDeviceIosUnknown = @"iosUnknown";
NSString * const kApplifierImpactDeviceSimulator = @"simulator";


/* Init Query Params */

NSString * const kApplifierImpactInitQueryParamDeviceIdKey = @"deviceId";
NSString * const kApplifierImpactInitQueryParamDeviceTypeKey = @"deviceType";
NSString * const kApplifierImpactInitQueryParamPlatformKey = @"platform";
NSString * const kApplifierImpactInitQueryParamGameIdKey = @"gameId";
NSString * const kApplifierImpactInitQueryParamOpenUdidKey = @"openUdid";
NSString * const kApplifierImpactInitQueryParamOdin1IdKey = @"odin1Id";
NSString * const kApplifierImpactInitQueryParamMacAddressKey = @"macAddress";
NSString * const kApplifierImpactInitQueryParamAdvertisingTrackingIdKey = @"advertisingTrackingId";
NSString * const kApplifierImpactInitQueryParamTrackingEnabledKey = @"trackingEnabled";
NSString * const kApplifierImpactInitQueryParamSoftwareVersionKey = @"softwareVersion";
NSString * const kApplifierImpactInitQueryParamHardwareVersionKey = @"hardwareVersion";
NSString * const kApplifierImpactInitQueryParamSdkVersionKey = @"sdkVersion";
NSString * const kApplifierImpactInitQueryParamConnectionTypeKey = @"connectionType";
NSString * const kApplifierImpactInitQueryParamTestKey = @"test";
NSString * const kApplifierImpactInitQueryParamEncryptionKey = @"encrypted";


/* Google Analytics Instrumentation */

NSString * const kApplifierImpactGoogleAnalyticsEventKey = @"googleAnalyticsEvent";
NSString * const kApplifierImpactGoogleAnalyticsEventTypeVideoPlayKey = @"videoAnalyticsEventPlay";
NSString * const kApplifierImpactGoogleAnalyticsEventTypeVideoErrorKey = @"videoAnalyticsEventError";
NSString * const kApplifierImpactGoogleAnalyticsEventTypeVideoAbortKey = @"videoAnalyticsEventAbort";
NSString * const kApplifierImpactGoogleAnalyticsEventTypeVideoCachingKey = @"videoAnalyticsEventCaching";
NSString * const kApplifierImpactGoogleAnalyticsEventVideoAbortBack = @"back";
NSString * const kApplifierImpactGoogleAnalyticsEventVideoAbortExit = @"exit";
NSString * const kApplifierImpactGoogleAnalyticsEventVideoPlayStream = @"stream";
NSString * const kApplifierImpactGoogleAnalyticsEventVideoPlayCached = @"cached";
NSString * const kApplifierImpactGoogleAnalyticsEventVideoCachingStart = @"start";
NSString * const kApplifierImpactGoogleAnalyticsEventVideoCachingCompleted = @"completed";
NSString * const kApplifierImpactGoogleAnalyticsEventVideoCachingFailed = @"failed";

@implementation ApplifierImpactConstants

@end
