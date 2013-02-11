//
//  ApplifierImpactConstants.h
//  ApplifierImpact
//
//  Created by bluesun on 1/10/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

/* WebView */

typedef enum {
  kApplifierImpactViewStateWebView,
  kApplifierImpactViewStateVideoPlayer,
  kApplifierImpactViewStateNone
} ApplifierImpactViewState;

extern NSString * const kApplifierImpactWebViewJSPrefix;
extern NSString * const kApplifierImpactWebViewJSInit;
extern NSString * const kApplifierImpactWebViewJSChangeView;
extern NSString * const kApplifierImpactWebViewJSHandleNativeEvent;

extern NSString * const kApplifierImpactWebViewAPIActionKey;
extern NSString * const kApplifierImpactWebViewAPIPlayVideo;
extern NSString * const kApplifierImpactWebViewAPINavigateTo;
extern NSString * const kApplifierImpactWebViewAPIInitComplete;
extern NSString * const kApplifierImpactWebViewAPIClose;
extern NSString * const kApplifierImpactWebViewAPIOpen;
extern NSString * const kApplifierImpactWebViewAPIAppStore;
extern NSString * const kApplifierImpactWebViewAPIActionVideoStartedPlaying;

extern NSString * const kApplifierImpactWebViewViewTypeCompleted;
extern NSString * const kApplifierImpactWebViewViewTypeStart;
extern NSString * const kApplifierImpactWebViewViewTypeNone;

extern NSString * const kApplifierImpactWebViewDataParamCampaignDataKey;
extern NSString * const kApplifierImpactWebViewDataParamPlatformKey;
extern NSString * const kApplifierImpactWebViewDataParamDeviceIdKey;
extern NSString * const kApplifierImpactWebViewDataParamGameIdKey;
extern NSString * const kApplifierImpactWebViewDataParamDeviceTypeKey;
extern NSString * const kApplifierImpactWebViewDataParamOpenUdidIdKey;
extern NSString * const kApplifierImpactWebViewDataParamMacAddressKey;
extern NSString * const kApplifierImpactWebViewDataParamSdkVersionKey;
extern NSString * const kApplifierImpactWebViewDataParamIosVersionKey;

extern NSString * const kApplifierImpactWebViewEventDataCampaignIdKey;
extern NSString * const kApplifierImpactWebViewEventDataRewatchKey;
extern NSString * const kApplifierImpactWebViewEventDataClickUrlKey;



/* Native Events */

extern NSString * const kApplifierImpactNativeEventHideSpinner;
extern NSString * const kApplifierImpactNativeEventShowSpinner;
extern NSString * const kApplifierImpactNativeEventShowError;
extern NSString * const kApplifierImpactNativeEventVideoCompleted;
extern NSString * const kApplifierImpactNativeEventCampaignIdKey;


/* Native Event Params */

extern NSString * const kApplifierImpactTextKeyKey;
extern NSString * const kApplifierImpactTextKeyBuffering;
extern NSString * const kApplifierImpactTextKeyLoading;
extern NSString * const kApplifierImpactItemKeyKey;
extern NSString * const kApplifierImpactTextKeyVideoPlaybackError;


/* JSON Data Root */

extern NSString * const kApplifierImpactJsonDataRootKey;


/* Campaign JSON Properties */

extern NSString * const kApplifierImpactCampaignsKey;
extern NSString * const kApplifierImpactCampaignEndScreenKey;
extern NSString * const kApplifierImpactCampaignClickURLKey;
extern NSString * const kApplifierImpactCampaignPictureKey;
extern NSString * const kApplifierImpactCampaignTrailerDownloadableKey;
extern NSString * const kApplifierImpactCampaignTrailerStreamingKey;
extern NSString * const kApplifierImpactCampaignGameIDKey;
extern NSString * const kApplifierImpactCampaignGameNameKey;
extern NSString * const kApplifierImpactCampaignIDKey;
extern NSString * const kApplifierImpactCampaignTaglineKey;
extern NSString * const kApplifierImpactCampaignStoreIDKey;
extern NSString * const kApplifierImpactCampaignCacheVideoKey;
extern NSString * const kApplifierImpactCampaignBypassAppSheet;
extern NSString * const kApplifierImpactCampaignExpectedFileSize;

/* Reward Item JSON Properties */

extern NSString * const kApplifierImpactRewardItemKeyKey;
extern NSString * const kApplifierImpactRewardNameKey;
extern NSString * const kApplifierImpactRewardPictureKey;
extern NSString * const kApplifierImpactRewardItemKey;
extern NSString * const kApplifierImpactRewardItemsKey;

/* Gamer JSON Properties */

extern NSString * const kApplifierImpactGamerIDKey;


