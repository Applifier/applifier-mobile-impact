//
//  ApplifierImpactZoneManager.m
//  ApplifierImpact
//
//  Created by Ville Orkas on 9/17/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactZoneManager.h"
#import "ApplifierImpactIncentivizedZone.h"

@interface ApplifierImpactZoneManager ()

@property (nonatomic, strong) NSMutableDictionary * _zones;
@property (nonatomic, strong) ApplifierImpactZone * _currentZone;

@end

@implementation ApplifierImpactZoneManager

static ApplifierImpactZoneManager *sharedZoneManager = nil;

+ (id)sharedInstance {
	@synchronized(self) {
		if (sharedZoneManager == nil) {
      sharedZoneManager = [[ApplifierImpactZoneManager alloc] init];
    }
	}
	return sharedZoneManager;
}

- (id)init {
  self = [super init];
  if(self) {
    self._zones = [[NSMutableDictionary alloc] init];
    self._currentZone = nil;
  }
  return self;
}

- (int)addZones:(NSDictionary *)zones {
  __block int addedZones = 0;
  [zones enumerateKeysAndObjectsUsingBlock:^(id zoneId, id zone, BOOL *stop) {
    if([self._zones objectForKey:zoneId] == nil) {
      [self._zones setObject:zone forKey:zoneId];
      ++addedZones;
      if([zone isDefault] && self._currentZone == nil) {
        self._currentZone = zone;
      }
    }
  }];
  return addedZones;
}

- (void)clearZones {
  self._currentZone = nil;
  [self._zones removeAllObjects];
}

- (NSDictionary *)getZones {
  return self._zones;
}

- (ApplifierImpactZone *)getZone:(NSString *)zoneId {
  return [self._zones objectForKey:zoneId];
}

- (BOOL)removeZone:(NSString *)zoneId {
  if([self._zones objectForKey:zoneId] != nil) {
    if([[self._currentZone getZoneId] isEqualToString:zoneId]) {
      self._currentZone = nil;
    }
    [self._zones removeObjectForKey:zoneId];
    return true;
  }
  return false;
}

- (BOOL)setCurrentZone:(NSString *)zoneId {
  id zone = [self._zones objectForKey:zoneId];
  if(zone != nil) {
    self._currentZone = zone;
    return true;
  } else {
    self._currentZone = nil;
  }
  return false;
}

- (ApplifierImpactZone *)getCurrentZone {
  return self._currentZone;
}

- (int)zoneCount {
  return self._zones.count;
}

@end
