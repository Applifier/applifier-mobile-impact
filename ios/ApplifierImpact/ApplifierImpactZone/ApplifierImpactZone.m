//
//  ApplifierImpactZone.m
//  ApplifierImpact
//
//  Created by Ville Orkas on 9/17/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "../ApplifierImpact.h"
#import "ApplifierImpactZone.h"
#import "ApplifierImpactConstants.h"

@interface ApplifierImpactZone ()

@property (nonatomic, strong) NSMutableDictionary *_options;
@property (nonatomic, strong) NSString * _gamerSid;

@end

@implementation ApplifierImpactZone

- (id)initWithData:(NSDictionary *)options {
  self = [super init];
  if(self) {
    self._options = [NSMutableDictionary dictionaryWithDictionary:options];
    self._gamerSid = nil;
  }
  return self;
}

- (BOOL)isIncentivized {
  return FALSE;
}

- (NSString *)getZoneId {
  return [self._options valueForKey:kApplifierImpactZoneIdKey];
}

- (NSDictionary *)getZoneOptions {
  return self._options;
}

- (BOOL)noWebView {
  return [[self._options valueForKey:kApplifierImpactZoneNoWebViewKey] boolValue];
}

- (BOOL)noOfferScreen {
  return [[self._options valueForKey:kApplifierImpactZoneNoOfferScreenKey] boolValue];
}

- (BOOL)openAnimated {
  return [[self._options valueForKey:kApplifierImpactZoneOpenAnimatedKey] boolValue];
}

- (BOOL)muteVideoSounds {
  return [[self._options valueForKey:kApplifierImpactZoneMuteVideoSoundsKey] boolValue];
}

- (BOOL)useDeviceOrientationForVideo {
  return [[self._options valueForKey:kApplifierImpactZoneUseDeviceOrientationForVideoKey] boolValue];
}

- (NSString *)getGamerSid {
  return self._gamerSid;
}

- (void)setGamerSid:(NSString *)gamerSid {
  self._gamerSid = gamerSid;
}

- (void)setNoOfferScreen:(BOOL)noOfferScreen {
  NSString *stringValue = noOfferScreen ? @"1" : @"0";
  [self._options setObject:stringValue forKey:kApplifierImpactZoneNoOfferScreenKey];
}

- (int)allowVideoSkipInSeconds {
  return [[self._options valueForKey:kApplifierImpactZoneAllowVideoSkipInSecondsKey] integerValue];
}

- (BOOL)allowsOverride:(NSString *)option {
  id allowOverrides = [self._options objectForKey:kApplifierImpactZoneAllowOverrides];
  return [allowOverrides indexOfObject:option] != NSNotFound;
}

- (void)mergeOptions:(NSDictionary *)options {
  [options enumerateKeysAndObjectsUsingBlock:^(id optionKey, id optionValue, BOOL *stop) {
    if([self allowsOverride:optionKey]) {
      [self._options setObject:optionValue forKey:optionKey];
    }
  }];
  NSString * gamerSid = [options valueForKey:kApplifierImpactOptionGamerSIDKey];
  if(gamerSid != nil) {
    [self setGamerSid:gamerSid];
  }
}

@end
