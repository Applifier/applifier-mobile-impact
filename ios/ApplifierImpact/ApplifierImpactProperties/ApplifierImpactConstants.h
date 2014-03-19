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
  kApplifierImpactViewStateTypeOfferScreen,
  kApplifierImpactViewStateTypeEndScreen,
  kApplifierImpactViewStateTypeVideoPlayer,
  kApplifierImpactViewStateTypeNone,
  kApplifierImpactViewStateTypeSpinner,
  kApplifierImpactViewStateTypeInvalid
} ApplifierImpactViewStateType;

typedef enum {
  kApplifierImpactStateActionWillLeaveApplication,
  kApplifierImpactStateActionVideoStartedPlaying,
  kApplifierImpactStateActionVideoPlaybackEnded,
  kApplifierImpactStateActionVideoPlaybackSkipped
} ApplifierImpactViewStateAction;

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
extern NSString * const kApplifierImpactWebViewAPIDeveloperOptions;
extern NSString * const kApplifierImpactWebViewAPIAppStore;
extern NSString * const kApplifierImpactWebViewAPIActionVideoStartedPlaying;
extern NSString * const kApplifierImpactWebViewAPIActionVideoPlaybackError;

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
extern NSString * const kApplifierImpactWebViewDataParamSdkIsCurrentKey;
extern NSString * const kApplifierImpactWebViewDataParamIosVersionKey;
extern NSString * const kApplifierImpactWebViewDataParamZoneKey;
extern NSString * const kApplifierImpactWebViewDataParamZonesKey;

extern NSString * const kApplifierImpactWebViewEventDataCampaignIdKey;
extern NSString * const kApplifierImpactWebViewEventDataRewatchKey;
extern NSString * const kApplifierImpactWebViewEventDataClickUrlKey;
extern NSString * const kApplifierImpactWebViewEventDataBypassAppSheetKey;

/* Web Data */

extern int const kApplifierImpactWebDataMaxRetryCount;
extern int const kApplifierImpactWebDataRetryInterval;

/* Native Events */

extern NSString * const kApplifierImpactNativeEventHideSpinner;
extern NSString * const kApplifierImpactNativeEventShowSpinner;
extern NSString * const kApplifierImpactNativeEventShowError;
extern NSString * const kApplifierImpactNativeEventVideoCompleted;
extern NSString * const kApplifierImpactNativeEventCampaignIdKey;
extern NSString * const kApplifierImpactNativeEventForceStopVideoPlayback;

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
extern NSString * const kApplifierImpactCampaignEndScreenPortraitKey;
extern NSString * const kApplifierImpactCampaignClickURLKey;
extern NSString * const kApplifierImpactCampaignCustomClickURLKey;
extern NSString * const kApplifierImpactCampaignPictureKey;
extern NSString * const kApplifierImpactCampaignTrailerDownloadableKey;
extern NSString * const kApplifierImpactCampaignTrailerStreamingKey;
extern NSString * const kApplifierImpactCampaignGameIDKey;
extern NSString * const kApplifierImpactCampaignGameNameKey;
extern NSString * const kApplifierImpactCampaignIDKey;
extern NSString * const kApplifierImpactCampaignTaglineKey;
extern NSString * const kApplifierImpactCampaignStoreIDKey;
extern NSString * const kApplifierImpactCampaignCacheVideoKey;
extern NSString * const kApplifierImpactCampaignAllowedToCacheVideoKey;
extern NSString * const kApplifierImpactCampaignBypassAppSheet;
extern NSString * const kApplifierImpactCampaignExpectedFileSize;
extern NSString * const kApplifierImpactCampaignGameIconKey;
extern NSString * const kApplifierImpactCampaignAllowVideoSkipKey;

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
extern NSString * const kApplifierImpactSdkVersionKey;

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
extern NSString * const kApplifierImpactInitQueryParamOdin1IdKey;
extern NSString * const kApplifierImpactAnalyticsQueryParamEventTypeKey;
extern NSString * const kApplifierImpactAnalyticsQueryParamTrackingIdKey;
extern NSString * const kApplifierImpactAnalyticsQueryParamProviderIdKey;
extern NSString * const kApplifierImpactAnalyticsQueryParamZoneIdKey;
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
extern NSString * const kApplifierImpactDeviceIpod;
extern NSString * const kApplifierImpactDeviceIpad;
extern NSString * const kApplifierImpactDeviceIosUnknown;
extern NSString * const kApplifierImpactDeviceSimulator;

