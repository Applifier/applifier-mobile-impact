//
//  ApplifierImpactZoneParser.h
//  ApplifierImpact
//
//  Created by Ville Orkas on 9/17/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApplifierImpactZone.h"

@interface ApplifierImpactZoneParser : NSObject

+ (NSDictionary *)parseZones:(NSArray *)zoneArray;
+ (ApplifierImpactZone *)parseZone:(NSDictionary *)zone;

@end
