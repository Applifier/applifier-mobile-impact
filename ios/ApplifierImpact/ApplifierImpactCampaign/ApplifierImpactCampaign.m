//
//  ApplifierImpactCampaign.m
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "../ApplifierImpact.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"

#import "ApplifierImpactCampaign.h"

@interface ApplifierImpactCampaign ()
@end

@implementation ApplifierImpactCampaign

- (id)initWithData:(NSDictionary *)data {
  self = [super init];
  if (self) {
    self.isValidCampaign = false;
    [self setupFromData:data];
  }
  return self;
}

- (long long)geBufferingDuration {
  if (self.videoBufferingEndTime == 0) {
    self.videoBufferingEndTime = [[NSDate date] timeIntervalSince1970] * 1000;
  }
  
  if (self.videoBufferingStartTime > 0) {
    return self.videoBufferingEndTime - self.videoBufferingStartTime;
  }
  
  return 0;
}

- (void)setupFromData:(NSDictionary *)data {
  BOOL failedData = false;
  
  self.viewed = NO;
  self.nativeTrackingQuerySent = false;
  self.videoBufferingEndTime = 0;
  self.videoBufferingStartTime  = 0;
  
  NSString *endScreenURLString = [data objectForKey:kApplifierImpactCampaignEndScreenKey];
  if (endScreenURLString == nil) failedData = true;
  NSURL *endScreenURL = [NSURL URLWithString:endScreenURLString];
  self.endScreenURL = endScreenURL;
  
  NSString *endScreenPortraitURLString = [data objectForKey:kApplifierImpactCampaignEndScreenPortraitKey];
  if (endScreenPortraitURLString != nil) {
    NSURL *endScreenPortraitURL = [NSURL URLWithString:endScreenPortraitURLString];
    AILOG_DEBUG(@"Found endScreenPortraitURL");
    self.endScreenPortraitURL = endScreenPortraitURL;
  }
    
  NSString *clickURLString = [data objectForKey:kApplifierImpactCampaignClickURLKey];
  if (clickURLString == nil) failedData = true;
  NSURL *clickURL = [NSURL URLWithString:clickURLString];
  self.clickURL = clickURL;
  
  NSString *pictureURLString = [data objectForKey:kApplifierImpactCampaignPictureKey];
  if (pictureURLString == nil) failedData = true;
  NSURL *pictureURL = [NSURL URLWithString:pictureURLString];
  self.pictureURL = pictureURL;
  
  NSString *trailerDownloadableURLString = [data objectForKey:kApplifierImpactCampaignTrailerDownloadableKey];
  if (trailerDownloadableURLString == nil) failedData = true;
  NSURL *trailerDownloadableURL = [NSURL URLWithString:trailerDownloadableURLString];
  self.trailerDownloadableURL = trailerDownloadableURL;
  
  NSString *trailerStreamingURLString = [data objectForKey:kApplifierImpactCampaignTrailerStreamingKey];
  if (trailerStreamingURLString == nil) failedData = true;
  NSURL *trailerStreamingURL = [NSURL URLWithString:trailerStreamingURLString];
  self.trailerStreamingURL = trailerStreamingURL;
  
  NSString *gameIconURLString = [data objectForKey:kApplifierImpactCampaignGameIconKey];
  if (gameIconURLString == nil) failedData = true;
  NSURL *gameIconURL = [NSURL URLWithString:gameIconURLString];
  self.gameIconURL = gameIconURL;
  
  id gameIDValue = [data objectForKey:kApplifierImpactCampaignGameIDKey];
  if (gameIDValue == nil) failedData = true;
  NSString *gameID = [gameIDValue isKindOfClass:[NSNumber class]] ? [gameIDValue stringValue] : gameIDValue;
  self.gameID = gameID;
  
  id gameNameValue = [data objectForKey:kApplifierImpactCampaignGameNameKey];
  if (gameNameValue == nil) failedData = true;
  NSString *gameName = [gameNameValue isKindOfClass:[NSNumber class]] ? [gameNameValue stringValue] : gameNameValue;
  self.gameName = gameName;
  
  id idValue = [data objectForKey:kApplifierImpactCampaignIDKey];
  if (idValue == nil) failedData = true;
  NSString *idString = [idValue isKindOfClass:[NSNumber class]] ? [idValue stringValue] : idValue;
  self.id = idString;
  
  id tagLineValue = [data objectForKey:kApplifierImpactCampaignTaglineKey];
  if (tagLineValue == nil) failedData = true;
  NSString *tagline = [tagLineValue isKindOfClass:[NSNumber class]] ? [tagLineValue stringValue] : tagLineValue;
  self.tagLine = tagline;
  
  id itunesIDValue = [data objectForKey:kApplifierImpactCampaignStoreIDKey];
  if (itunesIDValue == nil) failedData = true;
  NSString *itunesID = [itunesIDValue isKindOfClass:[NSNumber class]] ? [itunesIDValue stringValue] : itunesIDValue;
  self.itunesID = itunesID;

  self.allowedToCacheVideo = NO;
  if ([data objectForKey:kApplifierImpactCampaignAllowedToCacheVideoKey] != nil) {
    if ([[data valueForKey:kApplifierImpactCampaignAllowedToCacheVideoKey] boolValue] != 0) {
      self.allowedToCacheVideo = YES;
    }
  }
  
  self.shouldCacheVideo = NO;
  if ([data objectForKey:kApplifierImpactCampaignCacheVideoKey] != nil) {
    if ([[data valueForKey:kApplifierImpactCampaignCacheVideoKey] boolValue] != 0) {
      self.shouldCacheVideo = YES;
    }
  }
  
  self.bypassAppSheet = NO;
  if ([data objectForKey:kApplifierImpactCampaignBypassAppSheet] != nil) {
    if ([[data valueForKey:kApplifierImpactCampaignBypassAppSheet] boolValue] != 0) {
      self.bypassAppSheet = YES;
    }
  }
  
  self.expectedTrailerSize = -1;
  if ([data objectForKey:kApplifierImpactCampaignExpectedFileSize] != nil) {
    if ([[data valueForKey:kApplifierImpactCampaignExpectedFileSize] longLongValue] != 0) {
      self.expectedTrailerSize = [[data valueForKey:kApplifierImpactCampaignExpectedFileSize] longLongValue];
    }
  }
  
  if (!failedData) {
    self.isValidCampaign = true;
  }

  NSString *customClickURLString = [data objectForKey:kApplifierImpactCampaignCustomClickURLKey];
  if (customClickURLString != nil && [customClickURLString length] > 4) {
    AILOG_DEBUG(@"CustomClickUrl=%@ for CampaignID=%@", customClickURLString, idString);
    NSURL *customClickURL = [NSURL URLWithString:customClickURLString];
    self.customClickURL = customClickURL;
  }
  else {
    AILOG_DEBUG(@"Not a valid URL: %@", customClickURLString);
  }
  
  data = nil;
}

@end
