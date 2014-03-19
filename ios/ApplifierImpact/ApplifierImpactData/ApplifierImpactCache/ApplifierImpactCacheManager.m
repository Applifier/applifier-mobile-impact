//
//  ApplifierImpactCache.m
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpact.h"
#import "ApplifierImpactCacheManager.h"
#import "ApplifierImpactCampaign.h"
#import "ApplifierImpactInstrumentation.h"
#import "ApplifierImpactConstants.h"

static NSString * const kApplifierImpactCacheCampaignKey = @"kApplifierImpactCacheCampaignKey";
static NSString * const kApplifierImpactCacheConnectionKey = @"kApplifierImpactCacheConnectionKey";
static NSString * const kApplifierImpactCacheFilePathKey = @"kApplifierImpactCacheFilePathKey";
static NSString * const kApplifierImpactCacheURLRequestKey = @"kApplifierImpactCacheURLRequestKey";
static NSString * const kApplifierImpactCacheIndexKey = @"kApplifierImpactCacheIndexKey";
static NSString * const kApplifierImpactCacheResumeKey = @"kApplifierImpactCacheResumeKey";

static NSString * const kApplifierImpactCacheDownloadResumeExpected = @"kApplifierImpactCacheDownloadResumeExpected";
static NSString * const kApplifierImpactCacheDownloadNewDownload = @"kApplifierImpactCacheDownloadNewDownload";

static NSString * const kApplifierImpactCacheEntryCampaignIDKey = @"kApplifierImpactCacheEntryCampaignIDKey";
static NSString * const kApplifierImpactCacheEntryFilenameKey = @"kApplifierImpactCacheEntryFilenameKey";
static NSString * const kApplifierImpactCacheEntryFilesizeKey = @"kApplifierImpactCacheEntryFilesizeKey";
static NSString * const kApplifierImpactCacheOperationKey = @"kApplifierImpactCacheOperationKey";
static NSString * const kApplifierImpactCacheOperationCampaignKey = @"kApplifierImpactCacheOperationCampaignKey";


@interface ApplifierImpactCacheManager () <ApplifierImpactCacheOperationDelegate>
@property (nonatomic, strong) NSOperationQueue * cacheOperationsQueue;
@property (nonatomic, strong) NSMutableDictionary *campaignsOperations;
@end

static ApplifierImpactCacheManager * _inst = nil;

@implementation ApplifierImpactCacheManager

+ sharedInstance {
  @synchronized (self) {
    return _inst == nil ? _inst = [[self class] new] : _inst;
  }
}

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

- (NSURL *)_downloadURLFor:(ResourceType)resourceType of:(ApplifierImpactCampaign *)campaign {
  @synchronized(self) {
    NSURL * url = nil;
    switch (resourceType) {
      case ResourceTypeTrailerVideo:
        url = campaign.trailerDownloadableURL;
        break;
      default:
        break;
    }
    return url;
  }
}

