//
//  ApplifierImpactCache.m
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpact.h"
#import "ApplifierImpactCacheManager.h"
#import "ApplifierImpactCampaign.h"
#import "ApplifierImpactInstrumentation.h"
#import "ApplifierImpactConstants.h"
#import "ApplifierImpactCacheCampaignOperation.h"

NSString * const kApplifierImpactCacheCampaignKey = @"kApplifierImpactCacheCampaignKey";
NSString * const kApplifierImpactCacheConnectionKey = @"kApplifierImpactCacheConnectionKey";
NSString * const kApplifierImpactCacheFilePathKey = @"kApplifierImpactCacheFilePathKey";
NSString * const kApplifierImpactCacheURLRequestKey = @"kApplifierImpactCacheURLRequestKey";
NSString * const kApplifierImpactCacheIndexKey = @"kApplifierImpactCacheIndexKey";
NSString * const kApplifierImpactCacheResumeKey = @"kApplifierImpactCacheResumeKey";

NSString * const kApplifierImpactCacheDownloadResumeExpected = @"kApplifierImpactCacheDownloadResumeExpected";
NSString * const kApplifierImpactCacheDownloadNewDownload = @"kApplifierImpactCacheDownloadNewDownload";

NSString * const kApplifierImpactCacheEntryCampaignIDKey = @"kApplifierImpactCacheEntryCampaignIDKey";
NSString * const kApplifierImpactCacheEntryFilenameKey = @"kApplifierImpactCacheEntryFilenameKey";
NSString * const kApplifierImpactCacheEntryFilesizeKey = @"kApplifierImpactCacheEntryFilesizeKey";

@interface ApplifierImpactCacheManager () <ApplifierImpactCacheOperationDelegate>
@property (nonatomic, strong) NSOperationQueue * cacheOperationsQueue;
@property (nonatomic, strong) NSMutableDictionary *campaignsOperations;
@end

@implementation ApplifierImpactCacheManager

#pragma mark - Private

- (NSString *)_cachePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	AIAssertV(paths != nil && [paths count] > 0, nil);
	
	return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"applifier"];
}

- (NSString *)_videoFilenameForCampaign:(ApplifierImpactCampaign *)campaign {
  if ([campaign.trailerDownloadableURL lastPathComponent] == nil || [campaign.trailerDownloadableURL lastPathComponent].length < 3) {
    return [NSString stringWithFormat:@"%@-%@", campaign.id, @"failed.mp4"];
  }
  
	return [NSString stringWithFormat:@"%@-%@", campaign.id, [campaign.trailerDownloadableURL lastPathComponent]];
}

- (NSString *)_videoPathForCampaign:(ApplifierImpactCampaign *)campaign {
	return [[self _cachePath] stringByAppendingPathComponent:[self _videoFilenameForCampaign:campaign]];
}

- (long long)_cachedFilesizeForVideoFilename:(NSString *)filename {
	NSArray *index = [[NSUserDefaults standardUserDefaults] arrayForKey:kApplifierImpactCacheIndexKey];
	long long size = 0;
	
	for (NSDictionary *cacheEntry in index) {
		NSString *indexFilename = [cacheEntry objectForKey:kApplifierImpactCacheEntryFilenameKey];
		if ([filename isEqualToString:indexFilename]) {
			size = [[cacheEntry objectForKey:kApplifierImpactCacheEntryFilesizeKey] longLongValue];
			break;
		}
	}
	
	return size;
}

- (long long)_filesizeForPath:(NSString *)path {
	long long size = 0;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
		size = [attributes fileSize];
	}
	
	return size;
}

#pragma mark - Public

- (id)init {
	AIAssertV(![NSThread isMainThread], nil);
	
	if ((self = [super init])) {
    AILOG_DEBUG(@"creating downloadqueue");
    self.cacheOperationsQueue = [NSOperationQueue new];
    [self.cacheOperationsQueue setMaxConcurrentOperationCount:1];
    self.campaignsOperations = [NSMutableDictionary new];
	}
	
	return self;
}

