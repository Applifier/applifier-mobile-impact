//
//  ApplifierImpactInstrumentation.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 5/7/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactInstrumentation.h"

#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"
#import "../ApplifierImpactDevice/ApplifierImpactDevice.h"

@implementation ApplifierImpactInstrumentation

+ (NSDictionary *)getBasicGAVideoProperties:(ApplifierImpactCampaign *)campaign {
  if (campaign != nil) {
    NSString *videoPlayType = kApplifierImpactGoogleAnalyticsEventVideoPlayStream;
    
    if (campaign.shouldCacheVideo) {
      videoPlayType = kApplifierImpactGoogleAnalyticsEventVideoPlayCached;
    }
    
    NSString *connectionType = [ApplifierImpactDevice currentConnectionType];
    NSDictionary *data = @{kApplifierImpactGoogleAnalyticsEventVideoPlaybackTypeKey:videoPlayType, kApplifierImpactGoogleAnalyticsEventConnectionTypeKey:connectionType, kApplifierImpactGoogleAnalyticsEventCampaignIdKey:campaign.id};

    return data;
  }
  
  return nil;
}

+ (NSDictionary *)mergeDictionaries:(NSDictionary *)dict1 dictionaryToMerge:(NSDictionary *)dict2 {
  NSMutableDictionary *finalData = [NSMutableDictionary dictionary];
  
  if (dict1 != nil) {
    [finalData addEntriesFromDictionary:dict1];
  }
  
  if (dict2 != nil) {
    [finalData addEntriesFromDictionary:dict2];
  }
  
  return finalData;
}

+ (NSArray *)getUnsentGAInstrumentationEvents {
  return nil;
}

+ (void)sendGAInstrumentationEvent:(NSString *)eventType {
  
}

+ (void)gaInstrumentationVideoPlay:(ApplifierImpactCampaign *)campaign withValuesFrom:(NSDictionary *)additionalValues {
  NSDictionary *basicData = [self getBasicGAVideoProperties:campaign];
  NSDictionary *finalData = [self mergeDictionaries:basicData dictionaryToMerge:additionalValues];
}

+ (void)gaInstrumentationVideoError:(ApplifierImpactCampaign *)campaign withValuesFrom:(NSDictionary *)additionalValues {
  
}

+ (void)gaInstrumentationVideoAbort:(ApplifierImpactCampaign *)campaign withValuesFrom:(NSDictionary *)additionalValues {
  
}

+ (void)gaInstrumentationVideoCaching:(ApplifierImpactCampaign *)campaign withValuesFrom:(NSDictionary *)additionalValues {
  
}

@end
