//
//  ApplifierImpactZoneManagerTests.m
//  ApplifierImpact
//
//  Created by Ville Orkas on 10/9/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "ApplifierImpactZoneManager.h"

@interface ApplifierImpactZoneManagerTests : SenTestCase {
  ApplifierImpactZone * validZone;
  ApplifierImpactZoneManager * zoneManager;
}
@end

@implementation ApplifierImpactZoneManagerTests

- (void)setUp {
  [super setUp];
  validZone = [[ApplifierImpactZone alloc] initWithData:@{@"id": @"testZoneId", @"name": @"testZoneName", @"default": @"true"}];
  zoneManager = [[ApplifierImpactZoneManager alloc] init];
}

- (void)testZoneManagerIsEmptyOnInit {
  STAssertTrue([zoneManager zoneCount] == 0, @"New zone manager should be empty");
  STAssertTrue([zoneManager getCurrentZone] == nil, @"Current zone should be nil");
}

- (void)testZoneManagerAddSingleZone {
  int addedZones = [zoneManager addZones:@{@"testZoneId": validZone}];
  STAssertTrue(addedZones == 1, @"Failed to add single zone");
  STAssertTrue([[zoneManager getCurrentZone] isEqual:validZone], @"Failed to set current zone to single added zone");
}

- (void)testZoneManagerClearZones {
  [zoneManager clearZones];
  STAssertTrue([zoneManager zoneCount] == 0, @"Failed to clear zones");
  STAssertTrue([zoneManager getCurrentZone] == nil, @"Failed to clear current zone");
}

@end
