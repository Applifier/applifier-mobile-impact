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
  AIAssertV([endScreenURLString isKindOfClass:[NSString class]], nil);
  NSURL *endScreenURL = [NSURL URLWithString:endScreenURLString];
  AIAssertV(endScreenURL != nil, nil);
  self.endScreenURL = endScreenURL;
  
  NSString *endScreenPortraitURLString = [data objectForKey:kApplifierImpactCampaignEndScreenPortraitKey];
  if (endScreenPortraitURLString != nil) {
    AIAssertV([endScreenPortraitURLString isKindOfClass:[NSString class]], nil);
    NSURL *endScreenPortraitURL = [NSURL URLWithString:endScreenPortraitURLString];
    AIAssertV(endScreenPortraitURL != nil, nil);
    AILOG_DEBUG(@"Found endScreenPortraitURL");
    self.endScreenPortraitURL = endScreenPortraitURL;
  }
    
  NSString *clickURLString = [data objectForKey:kApplifierImpactCampaignClickURLKey];
  if (clickURLString == nil) failedData = true;
  AIAssertV([clickURLString isKindOfClass:[NSString class]], nil);
  NSURL *clickURL = [NSURL URLWithString:clickURLString];
  AIAssertV(clickURL != nil, nil);
  self.clickURL = clickURL;
  
  NSString *pictureURLString = [data objectForKey:kApplifierImpactCampaignPictureKey];
  if (pictureURLString == nil) failedData = true;
  AIAssertV([pictureURLString isKindOfClass:[NSString class]], nil);
  NSURL *pictureURL = [NSURL URLWithString:pictureURLString];
  AIAssertV(pictureURL != nil, nil);
  self.pictureURL = pictureURL;
  
  NSString *trailerDownloadableURLString = [data objectForKey:kApplifierImpactCampaignTrailerDownloadableKey];
  if (trailerDownloadableURLString == nil) failedData = true;
  AIAssertV([trailerDownloadableURLString isKindOfClass:[NSString class]], nil);
  NSURL *trailerDownloadableURL = [NSURL URLWithString:trailerDownloadableURLString];
  AIAssertV(trailerDownloadableURL != nil, nil);
  self.trailerDownloadableURL = trailerDownloadableURL;
  
  NSString *trailerStreamingURLString = [data objectForKey:kApplifierImpactCampaignTrailerStreamingKey];
  if (trailerStreamingURLString == nil) failedData = true;
  AIAssertV([trailerStreamingURLString isKindOfClass:[NSString class]], nil);
  NSURL *trailerStreamingURL = [NSURL URLWithString:trailerStreamingURLString];
  AIAssertV(trailerStreamingURL != nil, nil);
  self.trailerStreamingURL = trailerStreamingURL;
  
  NSString *gameIconURLString = [data objectForKey:kApplifierImpactCampaignGameIconKey];
  if (gameIconURLString == nil) failedData = true;
  AIAssertV([gameIconURLString isKindOfClass:[NSString class]], nil);
  NSURL *gameIconURL = [NSURL URLWithString:gameIconURLString];
  AIAssertV(gameIconURL != nil, nil);
  self.gameIconURL = gameIconURL;
  
  id gameIDValue = [data objectForKey:kApplifierImpactCampaignGameIDKey];
  if (gameIDValue == nil) failedData = true;
  AIAssertV(gameIDValue != nil && ([gameIDValue isKindOfClass:[NSString class]] || [gameIDValue isKindOfClass:[NSNumber class]]), nil);
  NSString *gameID = [gameIDValue isKindOfClass:[NSNumber class]] ? [gameIDValue stringValue] : gameIDValue;
  AIAssertV(gameID != nil && [gameID length] > 0, nil);
  self.gameID = gameID;
  
  id gameNameValue = [data objectForKey:kApplifierImpactCampaignGameNameKey];
  if (gameNameValue == nil) failedData = true;
  AIAssertV(gameNameValue != nil && ([gameNameValue isKindOfClass:[NSString class]] || [gameNameValue isKindOfClass:[NSNumber class]]), nil);
  NSString *gameName = [gameNameValue isKindOfClass:[NSNumber class]] ? [gameNameValue stringValue] : gameNameValue;
  AIAssertV(gameName != nil && [gameName length] > 0, nil);
  self.gameName = gameName;
  
  id idValue = [data objectForKey:kApplifierImpactCampaignIDKey];
  if (idValue == nil) failedData = true;
  AIAssertV(idValue != nil && ([idValue isKindOfClass:[NSString class]] || [idValue isKindOfClass:[NSNumber class]]), nil);
  NSString *idString = [idValue isKindOfClass:[NSNumber class]] ? [idValue stringValue] : idValue;
  AIAssertV(idString != nil && [idString length] > 0, nil);
  self.id = idString;
  
  id tagLineValue = [data objectForKey:kApplifierImpactCampaignTaglineKey];
  if (tagLineValue == nil) failedData = true;
  AIAssertV(tagLineValue != nil && ([tagLineValue isKindOfClass:[NSString class]] || [tagLineValue isKindOfClass:[NSNumber class]]), nil);
  NSString *tagline = [tagLineValue isKindOfClass:[NSNumber class]] ? [tagLineValue stringValue] : tagLineValue;
  AIAssertV(tagline != nil && [tagline length] > 0, nil);
  self.tagLine = tagline;
  
  id itunesIDValue = [data objectForKey:kApplifierImpactCampaignStoreIDKey];
  if (itunesIDValue == nil) failedData = true;
  AIAssertV(itunesIDValue != nil && ([itunesIDValue isKindOfClass:[NSString class]] || [itunesIDValue isKindOfClass:[NSNumber class]]), nil);
  NSString *itunesID = [itunesIDValue isKindOfClass:[NSNumber class]] ? [itunesIDValue stringValue] : itunesIDValue;
  AIAssertV(itunesID != nil && [itunesID length] > 0, nil);
  self.itunesID = itunesID;
  
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
  customClickURLString = @"http://www.google.com/";
  if (customClickURLString == nil) failedData = true;
  AIAssertV([customClickURLString isKindOfClass:[NSString class]], nil);
  
  if (customClickURLString != nil && [customClickURLString length] > 4) {
    AILOG_DEBUG(@"CustomClickUrl=%@ for CampaignID=%@", customClickURLString, idString);
    NSURL *customClickURL = [NSURL URLWithString:customClickURLString];
    AIAssertV(customClickURL != nil, nil);
    self.customClickURL = customClickURL;
  }
  else {
    AILOG_DEBUG(@"Not a valid URL: %@", customClickURLString);
  }
  
  data = nil;
}

@end