/* Init Query Params */

extern NSString * const kApplifierImpactInitQueryParamDeviceIdKey;
extern NSString * const kApplifierImpactInitQueryParamDeviceTypeKey;
extern NSString * const kApplifierImpactInitQueryParamPlatformKey;
extern NSString * const kApplifierImpactInitQueryParamGameIdKey;
extern NSString * const kApplifierImpactInitQueryParamOpenUdidKey;
extern NSString * const kApplifierImpactInitQueryParamMacAddressKey;
extern NSString * const kApplifierImpactInitQueryParamRawAdvertisingTrackingIdKey;
extern NSString * const kApplifierImpactInitQueryParamAdvertisingTrackingIdKey;
extern NSString * const kApplifierImpactInitQueryParamTrackingEnabledKey;
extern NSString * const kApplifierImpactInitQueryParamSoftwareVersionKey;
extern NSString * const kApplifierImpactInitQueryParamHardwareVersionKey;
extern NSString * const kApplifierImpactInitQueryParamSdkVersionKey;
extern NSString * const kApplifierImpactInitQueryParamConnectionTypeKey;
extern NSString * const kApplifierImpactInitQueryParamTestKey;
extern NSString * const kApplifierImpactInitQueryParamEncryptionKey;


/* Google Analytics Instrumentation */

extern NSString * const kApplifierImpactGoogleAnalyticsEventKey;
extern NSString * const kApplifierImpactGoogleAnalyticsEventTypeVideoPlay;
extern NSString * const kApplifierImpactGoogleAnalyticsEventTypeVideoError;
extern NSString * const kApplifierImpactGoogleAnalyticsEventTypeVideoAbort;
extern NSString * const kApplifierImpactGoogleAnalyticsEventTypeVideoCaching;
extern NSString * const kApplifierImpactGoogleAnalyticsEventVideoAbortBack;
extern NSString * const kApplifierImpactGoogleAnalyticsEventVideoAbortExit;
extern NSString * const kApplifierImpactGoogleAnalyticsEventVideoAbortSkip;
extern NSString * const kApplifierImpactGoogleAnalyticsEventVideoPlayStream;
extern NSString * const kApplifierImpactGoogleAnalyticsEventVideoPlayCached;
extern NSString * const kApplifierImpactGoogleAnalyticsEventVideoCachingStart;
extern NSString * const kApplifierImpactGoogleAnalyticsEventVideoCachingCompleted;
extern NSString * const kApplifierImpactGoogleAnalyticsEventVideoCachingFailed;

extern NSString * const kApplifierImpactGoogleAnalyticsEventCampaignIdKey;
extern NSString * const kApplifierImpactGoogleAnalyticsEventConnectionTypeKey;
extern NSString * const kApplifierImpactGoogleAnalyticsEventVideoPlaybackTypeKey;
extern NSString * const kApplifierImpactGoogleAnalyticsEventBufferingDurationKey;
extern NSString * const kApplifierImpactGoogleAnalyticsEventCachingDurationKey;
extern NSString * const kApplifierImpactGoogleAnalyticsEventValueKey;
extern NSString * const kApplifierImpactGoogleAnalyticsEventTypeKey;

/* Zones */

extern NSString * const kApplifierImpactZonesRootKey;
extern NSString * const kApplifierImpactZoneIdKey;
extern NSString * const kApplifierImpactZoneNameKey;
extern NSString * const kApplifierImpactZoneDefaultKey;
extern NSString * const kApplifierImpactZoneIsIncentivizedKey;
extern NSString * const kApplifierImpactZoneRewardItemsKey;
extern NSString * const kApplifierImpactZoneDefaultRewardItemKey;
extern NSString * const kApplifierImpactZoneAllowOverrides;
extern NSString * const kApplifierImpactZoneNoOfferScreenKey;
extern NSString * const kApplifierImpactZoneOpenAnimatedKey;
extern NSString * const kApplifierImpactZoneMuteVideoSoundsKey;
extern NSString * const kApplifierImpactZoneUseDeviceOrientationForVideoKey;
extern NSString * const kApplifierImpactZoneAllowVideoSkipInSecondsKey;

@interface ApplifierImpactConstants : NSObject

@end