/* Impact Base JSON Properties */

extern NSString * const kApplifierImpactUrlKey;
extern NSString * const kApplifierImpactWebViewUrlKey;
extern NSString * const kApplifierImpactAnalyticsUrlKey;


/* Analytics Uploader */

extern NSString * const kApplifierImpactAnalyticsTrackingPath;
extern NSString * const kApplifierImpactAnalyticsInstallTrackingPath;
extern NSString * const kApplifierImpactAnalyticsQueryDictionaryQueryKey;
extern NSString * const kApplifierImpactAnalyticsQueryDictionaryBodyKey;
extern NSString * const kApplifierImpactAnalyticsUploaderRequestKey;
extern NSString * const kApplifierImpactAnalyticsUploaderConnectionKey;
extern NSString * const kApplifierImpactAnalyticsUploaderRetriesKey;
extern NSString * const kApplifierImpactAnalyticsSavedUploadsKey;
extern NSString * const kApplifierImpactAnalyticsSavedUploadURLKey;
extern NSString * const kApplifierImpactAnalyticsSavedUploadBodyKey;
extern NSString * const kApplifierImpactAnalyticsSavedUploadHTTPMethodKey;

extern NSString * const kApplifierImpactAnalyticsQueryParamGameIdKey;
extern NSString * const kApplifierImpactAnalyticsQueryParamEventTypeKey;
extern NSString * const kApplifierImpactAnalyticsQueryParamTrackingIdKey;
extern NSString * const kApplifierImpactAnalyticsQueryParamProviderIdKey;
extern NSString * const kApplifierImpactAnalyticsQueryParamRewardItemKey;
extern NSString * const kApplifierImpactAnalyticsQueryParamGamerSIDKey;

extern NSString * const kApplifierImpactAnalyticsEventTypeVideoStart;
extern NSString * const kApplifierImpactAnalyticsEventTypeVideoFirstQuartile;
extern NSString * const kApplifierImpactAnalyticsEventTypeVideoMidPoint;
extern NSString * const kApplifierImpactAnalyticsEventTypeVideoThirdQuartile;
extern NSString * const kApplifierImpactAnalyticsEventTypeVideoEnd;
extern NSString * const kApplifierImpactAnalyticsEventTypeOpenAppStore;

extern NSString * const kApplifierImpactTrackingEventTypeVideoStart;
extern NSString * const kApplifierImpactTrackingEventTypeVideoEnd;


/* Devicetypes */

extern NSString * const kApplifierImpactDeviceIphone;
extern NSString * const kApplifierImpactDeviceIphone3g;
extern NSString * const kApplifierImpactDeviceIphone3gs;
extern NSString * const kApplifierImpactDeviceIphone4;
extern NSString * const kApplifierImpactDeviceIphone4s;
extern NSString * const kApplifierImpactDeviceIphone5;
extern NSString * const kApplifierImpactDeviceIpod;
extern NSString * const kApplifierImpactDeviceIpodTouch1gen;
extern NSString * const kApplifierImpactDeviceIpodTouch2gen;
extern NSString * const kApplifierImpactDeviceIpodTouch3gen;
extern NSString * const kApplifierImpactDeviceIpodTouch4gen;
extern NSString * const kApplifierImpactDeviceIpad;
extern NSString * const kApplifierImpactDeviceIpad1;
extern NSString * const kApplifierImpactDeviceIpad2;
extern NSString * const kApplifierImpactDeviceIpad3;
extern NSString * const kApplifierImpactDeviceIosUnknown;
extern NSString * const kApplifierImpactDeviceSimulator;


/* Init Query Params */

extern NSString * const kApplifierImpactInitQueryParamDeviceIdKey;
extern NSString * const kApplifierImpactInitQueryParamDeviceTypeKey;
extern NSString * const kApplifierImpactInitQueryParamPlatformKey;
extern NSString * const kApplifierImpactInitQueryParamGameIdKey;
extern NSString * const kApplifierImpactInitQueryParamOpenUdidKey;
extern NSString * const kApplifierImpactInitQueryParamMacAddressKey;
extern NSString * const kApplifierImpactInitQueryParamAdvertisingTrackingIdKey;
extern NSString * const kApplifierImpactInitQueryParamTrackingEnabledKey;
extern NSString * const kApplifierImpactInitQueryParamSoftwareVersionKey;
extern NSString * const kApplifierImpactInitQueryParamHardwareVersionKey;
extern NSString * const kApplifierImpactInitQueryParamSdkVersionKey;
extern NSString * const kApplifierImpactInitQueryParamConnectionTypeKey;
extern NSString * const kApplifierImpactInitQueryParamTestKey;


@interface ApplifierImpactConstants : NSObject

@end
