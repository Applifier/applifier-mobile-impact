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
#import "../ApplifierImpactWebView/ApplifierImpactWebAppController.h"

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

+ (NSDictionary *)makeEventFromEvent:(NSString *)eventType withData:(NSDictionary *)data {
  return @{kApplifierImpactGoogleAnalyticsEventTypeKey:eventType, @"data":data};
}

static NSMutableArray *unsentEvents;

+ (void)sendGAInstrumentationEvent:(NSString *)eventType withData:(NSDictionary *)data {
  NSDictionary *eventDataToSend = [self makeEventFromEvent:eventType withData:data];
  
  if (eventDataToSend != nil) {
    if ([[ApplifierImpactWebAppController sharedInstance] webViewInitialized] && [[ApplifierImpactWebAppController sharedInstance] webViewLoaded]) {
      NSMutableArray *eventsArray = [NSMutableArray array];
      
      if (unsentEvents != nil) {
        [eventsArray addObjectsFromArray:unsentEvents];
        [unsentEvents removeAllObjects];
        unsentEvents = nil;
      }
      
      [eventsArray addObject:eventDataToSend];
      NSDictionary *finalData = @{@"events":eventsArray};
      [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactGoogleAnalyticsEventKey data:finalData];
    }
    else {
      if (unsentEvents == nil) {
        unsentEvents = [NSMutableArray array];
      }
      
      [unsentEvents addObject:eventDataToSend];
    }
  }
}

+ (void)gaInstrumentationVideoPlay:(ApplifierImpactCampaign *)campaign withValuesFrom:(NSDictionary *)additionalValues {
  NSDictionary *basicData = [self getBasicGAVideoProperties:campaign];
  NSDictionary *finalData = [self mergeDictionaries:basicData dictionaryToMerge:additionalValues];
  [self sendGAInstrumentationEvent:kApplifierImpactGoogleAnalyticsEventTypeVideoPlay withData:finalData];
}

+ (void)gaInstrumentationVideoError:(ApplifierImpactCampaign *)campaign withValuesFrom:(NSDictionary *)additionalValues {
  NSDictionary *basicData = [self getBasicGAVideoProperties:campaign];
  NSDictionary *finalData = [self mergeDictionaries:basicData dictionaryToMerge:additionalValues];
  [self sendGAInstrumentationEvent:kApplifierImpactGoogleAnalyticsEventTypeVideoError withData:finalData];
}

+ (void)gaInstrumentationVideoAbort:(ApplifierImpactCampaign *)campaign withValuesFrom:(NSDictionary *)additionalValues {
  NSDictionary *basicData = [self getBasicGAVideoProperties:campaign];
  NSDictionary *finalData = [self mergeDictionaries:basicData dictionaryToMerge:additionalValues];
  [self sendGAInstrumentationEvent:kApplifierImpactGoogleAnalyticsEventTypeVideoAbort withData:finalData];
}

+ (void)gaInstrumentationVideoCaching:(ApplifierImpactCampaign *)campaign withValuesFrom:(NSDictionary *)additionalValues {
  NSDictionary *basicData = [self getBasicGAVideoProperties:campaign];
  NSDictionary *finalData = [self mergeDictionaries:basicData dictionaryToMerge:additionalValues];
  [self sendGAInstrumentationEvent:kApplifierImpactGoogleAnalyticsEventTypeVideoCaching withData:finalData];
}

@end