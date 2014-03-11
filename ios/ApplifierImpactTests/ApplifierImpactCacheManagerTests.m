//
//  ApplifierImpactCacheManagerTests.m
//  ApplifierImpact
//
//  Created by Sergey D on 3/11/14.
//  Copyright (c) 2014 Applifier. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ApplifierImpactCampaign.h"
#import "ApplifierImpactCacheManager.h"

typedef enum {
  CachingResultUndefined = 0,
  CachingResultFinished,
  CachingResultFailed,
  CachingResultCancelled,
} CachingResult;

@interface ApplifierImpactCacheManagerTests : SenTestCase <ApplifierImpactCacheManagerDelegate> {
  @private
  CachingResult cachingResult;
}

@end

extern void __gcov_flush();

@implementation ApplifierImpactCacheManagerTests

- (void)threadBlocked:(BOOL (^)())isThreadBlocked {
	@autoreleasepool {
		NSPort *port = [[NSPort alloc] init];
		[port scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		while(isThreadBlocked) {
			@autoreleasepool {
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
			}
		}
	}
}

- (void)setUp
{
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
  __gcov_flush();
  [super tearDown];
}

- (void)testCacheEmptyCampaign {
  cachingResult = CachingResultUndefined;
  ApplifierImpactCacheManager * cacheManager = [ApplifierImpactCacheManager new];
  ApplifierImpactCampaign * campaignToCache = [ApplifierImpactCampaign new];
  [cacheManager cacheCampaign:campaignToCache];
  STAssertTrue(cachingResult == CachingResultFailed,
               @"caching should fail instantly in same thread when caching empty campaign");
}

- (void)cache:(ApplifierImpactCacheManager *)cache failedToCacheCampaign:(ApplifierImpactCampaign *)campaign {
  @synchronized(self) {
    cachingResult = CachingResultFailed;
  }
}

- (void)cache:(ApplifierImpactCacheManager *)cache finishedCachingCampaign:(ApplifierImpactCampaign *)campaign {
  @synchronized(self) {
    cachingResult = CachingResultFinished;
  }
}

- (void)cache:(ApplifierImpactCacheManager *)cache cancelledCaching:(ApplifierImpactCampaign *)campaign {
  @synchronized(self) {
    cachingResult = CachingResultCancelled;
  }
}

@end
