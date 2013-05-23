//
//  ApplifierImpactProperties.m
//  ApplifierImpact
//
//  Created by bluesun on 11/2/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactProperties.h"
#import "ApplifierImpactConstants.h"
#import "../ApplifierImpact.h"
#import "../ApplifierImpactDevice/ApplifierImpactDevice.h"

NSString * const kApplifierImpactVersion = @"105";

@implementation ApplifierImpactProperties

static ApplifierImpactProperties *sharedImpactProperties = nil;

+ (id)sharedInstance {
	@synchronized(self) {
		if (sharedImpactProperties == nil)
      sharedImpactProperties = [[ApplifierImpactProperties alloc] init];
	}
	
	return sharedImpactProperties;
}

- (ApplifierImpactProperties *)init {
  if (self = [super init]) {
    [self setMaxNumberOfAnalyticsRetries:5];
    [self setAllowVideoSkipInSeconds:0];
    [self setCampaignDataUrl:@"https://impact.applifier.com/mobile/campaigns"];
    //[self setCampaignDataUrl:@"https://staging-impact.applifier.com/mobile/campaigns"];
    //[self setCampaignDataUrl:@"http://192.168.1.246:3500/mobile/campaigns"];
    [self setCampaignQueryString:[self _createCampaignQueryString]];
    [self setSdkIsCurrent:true];
  }
  
  return self;
}

- (NSString *)impactVersion {
  return kApplifierImpactVersion;
}

- (NSString *)_createCampaignQueryString {
  NSString *queryParams = @"?";
  
  // Mandatory params
  queryParams = [NSString stringWithFormat:@"%@%@=%@", queryParams, kApplifierImpactInitQueryParamPlatformKey, @"ios"];
  queryParams = [NSString stringWithFormat:@"%@&%@=%@", queryParams, kApplifierImpactInitQueryParamGameIdKey, [self impactGameId]];
  queryParams = [NSString stringWithFormat:@"%@&%@=%@", queryParams, kApplifierImpactInitQueryParamOpenUdidKey, [ApplifierImpactDevice md5OpenUDIDString]];
  queryParams = [NSString stringWithFormat:@"%@&%@=%@", queryParams, kApplifierImpactInitQueryParamMacAddressKey, [ApplifierImpactDevice md5MACAddressString]];
  queryParams = [NSString stringWithFormat:@"%@&%@=%@", queryParams, kApplifierImpactInitQueryParamSdkVersionKey, kApplifierImpactVersion];
  
  if ([ApplifierImpactDevice ODIN1] != nil) {
    queryParams = [NSString stringWithFormat:@"%@&%@=%@", queryParams, kApplifierImpactInitQueryParamOdin1IdKey, [ApplifierImpactDevice ODIN1]];
  }
  
  // Add advertisingTrackingId info if identifier is available
  if ([ApplifierImpactDevice md5AdvertisingIdentifierString] != nil) {
    queryParams = [NSString stringWithFormat:@"%@&%@=%@", queryParams, kApplifierImpactInitQueryParamAdvertisingTrackingIdKey, [ApplifierImpactDevice md5AdvertisingIdentifierString]];
    queryParams = [NSString stringWithFormat:@"%@&%@=%i", queryParams, kApplifierImpactInitQueryParamTrackingEnabledKey, [ApplifierImpactDevice canUseTracking]];
  }
  
  // Add tracking params if canUseTracking (returns always true < ios6)
  if ([ApplifierImpactDevice canUseTracking]) {
    queryParams = [NSString stringWithFormat:@"%@&%@=%@", queryParams, kApplifierImpactInitQueryParamSoftwareVersionKey, [ApplifierImpactDevice softwareVersion]];
    queryParams = [NSString stringWithFormat:@"%@&%@=%@", queryParams, kApplifierImpactInitQueryParamHardwareVersionKey, @"unknown"];
    queryParams = [NSString stringWithFormat:@"%@&%@=%@", queryParams, kApplifierImpactInitQueryParamDeviceTypeKey, [ApplifierImpactDevice analyticsMachineName]];
    queryParams = [NSString stringWithFormat:@"%@&%@=%@", queryParams, kApplifierImpactInitQueryParamConnectionTypeKey, [ApplifierImpactDevice currentConnectionType]];
  }
  
  if ([self testModeEnabled]) {
    queryParams = [NSString stringWithFormat:@"%@&%@=true", queryParams, kApplifierImpactInitQueryParamTestKey];
    
    if ([self optionsId] != nil) {
      queryParams = [NSString stringWithFormat:@"%@&optionsId=%@", queryParams, [self optionsId]];
    }
    if ([self developerId] != nil) {
      queryParams = [NSString stringWithFormat:@"%@&developerId=%@", queryParams, [self developerId]];
    }
  }
  else {
    queryParams = [NSString stringWithFormat:@"%@&%@=%@", queryParams, kApplifierImpactInitQueryParamEncryptionKey, [ApplifierImpactDevice isEncrypted] ? @"true" : @"false"];
  }
  
  return queryParams;
}

- (void)refreshCampaignQueryString {
  [self setCampaignQueryString:[self _createCampaignQueryString]];
}

@end
