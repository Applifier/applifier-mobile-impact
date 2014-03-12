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
#import "ApplifierImpactSBJsonParser.h"
#import "NSObject+ApplifierImpactSBJson.h"
#import "ApplifierImpactCampaignManager.h"
#import "ApplifierImpactConstants.h"

typedef enum {
  CachingResultUndefined = 0,
  CachingResultFinished,
  CachingResultFinishedAll,
  CachingResultFailed,
  CachingResultCancelled,
  CachingResultCancelledAll,
  
} CachingResult;

@interface ApplifierImpactCacheManagerTests : SenTestCase <ApplifierImpactCacheManagerDelegate> {
@private
  CachingResult cachingResult;
  ApplifierImpactCacheManager * _cacheManager;
}

@end

extern void __gcov_flush();

@implementation ApplifierImpactCacheManagerTests

- (void)threadBlocked:(BOOL (^)())isThreadBlocked {
	@autoreleasepool {
		NSPort *port = [[NSPort alloc] init];
		[port scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		while(isThreadBlocked()) {
			@autoreleasepool {
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
			}
		}
	}
}

- (void)setUp
{
  [super setUp];
  _cacheManager = [ApplifierImpactCacheManager new];
  _cacheManager.delegate = self;
  // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
  __gcov_flush();
  [super tearDown];
  _cacheManager = nil;
}

- (void)testCacheNilCampaign {
  cachingResult = CachingResultUndefined;
  ApplifierImpactCampaign * campaignToCache = nil;
  [_cacheManager cacheCampaign:campaignToCache];
  STAssertTrue(cachingResult == CachingResultFailed,
               @"caching should fail instantly in same thread when caching nil campaign");
}

- (void)testCacheEmptyCampaign {
  cachingResult = CachingResultUndefined;
  ApplifierImpactCampaign * campaignToCache = [ApplifierImpactCampaign new];
  [_cacheManager cacheCampaign:campaignToCache];
  
  STAssertTrue(cachingResult == CachingResultFailed,
               @"caching should fail instantly in same thread when caching empty campaign");
}

- (void)testCachePartiallyFilledCampaign {
  cachingResult = CachingResultUndefined;
  ApplifierImpactCampaign * campaignToCache = [ApplifierImpactCampaign new];
  campaignToCache.id = @"tmp";
  [_cacheManager cacheCampaign:campaignToCache];
  
  STAssertTrue(cachingResult == CachingResultFailed,
               @"caching should fail instantly in same thread when caching partially empty campaign");
  
  campaignToCache.id = @"tmp";
  campaignToCache.isValidCampaign = NO;
  [_cacheManager cacheCampaign:campaignToCache];
  
  STAssertTrue(cachingResult == CachingResultFailed,
               @"caching should fail instantly in same thread when caching partially empty campaign");
  
  campaignToCache.id = @"tmp";
  campaignToCache.isValidCampaign = YES;
  [_cacheManager cacheCampaign:campaignToCache];
  
  STAssertTrue(cachingResult == CachingResultFailed,
               @"caching should fail instantly in same thread when caching partially empty campaign");
}

- (void)testCacheCampaignFilledWithWrongValues {
  cachingResult = CachingResultUndefined;
  ApplifierImpactCampaign * campaignToCache = [ApplifierImpactCampaign new];
  campaignToCache.id = @"tmp";
  campaignToCache.isValidCampaign = YES;
  campaignToCache.trailerDownloadableURL = [NSURL URLWithString:@"tmp"];
  [_cacheManager cacheCampaign:campaignToCache];
  
  [self threadBlocked:^BOOL{
    @synchronized(self) {
      return cachingResult == CachingResultUndefined;
    }
  }];
  
  STAssertTrue(cachingResult == CachingResultFailed,
               @"caching should fail campaign filled with wrong values");
}

- (void)testCacheSingleValidCampaign {
  cachingResult = CachingResultUndefined;
  NSError * error = nil;
  NSStringEncoding encoding = NSStringEncodingConversionAllowLossy;
  NSString * pathToResource = [[NSBundle bundleForClass:[self class]] pathForResource:@"jsonData.txt" ofType:nil];
  NSString * jsonString = [[NSString alloc] initWithContentsOfFile:pathToResource
                                                      usedEncoding:&encoding
                                                             error:&error];
  NSDictionary * jsonDataDictionary = [jsonString JSONValue];
  NSDictionary *jsonDictionary = [jsonDataDictionary objectForKey:kApplifierImpactJsonDataRootKey];
  NSArray  * campaignsDataArray = [jsonDictionary objectForKey:kApplifierImpactCampaignsKey];
  NSArray * campaigns = [[ApplifierImpactCampaignManager sharedInstance] performSelector:@selector(deserializeCampaigns:) withObject:campaignsDataArray];
  STAssertTrue(jsonString != nil, @"empty json string");
  ApplifierImpactCampaign * campaignToCache = campaigns[0];
  STAssertTrue(campaignToCache != nil, @"campaign is nil");
  [_cacheManager cacheCampaign:campaignToCache];
  
  [self threadBlocked:^BOOL{
    @synchronized(self) {
      return cachingResult != CachingResultFinishedAll;
    }
  }];
  
  STAssertTrue(cachingResult == CachingResultFinishedAll,
               @"caching should be ok when caching valid campaigns");
}

- (void)testCacheAllCampaigns {
  cachingResult = CachingResultUndefined;
  NSError * error = nil;
  NSStringEncoding encoding = NSStringEncodingConversionAllowLossy;
  NSString * pathToResource = [[NSBundle bundleForClass:[self class]] pathForResource:@"jsonData.txt" ofType:nil];
  NSString * jsonString = [[NSString alloc] initWithContentsOfFile:pathToResource
                                                      usedEncoding:&encoding
                                                             error:&error];
  NSDictionary * jsonDataDictionary = [jsonString JSONValue];
  NSDictionary *jsonDictionary = [jsonDataDictionary objectForKey:kApplifierImpactJsonDataRootKey];
  NSArray  * campaignsDataArray = [jsonDictionary objectForKey:kApplifierImpactCampaignsKey];
  NSArray * campaigns = [[ApplifierImpactCampaignManager sharedInstance] performSelector:@selector(deserializeCampaigns:) withObject:campaignsDataArray];
  STAssertTrue(jsonString != nil, @"empty json string");
  [_cacheManager cacheCampaigns:campaigns];
  [self threadBlocked:^BOOL{
    @synchronized(self) {
      return cachingResult != CachingResultFinishedAll;
    }
  }];
  
  STAssertTrue(cachingResult == CachingResultFinishedAll,
               @"caching should be ok when caching valid campaigns");
}

- (void)testCancelAllOperatons {
  cachingResult = CachingResultUndefined;
  NSError * error = nil;
  NSStringEncoding encoding = NSStringEncodingConversionAllowLossy;
  NSString * pathToResource = [[NSBundle bundleForClass:[self class]] pathForResource:@"jsonData.txt" ofType:nil];
  NSString * jsonString = [[NSString alloc] initWithContentsOfFile:pathToResource
                                                      usedEncoding:&encoding
                                                             error:&error];
  NSDictionary * jsonDataDictionary = [jsonString JSONValue];
  NSDictionary *jsonDictionary = [jsonDataDictionary objectForKey:kApplifierImpactJsonDataRootKey];
  NSArray  * campaignsDataArray = [jsonDictionary objectForKey:kApplifierImpactCampaignsKey];
  NSArray * campaigns = [[ApplifierImpactCampaignManager sharedInstance] performSelector:@selector(deserializeCampaigns:) withObject:campaignsDataArray];
  STAssertTrue(jsonString != nil, @"empty json string");
  [_cacheManager cacheCampaigns:campaigns];
  sleep(4);
  [_cacheManager cancelAllDownloads];
  [self threadBlocked:^BOOL{
    @synchronized(self) {
      return cachingResult != CachingResultCancelledAll;
    }
  }];
  
  STAssertTrue(cachingResult == CachingResultCancelledAll,
               @"caching should be ok when caching valid campaigns");
}

#pragma mark - ApplifierImpactCacheManagerDelegate

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

- (void)cache:(ApplifierImpactCacheManager *)cache cancelledCachingCampaign:(ApplifierImpactCampaign *)campaign {
  @synchronized(self) {
    cachingResult = CachingResultCancelled;
  }
}

- (void)cache:(ApplifierImpactCacheManager *)cache finishedCachingAllCampaigns:(NSArray *)campaigns {
  @synchronized(self) {
    cachingResult = CachingResultFinishedAll;
  }
}

- (void)cache:(ApplifierImpactCacheManager *)cache cancelledCachingAllCampaigns:(NSArray *)campaigns {
  @synchronized(self) {
    cachingResult = CachingResultCancelledAll;
  }
}

@end
