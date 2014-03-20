//
//  ApplifierImpactZoneManager.h
//  ApplifierImpact
//
//  Created by Ville Orkas on 9/17/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApplifierImpactZone.h"

@interface ApplifierImpactZoneManager : NSObject

+ (id)sharedInstance;

- (int)addZones:(NSDictionary *)zones;
- (void)clearZones;

- (NSDictionary *)getZones;
- (ApplifierImpactZone *)getZone:(NSString *)zoneId;
- (BOOL)removeZone:(NSString *)zoneId;

- (BOOL)setCurrentZone:(NSString *)zoneId;
- (ApplifierImpactZone *)getCurrentZone;

- (NSUInteger)zoneCount;

@end