- (BOOL)isCampaignVideoCached:(ApplifierImpactCampaign *)campaign {
  @synchronized(self) {
    BOOL cached = [self _filesizeForPath:[self _videoPathForCampaign:campaign]] == campaign.expectedTrailerSize &&
    campaign.expectedTrailerSize;
    return cached;
  }
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

- (NSURL *)localURLFor:(ResourceType)resourceType ofCampaign:(ApplifierImpactCampaign *)campaign {
	@synchronized (self) {
		if (campaign == nil) {
			AILOG_DEBUG(@"Input is nil.");
			return nil;
		}
		NSString *path = nil;
    switch (resourceType) {
      case ResourceTypeTrailerVideo:
        path = [self _videoPathForCampaign:campaign];
        break;
        
      default:
        break;
    }
		return [NSURL fileURLWithPath:path];
	}
}

- (BOOL)_isCampaignValid:(ApplifierImpactCampaign *)campaign {
  @synchronized(self) {
    return campaign != nil && campaign.expectedTrailerSize && campaign.id && campaign.allowedToCacheVideo;
  }
}

- (BOOL)cache:(ResourceType)resourceType forCampaign:(ApplifierImpactCampaign *)campaign {
  @synchronized(self) {
    if ([self campaignExistsInQueue:campaign withResourceType:resourceType] ||
        ![self _isCampaignValid:campaign]) return NO;
    
    ApplifierImpactCacheOperation * cacheOperation = nil;
    
    if (resourceType == ResourceTypeTrailerVideo) {
      ApplifierImpactCacheFileOperation  * tmp = [ApplifierImpactCacheFileOperation new];
      tmp.directoryPath = [self _cachePath];
      tmp.downloadURL = [self _downloadURLFor:resourceType of:campaign];
      tmp.filePath = [[self localURLFor:resourceType ofCampaign:campaign] relativePath];
      tmp.expectedFileSize = campaign.expectedTrailerSize;
      cacheOperation = tmp;
    }
    NSString * key = [self operationKey:campaign resourceType:resourceType];
    cacheOperation.delegate = self;
    cacheOperation.operationKey = key;
    cacheOperation.resourceType = resourceType;
    self.campaignsOperations[key] = @{ kApplifierImpactCacheOperationKey : cacheOperation,
                                       kApplifierImpactCacheOperationCampaignKey : campaign };
    [self.cacheOperationsQueue addOperation:cacheOperation];
    return YES;
  }
}

- (void)cancelCacheForCampaign:(ApplifierImpactCampaign *)campaign withResourceType:(ResourceType)resourceType {
  @synchronized(self) {
    ApplifierImpactCacheOperation * cacheOperation =
    self.campaignsOperations[[self operationKey:campaign resourceType:resourceType]][kApplifierImpactCacheOperationKey];
    [cacheOperation cancel];
  }
}

- (BOOL)is:(ResourceType)resourceType cachedForCampaign:(ApplifierImpactCampaign *)campaign {
  @synchronized(self) {
    BOOL result = NO;
    switch (resourceType) {
      case ResourceTypeTrailerVideo:
        result = [self isCampaignVideoCached:campaign];
        break;
      default:
        break;
    }
    return result;
  }
}



- (NSString *)operationKey:(ApplifierImpactCampaign *)campaign resourceType:(ResourceType)resourceType {
  @synchronized(self) {
    return [NSString stringWithFormat:@"%@-%d", campaign.id, resourceType];
  }
}


- (BOOL)campaignExistsInQueue:(ApplifierImpactCampaign *)campaign
             withResourceType:(ResourceType)resourceType {
  @synchronized(self) {
    return self.campaignsOperations[[self operationKey:campaign resourceType:resourceType]] != nil;
  }
}

- (void)cancelAllDownloads {
  @synchronized(self) {
    [self.cacheOperationsQueue cancelAllOperations];
  }
}

- (void)_removeOperation:(ApplifierImpactCacheOperation *)cacheOperation {
  @synchronized(self) {
    if (!cacheOperation.operationKey) return;
    [self.campaignsOperations removeObjectForKey:cacheOperation.operationKey];
    
    if (self.campaignsOperations.count == 0 &&
        [self.delegate respondsToSelector:@selector(cachingQueueEmpty)])
      [self.delegate cachingQueueEmpty];
  }
}

#pragma mark ----
#pragma mark ApplifierImpactFileCacheOperationDelegate
#pragma mark ----

- (void)cacheOperationStarted:(ApplifierImpactCacheOperation *)cacheOperation  {
  @synchronized(self) {
    NSDictionary * operationInfo = self.campaignsOperations[cacheOperation.operationKey];
    ApplifierImpactCampaign * campaign = operationInfo[kApplifierImpactCacheOperationCampaignKey];
    AILOG_DEBUG(@"for campaign %@", campaign.id);
    if ([self.delegate respondsToSelector:@selector(startedCaching:forCampaign:)])
      [self.delegate startedCaching:cacheOperation.resourceType forCampaign:campaign];
  }
}

- (void)cacheOperationFinished:(ApplifierImpactCacheOperation *)cacheOperation {
  @synchronized(self) {
    NSDictionary * operationInfo = self.campaignsOperations[cacheOperation.operationKey];
    ApplifierImpactCampaign * campaign = operationInfo[kApplifierImpactCacheOperationCampaignKey];
    AILOG_DEBUG(@"for campaign %@", campaign.id);
    if ([self.delegate respondsToSelector:@selector(finishedCaching:forCampaign:)])
      [self.delegate finishedCaching:cacheOperation.resourceType forCampaign:campaign];
    [self _removeOperation:cacheOperation];
  }
}

- (void)cacheOperationFailed:(ApplifierImpactCacheOperation *)cacheOperation {
  @synchronized(self) {
    NSDictionary * operationInfo = self.campaignsOperations[cacheOperation.operationKey];
    ApplifierImpactCampaign * campaign = operationInfo[kApplifierImpactCacheOperationCampaignKey];
    AILOG_DEBUG(@"for campaign %@", campaign.id);
    if ([self.delegate respondsToSelector:@selector(failedCaching:forCampaign:)])
      [self.delegate failedCaching:cacheOperation.resourceType forCampaign:campaign];
    [self _removeOperation:cacheOperation];
  }
}

- (void)cacheOperationCancelled:(ApplifierImpactCacheOperation *)cacheOperation {
  @synchronized(self) {
    NSDictionary * operationInfo = self.campaignsOperations[cacheOperation.operationKey];
    ApplifierImpactCampaign * campaign = operationInfo[kApplifierImpactCacheOperationCampaignKey];
    AILOG_DEBUG(@"for campaign %@", campaign.id);
    if ([self.delegate respondsToSelector:@selector(cancelledCaching:forCampaign:)])
      [self.delegate cancelledCaching:cacheOperation.resourceType forCampaign:campaign];
    [self _removeOperation:cacheOperation];
  }
}

@end