- (BOOL)campaignHasValidCache:(ApplifierImpactCampaign *)campaignToCache {
  return NO;
}

- (BOOL)_isValidCampaignToCache:(ApplifierImpactCampaign *)campaignToCache {
  @synchronized(self) {
    return campaignToCache.id != nil && campaignToCache.isValidCampaign && campaignToCache.trailerDownloadableURL;
  }
}

- (void)cacheCampaigns:(NSArray *)campaigns {
  @synchronized(self) {
    if (!campaigns.count) return;
    [campaigns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      ApplifierImpactCampaign * campaigntoCache = nil;
      if ([obj isKindOfClass:[ApplifierImpactCampaign class]]) {
        campaigntoCache = (ApplifierImpactCampaign *)obj;
        [self cacheCampaign:campaigntoCache];
      }
    }];
  }
}

- (void)cacheCampaign:(ApplifierImpactCampaign *)campaignToCache {
  @synchronized(self) {
    if (![self _isValidCampaignToCache:campaignToCache]) {
      if ([self.delegate respondsToSelector:@selector(cache:failedToCacheCampaign:)]) {
        [self.delegate cache:self failedToCacheCampaign:campaignToCache];
      }
      return;
    }
    
    if ([self campaignExistsInQueue:campaignToCache]) return;
    
    ApplifierImpactCacheCampaignOperation * cacheOperation = [ApplifierImpactCacheCampaignOperation new];
    cacheOperation.campaignToCache = campaignToCache;
    cacheOperation.delegate = self;
    self.campaignsOperations[campaignToCache.id] = cacheOperation;
    [self.cacheOperationsQueue addOperation:cacheOperation];
  }
}

- (BOOL)campaignExistsInQueue:(ApplifierImpactCampaign *)campaign {
  @synchronized(self) {
    return self.campaignsOperations[campaign.id] != nil;
  }
}

- (BOOL)isCampaignVideoCached:(ApplifierImpactCampaign *)campaign {
  BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[self _videoPathForCampaign:campaign]];
  AILOG_DEBUG(@"File exists at path: %@, %i", [self _videoPathForCampaign:campaign], exists);
  return exists;
}

- (NSURL *)localVideoURLForCampaign:(ApplifierImpactCampaign *)campaign {
	@synchronized (self) {
		if (campaign == nil) {
			AILOG_DEBUG(@"Input is nil.");
			return nil;
		}
    
		NSString *path = [self _videoPathForCampaign:campaign];
		
		return [NSURL fileURLWithPath:path];
	}
}

- (void)cancelAllDownloads {
  @synchronized(self) {
    [self.cacheOperationsQueue cancelAllOperations];
  }
}

- (void)_removeCacheOperationForCampaign:(ApplifierImpactCampaign *)campaign {
  @synchronized(self) {
    [self.campaignsOperations removeObjectForKey:campaign.id];
  }
}

#pragma mark ----
#pragma mark ApplifierImpactCacheOperationDelegate
#pragma mark ----

- (void)operationStarted:(ApplifierImpactCacheCampaignOperation *)cacheOperation {
  @synchronized(self) {
    [self _removeCacheOperationForCampaign:cacheOperation.campaignToCache];
  }
}

- (void)operationFinished:(ApplifierImpactCacheCampaignOperation *)cacheOperation {
  @synchronized(self) {
    [self _removeCacheOperationForCampaign:cacheOperation.campaignToCache];
    [self.delegate cache:self finishedCachingCampaign:cacheOperation.campaignToCache];
  }
}

- (void)operationFailed:(ApplifierImpactCacheCampaignOperation *)cacheOperation {
  @synchronized(self) {
    [self _removeCacheOperationForCampaign:cacheOperation.campaignToCache];
  }
}

- (void)operationCancelled:(ApplifierImpactCacheCampaignOperation *)cacheOperation {
  @synchronized(self) {
    [self _removeCacheOperationForCampaign:cacheOperation.campaignToCache];
  }
}

@end