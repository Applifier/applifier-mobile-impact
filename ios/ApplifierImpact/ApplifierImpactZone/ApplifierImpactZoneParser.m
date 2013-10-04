//
//  ApplifierImpactZoneParser.m
//  ApplifierImpact
//
//  Created by Ville Orkas on 9/17/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactZoneParser.h"
#import "ApplifierImpactIncentivizedZone.h"
#import "ApplifierImpactConstants.h"

@implementation ApplifierImpactZoneParser

+ (NSDictionary *)parseZones:(NSArray *)zoneArray {
  NSMutableDictionary *zones = [[NSMutableDictionary alloc] init];
  [zoneArray enumerateObjectsUsingBlock:^(id rawZone, NSUInteger index, BOOL *stop) {
    id zone = [ApplifierImpactZoneParser parseZone:rawZone];
    if(zone != nil) {
      [zones setObject:zone forKey:[zone getZoneId]];
    }
  }];
  return zones;
}

+ (ApplifierImpactZone *)parseZone:(NSDictionary *)rawZone {
  NSString * zoneId = [rawZone objectForKey:kApplifierImpactZoneIdKey];
  if([zoneId length] == 0) {
    return nil;
  }
  
  NSString * zoneName = [rawZone objectForKey:kApplifierImpactZoneNameKey];
  if([zoneName length] == 0) {
    return nil;
  }
  
  
  
  BOOL isIncentivized = [[rawZone objectForKey:kApplifierImpactZoneIsIncentivizedKey] boolValue];
  if(isIncentivized) {
    return [[ApplifierImpactIncentivizedZone alloc] initWithData:rawZone];
  } else {
    return [[ApplifierImpactZone alloc] initWithData:rawZone];
  }
}

@end
