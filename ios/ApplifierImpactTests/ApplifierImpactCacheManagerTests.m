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
} CachingResult;

@interface ApplifierImpactCacheManagerTests : SenTestCase <ApplifierImpactCacheManagerDelegate> {
@private
  CachingResult _cachingResult;
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

- (NSString *)_cachePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"applifier"];
}

- (void)setUp
{
  [super setUp];
  _cacheManager = [ApplifierImpactCacheManager new];
  _cacheManager.delegate = self;
  [[NSFileManager defaultManager] removeItemAtPath:[self _cachePath] error:nil];
  // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
  __gcov_flush();
  [super tearDown];
  _cacheManager = nil;
}

- (void)testCacheNilCampaign {
  _cachingResult = CachingResultUndefined;
  ApplifierImpactCampaign * campaignToCache = nil;
  STAssertTrue([_cacheManager cache:ResourceTypeTrailerVideo forCampaign:campaignToCache] != YES,
               @"caching should fail instantly in same thread when caching nil campaign");
}

- (void)testCacheEmptyCampaign {
  _cachingResult = CachingResultUndefined;
  ApplifierImpactCampaign * campaignToCache = [ApplifierImpactCampaign new];
  [_cacheManager cache:ResourceTypeTrailerVideo forCampaign:campaignToCache];
  STAssertTrue([_cacheManager cache:ResourceTypeTrailerVideo forCampaign:campaignToCache] != YES,
               @"caching should fail instantly in same thread when caching nil campaign");
}

- (void)testCachePartiallyFilledCampaign {
  _cachingResult = CachingResultUndefined;
  ApplifierImpactCampaign * campaignToCache = [ApplifierImpactCampaign new];
  campaignToCache.id = @"tmp";
  [_cacheManager cache:ResourceTypeTrailerVideo forCampaign:campaignToCache];
  STAssertTrue([_cacheManager cache:ResourceTypeTrailerVideo forCampaign:campaignToCache] != YES,
               @"caching should fail instantly in same thread when caching nil campaign");
  
  _cachingResult = CachingResultUndefined;
  campaignToCache.id = @"tmp";
  campaignToCache.isValidCampaign = NO;
  [_cacheManager cache:ResourceTypeTrailerVideo forCampaign:campaignToCache];
  
  STAssertTrue([_cacheManager cache:ResourceTypeTrailerVideo forCampaign:campaignToCache] != YES,
               @"caching should fail instantly in same thread when caching nil campaign");
  
  _cachingResult = CachingResultUndefined;
  campaignToCache.id = @"tmp";
  campaignToCache.isValidCampaign = YES;
  [_cacheManager cache:ResourceTypeTrailerVideo forCampaign:campaignToCache];
  
  STAssertTrue([_cacheManager cache:ResourceTypeTrailerVideo forCampaign:campaignToCache] != YES,
               @"caching should fail instantly in same thread when caching nil campaign");
}

- (void)testCacheCampaignFilledWithWrongValues {
  _cachingResult = CachingResultUndefined;
  ApplifierImpactCampaign * campaignToCache = [ApplifierImpactCampaign new];
  campaignToCache.id = @"tmp";
  campaignToCache.isValidCampaign = YES;
  campaignToCache.trailerDownloadableURL = [NSURL URLWithString:@"tmp"];
  BOOL addedToQueue = [_cacheManager cache:ResourceTypeTrailerVideo forCampaign:campaignToCache];
  
  if (addedToQueue) {
    [self threadBlocked:^BOOL{
      @synchronized(self) {
        return _cachingResult != CachingResultFinishedAll;
      }
    }];
  }
  
  STAssertTrue([_cacheManager is:ResourceTypeTrailerVideo cachedForCampaign:campaignToCache] != YES,
               @"video should not be cached");
  
  if (addedToQueue) {
    STAssertTrue(_cachingResult == CachingResultFinishedAll,
                 @"caching should fail campaign filled with wrong values");
  }
}

- (void)testCacheSingleValidCampaign {
  _cachingResult = CachingResultUndefined;
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
  BOOL addedToQueue = [_cacheManager cache:ResourceTypeTrailerVideo forCampaign:campaignToCache];
  
  if (addedToQueue) {
    [self threadBlocked:^BOOL{
      @synchronized(self) {
        return _cachingResult != CachingResultFinishedAll;
      }
    }];
  }
  
  STAssertTrue([_cacheManager is:ResourceTypeTrailerVideo cachedForCampaign:campaignToCache],
               @"video should be cached");
  if (addedToQueue)
  STAssertTrue(_cachingResult == CachingResultFinishedAll,
               @"caching should be ok when caching valid campaigns");
}

- (void)testCacheAllCampaigns {
  _cachingResult = CachingResultUndefined;
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
  [campaigns  enumerateObjectsUsingBlock:^(ApplifierImpactCampaign *campaign, NSUInteger idx, BOOL *stop) {
    [_cacheManager cache:ResourceTypeTrailerVideo forCampaign:campaign];
  }];
  
  [self threadBlocked:^BOOL{
    @synchronized(self) {
      return _cachingResult != CachingResultFinishedAll;
    }
  }];
  
  STAssertTrue(_cachingResult == CachingResultFinishedAll,
               @"caching should be ok when caching valid campaigns");
}

- (void)testCancelAllOperatons {
  _cachingResult = CachingResultUndefined;
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
  [campaigns  enumerateObjectsUsingBlock:^(ApplifierImpactCampaign *campaign, NSUInteger idx, BOOL *stop) {
    [_cacheManager cache:ResourceTypeTrailerVideo forCampaign:campaign];
  }];
  sleep(4);
  [_cacheManager cancelAllDownloads];
  [self threadBlocked:^BOOL{
    @synchronized(self) {
      return _cachingResult != CachingResultFinishedAll;
    }
  }];
  
  STAssertTrue(_cachingResult == CachingResultFinishedAll,
               @"caching should be ok when caching valid campaigns");
}

#pragma mark - ApplifierImpactCacheManagerDelegate

- (void)finishedCaching:(ResourceType)resourceType forCampaign:(ApplifierImpactCampaign *)campaign {
  @synchronized(self) {
    NSLog(@"finishedCaching %@", campaign.trailerDownloadableURL);
    _cachingResult = CachingResultFinished;
  }
}

- (void)failedCaching:(ResourceType)resourceType forCampaign:(ApplifierImpactCampaign *)campaign {
  @synchronized(self) {
    NSLog(@"failedCaching %@", campaign.trailerDownloadableURL);
    _cachingResult = CachingResultFailed;
  }
}

- (void)cancelledCaching:(ResourceType)resourceType forCampaign:(ApplifierImpactCampaign *)campaign {
  @synchronized(self) {
    NSLog(@"cancelledCaching %@", campaign.trailerDownloadableURL);
    _cachingResult = CachingResultCancelled;
  }
}

- (void)cacheQueueEmpty {
  @synchronized(self) {
    _cachingResult = CachingResultFinishedAll;
  }
}

@end
