//
//  ApplifierImpactZoneManagerTests.m
//  ApplifierImpact
//
//  Created by Ville Orkas on 10/9/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import <objc/objc-runtime.h>
extern void __gcov_flush();

#import "ApplifierImpactZoneManager.h"

@interface ApplifierImpactZoneManagerTests : SenTestCase {
  ApplifierImpactZone * validZone1, * validZone2;
  ApplifierImpactZoneManager * zoneManager;
}
@end

@implementation ApplifierImpactZoneManagerTests

- (void)setUp {
  [super setUp];
  validZone1 = [[ApplifierImpactZone alloc] initWithData:@{@"id": @"testZoneId1", @"name": @"testZoneName1", @"default": @"true"}];
  validZone2 = [[ApplifierImpactZone alloc] initWithData:@{@"id": @"testZoneId2", @"name": @"testZoneName2", @"default": @"false"}];
  zoneManager = [[ApplifierImpactZoneManager alloc] init];
}

- (void)tearDown {
  __gcov_flush();
  [super tearDown];
}

- (void)testZoneManagerIsEmptyOnInit {
  STAssertTrue([zoneManager zoneCount] == 0, @"New zone manager should be empty");
  STAssertTrue([zoneManager getCurrentZone] == nil, @"Current zone should be nil");
}

- (void)testZoneManagerAddSingleZone {
  int addedZones = [zoneManager addZones:@{@"testZoneId": validZone1}];
  STAssertTrue(addedZones == 1, @"Failed to add single zone");
  STAssertTrue([[zoneManager getCurrentZone] isEqual:validZone1], @"Failed to set current zone to single added zone");
}

- (void)testZoneManagerClearZones {
  [zoneManager clearZones];
  STAssertTrue([zoneManager zoneCount] == 0, @"Failed to clear zones");
  STAssertTrue([zoneManager getCurrentZone] == nil, @"Failed to clear current zone");
}

- (void)testZoneManagerAddMultipleZones {
  [zoneManager addZones:@{@"testZoneId1": validZone1, @"testZoneId2": validZone2}];
  STAssertTrue([zoneManager zoneCount] == 2, @"Failed to add multiple zones");
  STAssertTrue([[zoneManager getCurrentZone] isEqual:validZone1], @"Failed to set current zone from multiple zones");
}

- (void)testZoneManagerSetInvalidZone {
  [zoneManager addZones:@{@"testZoneId1": validZone1, @"testZoneId2": validZone2}];
  STAssertFalse([zoneManager setCurrentZone:@"invalidZoneKey"], @"Failed to return false for setting an invalid current zone");
  STAssertTrue([[[zoneManager getCurrentZone] getZoneId] isEqualToString:@"testZoneId1"], @"Current zone should be the default zone after setting an invalid current zone");
}

- (void)testZoneManagerSetValidZone {
  [zoneManager addZones:@{@"testZoneId1": validZone1, @"testZoneId2": validZone2}];
  STAssertTrue([zoneManager setCurrentZone:@"testZoneId2"], @"Failed to set valid current zone");
}

@end
