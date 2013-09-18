//
//  ApplifierImpactZoneParser.m
//  ApplifierImpact
//
//  Created by Ville Orkas on 9/17/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactZoneParser.h"
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
  id zoneId = [rawZone objectForKey:kApplifierImpactZoneIdKey];
  if([zoneId length] == 0) {
    return nil;
  }
  
  id zoneName = [rawZone objectForKey:kApplifierImpactZoneNameKey];
  if([zoneName length] == 0) {
    return nil;
  }
  
  return [[ApplifierImpactZone alloc] initWithData:rawZone];
}

@end
