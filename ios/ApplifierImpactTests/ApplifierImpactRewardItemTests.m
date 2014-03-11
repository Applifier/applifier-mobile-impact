//
//  ApplifierImpactItemTests.m
//  ApplifierImpact
//
//  Created by Ville Orkas on 10/2/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

extern void __gcov_flush();

#import "ApplifierImpactRewardItem.h"

@interface ApplifierImpactRewardItemTests : SenTestCase

@end

@implementation ApplifierImpactRewardItemTests

- (void)tearDown {
  __gcov_flush();
  [super tearDown];
}

- (void)testValidItem {
  id itemData = @{@"key": @"testItemKey", @"name": @"testItemName", @"picture": @"http://www.google.fi"};
  ApplifierImpactRewardItem * item = [[ApplifierImpactRewardItem alloc] initWithData:itemData];
  STAssertTrue([item.key isEqual:@"testItemKey"], @"Item key is not valid");
  STAssertTrue([item.name isEqual:@"testItemName"], @"Item name is not valid");
  STAssertTrue([[item.pictureURL absoluteString] isEqual:@"http://www.google.fi"], @"Item picture is not valid");
}

- (void)testInvalidItem {
  id itemData = @{@"key": @"", @"picture": @"asd"};
  ApplifierImpactRewardItem * item = [[ApplifierImpactRewardItem alloc] initWithData:itemData];
  STAssertTrue(item == nil, @"Invalid item was created");
}

@end
