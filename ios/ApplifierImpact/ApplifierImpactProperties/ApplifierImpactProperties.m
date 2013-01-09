//
//  ApplifierImpactProperties.m
//  ApplifierImpact
//
//  Created by bluesun on 11/2/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactProperties.h"
#import "../ApplifierImpact.h"
#import "../ApplifierImpactDevice/ApplifierImpactDevice.h"

NSString * const kApplifierImpactVersion = @"1.0.3";

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
    //[self setCampaignDataUrl:@"https://impact.applifier.com/mobile/campaigns"];
    [self setCampaignDataUrl:@"https://staging-impact.applifier.com/mobile/campaigns"];
    //[self setCampaignDataUrl:@"http://192.168.1.152:3500/mobile/campaigns"];
    [self setCampaignQueryString:[self _createCampaignQueryString]];
  }
  
  return self;
}

- (NSString *)impactVersion {
  return kApplifierImpactVersion;
}

- (NSString *)_createCampaignQueryString {
  NSString *queryParams = @"?";
  
  queryParams = [NSString stringWithFormat:@"%@deviceId=%@&platform=%@&gameId=%@", queryParams, [ApplifierImpactDevice md5DeviceId], @"ios", [self impactGameId]];
  queryParams = [NSString stringWithFormat:@"%@&openUdid=%@", queryParams, [ApplifierImpactDevice md5OpenUDIDString]];
  queryParams = [NSString stringWithFormat:@"%@&macAddress=%@", queryParams, [ApplifierImpactDevice md5MACAddressString]];
  
  if ([ApplifierImpactDevice md5AdvertisingIdentifierString] != nil) {
    queryParams = [NSString stringWithFormat:@"%@&advertisingTrackingId=%@", queryParams, [ApplifierImpactDevice md5AdvertisingIdentifierString]];
    queryParams = [NSString stringWithFormat:@"%@&trackingEnabled=%i", queryParams, [ApplifierImpactDevice canUseTracking]];
  }
  
  if ([ApplifierImpactDevice canUseTracking]) {
    queryParams = [NSString stringWithFormat:@"%@&softwareVersion=%@&hardwareVersion=%@&deviceType=%@&apiVersion=%@&connectionType=%@", queryParams, [ApplifierImpactDevice softwareVersion], @"unknown", [ApplifierImpactDevice analyticsMachineName], kApplifierImpactVersion, [ApplifierImpactDevice currentConnectionType]];
  }
  
  if ([self testModeEnabled]) {
    queryParams = [NSString stringWithFormat:@"%@&test=true", queryParams];
  }
  
  return queryParams;
}

- (void)refreshCampaignQueryString {
  [self setCampaignQueryString:[self _createCampaignQueryString]];
}

@end
