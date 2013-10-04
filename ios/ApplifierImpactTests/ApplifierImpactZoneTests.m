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

@interface ApplifierImpactZoneTests : SenTestCase {
  ApplifierImpactZone * validZone;
}
@end

@implementation ApplifierImpactZoneTests

- (void)setUp {
  [super setUp];
  validZone = [[ApplifierImpactZone alloc] initWithData:@{
                                                         @"id": @"testZoneId",
                                                         @"name": @"testZoneName",
                                                         @"noOfferScreen": @NO,
                                                         @"openAnimated": @YES,
                                                         @"muteVideoSounds": @NO,
                                                         @"useDeviceOrientationForVideo": @YES,
                                                         @"allowClientOverrides": @[@"noOfferScreen", @"openAnimated"]}];
}

- (void)testZoneValidOverrides {
  [validZone mergeOptions:@{@"openAnimated": @NO}];
  STAssertTrue(![validZone openAnimated], @"Merge options failed");
}

- (void)testZoneInvalidOverrides {
  [validZone mergeOptions:@{@"muteVideoSounds": @YES}];
  STAssertTrue(![validZone muteVideoSounds], @"Merge options failed");
}

@end
