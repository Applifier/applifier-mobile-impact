//
//  ApplifierImpactItemManagerTests.m
//  ApplifierImpact
//
//  Created by Ville Orkas on 10/2/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

extern void __gcov_flush();

#import "ApplifierImpactRewardItemManager.h"

@interface ApplifierImpactRewardItemManagerTests : SenTestCase {
  ApplifierImpactRewardItem * validItem1, * validItem2;
}

@end

@implementation ApplifierImpactRewardItemManagerTests

- (void)setUp {
  [super setUp];
  validItem1 = [[ApplifierImpactRewardItem alloc] initWithData:@{@"key": @"testItemKey1", @"name": @"testItemName1", @"picture": @"http://www.google.fi"}];
  validItem2 = [[ApplifierImpactRewardItem alloc] initWithData:@{@"key": @"testItemKey2", @"name": @"testItemName2", @"picture": @"http://www.google.fi"}];
}

- (void)tearDown {
  __gcov_flush();
  [super tearDown];
}

- (void)testEmptyItems {
  ApplifierImpactRewardItemManager * itemManager = [[ApplifierImpactRewardItemManager alloc] initWithItems:@{} defaultItem:validItem1];
  STAssertTrue(itemManager == nil, @"Invalid item manager was created");
}

- (void)testEmptyDefaultItem {
  ApplifierImpactRewardItemManager * itemManager = [[ApplifierImpactRewardItemManager alloc] initWithItems:@{@"testItemKey1": validItem1} defaultItem:nil];
  STAssertTrue(itemManager == nil, @"Invalid item manager was created");
}

- (void)testMissingDefaultItem {
  ApplifierImpactRewardItemManager * itemManager = [[ApplifierImpactRewardItemManager alloc] initWithItems:@{@"testItemKey1": validItem1} defaultItem:validItem2];
  STAssertTrue(itemManager == nil, @"Invalid item manager was created");
}

- (void)testValidItems {
  ApplifierImpactRewardItemManager * itemManager = [[ApplifierImpactRewardItemManager alloc] initWithItems:@{@"testItemKey1": validItem1, @"testItemKey2": validItem2} defaultItem:validItem2];
  STAssertTrue(itemManager != nil, @"Valid item manager was not created");
  STAssertTrue([itemManager itemCount] == 2, @"Invalid item count");
}

@end
