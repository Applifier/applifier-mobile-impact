//
//  ApplifierImpactZone.m
//  ApplifierImpact
//
//  Created by Ville Orkas on 9/17/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactZone.h"
#import "ApplifierImpactConstants.h"

@interface ApplifierImpactZone ()

@property (nonatomic, strong) NSMutableDictionary *_options;

@end

@implementation ApplifierImpactZone

- (id)initWithData:(NSDictionary *)options {
  self = [super init];
  if(self) {
    self._options = [NSMutableDictionary dictionaryWithDictionary:options];
  }
  return self;
}

- (BOOL)isIncentivized {
  return FALSE;
}

- (NSString *)getZoneId {
  return [self._options valueForKey:kApplifierImpactZoneIdKey];
}

- (BOOL)noWebView {
  return [self._options valueForKey:kApplifierImpactZoneNoWebViewKey];
}

- (BOOL)noOfferScreen {
  return [self._options valueForKey:kApplifierImpactZoneNoOfferScreenKey];
}

- (BOOL)openAnimated {
  return [self._options valueForKey:kApplifierImpactZoneOpenAnimatedKey];
}

- (BOOL)muteVideoSounds {
  return [self._options valueForKey:kApplifierImpactZoneMuteVideoSoundsKey];
}

- (BOOL)useDeviceOrientationForVideo {
  return [self._options valueForKey:kApplifierImpactZoneUseDeviceOrientationForVideoKey];
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
}

@end
