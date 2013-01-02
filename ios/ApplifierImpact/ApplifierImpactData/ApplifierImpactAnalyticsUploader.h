//
//  ApplifierImpactAnalyticsUploader.h
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../ApplifierImpactVideo/ApplifierImpactVideoPlayer.h"

extern NSString * const kApplifierImpactQueryDictionaryQueryKey;
extern NSString * const kApplifierImpactQueryDictionaryBodyKey;

@class ApplifierImpactCampaign;

@interface ApplifierImpactAnalyticsUploader : NSObject

- (void)sendOpenAppStoreRequest:(ApplifierImpactCampaign *)campaign;
- (void)sendTrackingCallWithQueryString:(NSString *)queryString;
- (void)sendInstallTrackingCallWithQueryDictionary:(NSDictionary *)queryDictionary;
- (void)retryFailedUploads;
- (void)logVideoAnalyticsWithPosition:(VideoAnalyticsPosition)videoPosition campaign:(ApplifierImpactCampaign *)campaign;
- (void)sendManualInstallTrackingCall;

+ (ApplifierImpactAnalyticsUploader *)sharedInstance;
@end