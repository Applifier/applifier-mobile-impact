//
//  ApplifierImpactZoneTests.m
//  ApplifierImpact
//
//  Created by Ville Orkas on 9/17/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "ApplifierImpactSBJsonParser.h"

#import "ApplifierImpactZone.h"
#import "ApplifierImpactZoneManager.h"
#import "ApplifierImpactZoneParser.h"

@interface ApplifierImpactZoneTests : SenTestCase

@end

@implementation ApplifierImpactZoneTests

- (void)testZone {
  id parser = [[ApplifierImpactSBJsonParser alloc] init];
  id json = [parser objectWithString:@"{\"id\": \"testId\", \"name\": \"testName\"}"];
  id test = [ApplifierImpactZoneParser parseZone:json];
  id testZoneId = [test getZoneId];
  STAssertTrue([testZoneId isEqual:@"testId"], @"zoneId does not match");
}

@end
