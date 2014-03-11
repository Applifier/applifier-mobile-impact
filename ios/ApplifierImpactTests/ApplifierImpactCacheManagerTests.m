//
//  ApplifierImpactCacheManagerTests.m
//  ApplifierImpact
//
//  Created by Sergey D on 3/11/14.
//  Copyright (c) 2014 Applifier. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface ApplifierImpactCacheManagerTests : SenTestCase

@end

extern void __gcov_flush();

@implementation ApplifierImpactCacheManagerTests

- (void)setUp
{
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
  __gcov_flush();
  [super tearDown];
}


@end
