//
//  ApplifierImpactAnalyticsUploader.h
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../ApplifierImpactVideo/ApplifierImpactVideoPlayer.h"

@class ApplifierImpactCampaign;

@interface ApplifierImpactAnalyticsUploader : NSObject

- (void)sendOpenAppStoreRequest:(ApplifierImpactCampaign *)campaign;
- (void)sendTrackingCallWithQueryString:(NSString *)queryString;
- (void)sendInstallTrackingCallWithQueryDictionary:(NSDictionary *)queryDictionary;
- (void)retryFailedUploads;
- (void)logVideoAnalyticsWithPosition:(VideoAnalyticsPosition)videoPosition campaign:(ApplifierImpactCampaign *)campaign;

+ (ApplifierImpactAnalyticsUploader *)sharedInstance;
@end