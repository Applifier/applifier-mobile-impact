//
//  ApplifierImpactCache.m
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "../ApplifierImpact.h"
#import "ApplifierImpactCache.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "ApplifierImpactInstrumentation.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"

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

@interface ApplifierImpactCache () <NSURLConnectionDelegate>
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSMutableArray *downloadQueue;
@property (nonatomic, strong) NSMutableDictionary *currentDownload;
@end

@implementation ApplifierImpactCache

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

- (BOOL)_queueCampaignDownload:(ApplifierImpactCampaign *)campaign {
	if (campaign == nil) {
		AILOG_DEBUG(@"Campaign cannot be nil.");
		return NO;
	}
	
  if (campaign.shouldCacheVideo) {
    NSString *filePath = [self _videoPathForCampaign:campaign];
    long long existingFilesize = [self _filesizeForPath:filePath];
    long long filesize = [self _cachedFilesizeForVideoFilename:[self _videoFilenameForCampaign:campaign]];
    
    if (![self campaignExistsInQueue:campaign] && (existingFilesize < filesize || filesize == 0)) {
      AILOG_DEBUG(@"Queueing %@, id %@", campaign.trailerDownloadableURL, campaign.id);
      
      // Initialize downloadque only if it's NULL
      if (_downloadQueue == nil) {
        _downloadQueue = [NSMutableArray array];
      }
      
      NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:campaign.trailerDownloadableURL];
      NSMutableDictionary *downloadDictionary = [NSMutableDictionary dictionary];
      [downloadDictionary setObject:request forKey:kApplifierImpactCacheURLRequestKey];
      [downloadDictionary setObject:campaign forKey:kApplifierImpactCacheCampaignKey];
      [downloadDictionary setObject:filePath forKey:kApplifierImpactCacheFilePathKey];
      [downloadDictionary setObject:(existingFilesize > 0 ? kApplifierImpactCacheDownloadResumeExpected : kApplifierImpactCacheDownloadNewDownload) forKey:kApplifierImpactCacheResumeKey];
      [self.downloadQueue addObject:downloadDictionary];
      [self _startDownload];
      
      return YES;
    }
  }
  else {
    AILOG_DEBUG(@"Skipping campaign video caching: cacheVideo is false");
  }
	
	return NO;
}

- (long long)_filesizeForPath:(NSString *)path {
	long long size = 0;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
		size = [attributes fileSize];
	}
	
	return size;
}

- (BOOL)_startNextDownloadInQueue {
	if (self.currentDownload != nil || [self.downloadQueue count] == 0)
		return NO;
	
	self.currentDownload = [self.downloadQueue objectAtIndex:0];
	
	NSMutableURLRequest *request = [self.currentDownload objectForKey:kApplifierImpactCacheURLRequestKey];
	NSString *filePath = [self.currentDownload objectForKey:kApplifierImpactCacheFilePathKey];
	
	if ( ! [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		if ( ! [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
			AILOG_DEBUG(@"Unable to create file at %@", filePath);
			self.currentDownload = nil;
			return NO;
		}
	}
	
	self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
	[self.fileHandle seekToEndOfFile];
	long long rangeStart = [self.fileHandle offsetInFile];
	if (rangeStart > 0)
		[request setValue:[NSString stringWithFormat:@"bytes=%qi-", rangeStart] forHTTPHeaderField:@"Range"];
	
	NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	[self.currentDownload setObject:urlConnection forKey:kApplifierImpactCacheConnectionKey];
	[urlConnection start];
	
  ApplifierImpactCampaign *campaign = [self.currentDownload objectForKey:kApplifierImpactCacheCampaignKey];
  if (campaign != nil) {
    long long cachingStarted = [[NSDate date] timeIntervalSince1970] * 1000;
    campaign.videoCachingStartTime = cachingStarted;
    [ApplifierImpactInstrumentation gaInstrumentationVideoCaching:campaign withValuesFrom:@{kApplifierImpactGoogleAnalyticsEventValueKey:kApplifierImpactGoogleAnalyticsEventVideoCachingStart}];
  }
  
	[self.downloadQueue removeObjectAtIndex:0];
	
	AILOG_DEBUG(@"starting download %@", self.currentDownload);

	return YES;
}

- (void)_startDownload {
	BOOL downloadStarted = [self _startNextDownloadInQueue];
	if ( ! downloadStarted && self.currentDownload == nil && [self.downloadQueue count] > 0)
		[self performSelector:@selector(_startDownload) withObject:self afterDelay:3.0];
}

- (void)_downloadFinishedWithFailure:(BOOL)failure {
	AILOG_DEBUG(@"download finished with failure: %@", failure ? @"yes" : @"no");
	
  NSError *err;
	[self.fileHandle closeFile];
	self.fileHandle = nil;
  long long cachingFinished = [[NSDate date] timeIntervalSince1970] * 1000;
	ApplifierImpactCampaign *campaign = [self.currentDownload objectForKey:kApplifierImpactCacheCampaignKey];
  campaign.videoCachingEndTime = cachingFinished;
  
  // Check that file came through OK
  if (!failure) {
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.currentDownload objectForKey:kApplifierImpactCacheFilePathKey] error:&err];
    
    if (err == nil) {
      NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
      long long fileSize = [fileSizeNumber longLongValue];
      AILOG_DEBUG(@"File size values are: expectedSize=%lld, actualSize=%lld", campaign.expectedTrailerSize, fileSize);
      if (campaign.expectedTrailerSize > 0 && fileSize != campaign.expectedTrailerSize) {
        AILOG_DEBUG(@"Problems with file size, expected: %lld, got: %lld", campaign.expectedTrailerSize, fileSize);
        [[NSFileManager defaultManager] removeItemAtPath:[self.currentDownload objectForKey:kApplifierImpactCacheFilePathKey] error:&err];
        NSDictionary *data = @{kApplifierImpactGoogleAnalyticsEventValueKey:kApplifierImpactGoogleAnalyticsEventVideoCachingFailed};
        [ApplifierImpactInstrumentation gaInstrumentationVideoCaching:campaign withValuesFrom:data];
      }
    }
    else {
      AILOG_DEBUG(@"Could not get file stats, something could be wrong with the file!");
    }
  }
  
  // FIX: _queueCampaignDownload cannot ever start download again because self.currentDownload has a reference
  // to the failed campaign and existinqueue will say YES. Currently okay since downloads do not support retries
  // and therefore any of the files could remain in forever download loop. Fix downloads to have retries.
  
	if (failure) {		
		[self _queueCampaignDownload:campaign];
    if ([self isCampaignVideoCached:campaign]) {
      [[NSFileManager defaultManager] removeItemAtPath:[self.currentDownload objectForKey:kApplifierImpactCacheFilePathKey] error:&err];
    }
    NSDictionary *data = @{kApplifierImpactGoogleAnalyticsEventValueKey:kApplifierImpactGoogleAnalyticsEventVideoCachingFailed};
    [ApplifierImpactInstrumentation gaInstrumentationVideoCaching:campaign withValuesFrom:data];
	}
	else {
		[self.delegate cache:self finishedCachingCampaign:[self.currentDownload objectForKey:kApplifierImpactCacheCampaignKey]];
    NSDictionary *data = @{kApplifierImpactGoogleAnalyticsEventValueKey:kApplifierImpactGoogleAnalyticsEventVideoCachingCompleted,
                           kApplifierImpactGoogleAnalyticsEventCachingDurationKey:@(campaign.videoCachingEndTime - campaign.videoCachingStartTime)};
    [ApplifierImpactInstrumentation gaInstrumentationVideoCaching:campaign withValuesFrom:data];
  }
	
	self.currentDownload = nil;
	
	if ([self.downloadQueue count] == 0) {
    [self.delegate cacheFinishedCachingCampaigns:self];
    _downloadQueue = nil;
  }
		
	[self _startDownload];
}

- (void)_cleanUpIndexWithCampaigns:(NSArray *)campaigns {
	// FIXME: what to do with old campaigns?
	
  if (campaigns == nil || [campaigns count] == 0) {
		AILOG_DEBUG(@"No new campaigns.");
		return;
	}
	
	NSString *cachePath = [self _cachePath];
	NSMutableArray *oldIndex = [[[NSUserDefaults standardUserDefaults] arrayForKey:kApplifierImpactCacheIndexKey] mutableCopy];
	NSMutableArray *entriesToRemove = [NSMutableArray array];
	
	for (NSDictionary *oldEntry in oldIndex) {
		NSString *oldFilename = [oldEntry objectForKey:kApplifierImpactCacheEntryFilenameKey];
		NSString *oldCampaignID = [oldEntry objectForKey:kApplifierImpactCacheEntryCampaignIDKey];
		BOOL found = NO;
		
		for (ApplifierImpactCampaign *campaign in campaigns) {
			NSString *filename = [self _videoFilenameForCampaign:campaign];
			if ([oldFilename isEqualToString:filename] && [oldCampaignID isEqualToString:campaign.id]) {
				found = YES;
				break;
			}
		}
		
		if (!found) {
			NSString *filePath = [cachePath stringByAppendingPathComponent:oldFilename];
			NSError *error = nil;
			if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
				AILOG_DEBUG(@"Deleted file '%@'", filePath);
				[entriesToRemove addObject:oldEntry];
			}
			else
				AILOG_DEBUG(@"Unable to remove file. %@", error);
		}
	}
	
	if ([entriesToRemove count] > 0) {
		AILOG_DEBUG(@"Removing entries from index: %@", entriesToRemove);
		[oldIndex removeObjectsInArray:entriesToRemove];
		[[NSUserDefaults standardUserDefaults] setObject:oldIndex forKey:kApplifierImpactCacheIndexKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	else
		AILOG_DEBUG(@"No cache index entries to remove.");
}

- (void)_saveCurrentlyDownloadingCampaignToIndexWithFilesize:(long long)filesize {
	NSMutableArray *index = [[[NSUserDefaults standardUserDefaults] arrayForKey:kApplifierImpactCacheIndexKey] mutableCopy];
	if (index == nil)
		index = [NSMutableArray array];
	
	ApplifierImpactCampaign *campaign = [self.currentDownload objectForKey:kApplifierImpactCacheCampaignKey];

	BOOL found = NO;
	if (campaign != nil) {
		for (NSDictionary *cacheEntry in index) {
			NSString *campaignID = [cacheEntry objectForKey:kApplifierImpactCacheEntryCampaignIDKey];
			if ([campaignID isEqualToString:campaign.id]) {
				NSString *filename = [self _videoFilenameForCampaign:campaign];
				NSString *oldFilename = [cacheEntry objectForKey:kApplifierImpactCacheEntryFilenameKey];
				
				if ([filename isEqualToString:oldFilename]) {
					found = YES;
					break;
				}
			}
		}

		if (!found) {
			AILOG_DEBUG(@"Adding campaign '%@' to index.", campaign.id);
			NSMutableDictionary *cacheEntry = [NSMutableDictionary dictionary];
			[cacheEntry setObject:campaign.id forKey:kApplifierImpactCacheEntryCampaignIDKey];
			[cacheEntry setObject:[self _videoFilenameForCampaign:campaign] forKey:kApplifierImpactCacheEntryFilenameKey];
			[cacheEntry setObject:[NSNumber numberWithLongLong:filesize] forKey:kApplifierImpactCacheEntryFilesizeKey];
			[index addObject:cacheEntry];
			[[NSUserDefaults standardUserDefaults] setObject:index forKey:kApplifierImpactCacheIndexKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		else
			AILOG_DEBUG(@"Campaign '%@' already exists in index.", campaign.id);
	}
}

- (void)_removeInvalidDownloadsWithCampaigns:(NSArray *)campaigns {
  if ([self.downloadQueue count] == 0) {
		AILOG_DEBUG(@"No downloads queued.");
		return;
	}
  
	NSMutableArray *downloadsToRemove = [NSMutableArray array];
	
	for (NSDictionary *downloadDictionary in self.downloadQueue) {
		ApplifierImpactCampaign *downloadCampaign = [downloadDictionary objectForKey:kApplifierImpactCacheCampaignKey];
		BOOL found = NO;
		
		for (ApplifierImpactCampaign *campaign in campaigns) {
			if ([campaign.id isEqualToString:downloadCampaign.id] && [campaign.trailerDownloadableURL isEqual:downloadCampaign.trailerDownloadableURL]) {
				found = YES;
				break;
			}
		}
		
		if (!found)
			[downloadsToRemove addObject:downloadDictionary];
	}
	
	if ([downloadsToRemove count] > 0) {
		AILOG_DEBUG(@"Removing downloads from queue: %@", downloadsToRemove);
		[self.downloadQueue removeObjectsInArray:downloadsToRemove];
	}
	else
		AILOG_DEBUG(@"Not removing any downloads from the queue.");
}


#pragma mark - Public

- (id)init {
	AIAssertV(![NSThread isMainThread], nil);
	
	if ((self = [super init])) {
    AILOG_DEBUG(@"creating downloadqueue");
	}
	
	return self;
}

- (void)cacheCampaigns:(NSArray *)campaigns {
	AIAssert(![NSThread isMainThread]);

  if (campaigns == nil) {
		AILOG_DEBUG(@"Input is nil.");
		return;
	}
	
	NSError *error = nil;
	NSString *cachePath = [self _cachePath];
  
	if (![[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error]) {
		AILOG_DEBUG(@"Couldn't create cache path. Error: %@", error);
		return;
	}
	
	[self _removeInvalidDownloadsWithCampaigns:campaigns];
	[self _cleanUpIndexWithCampaigns:campaigns];
  
  BOOL downloadsQueued = NO;
  
	for (ApplifierImpactCampaign *campaign in campaigns) {
		if ([self _queueCampaignDownload:campaign]) {
      downloadsQueued = YES;
    } 	  
	}
	
	if (!downloadsQueued) {
		AILOG_DEBUG(@"No new or partial videos to download.");
		[self.delegate cacheFinishedCachingCampaigns:self];
	}
}

- (BOOL)campaignExistsInQueue:(ApplifierImpactCampaign *)campaign {
  BOOL existsInQueue = NO;
  
  if (self.downloadQueue != nil) {
    for (NSDictionary *downloadDictionary in self.downloadQueue) {
      ApplifierImpactCampaign *downloadCampaign = [downloadDictionary objectForKey:kApplifierImpactCacheCampaignKey];
      if ([downloadCampaign.id isEqualToString:campaign.id]) {
        existsInQueue = YES;
        break;
      }
    }
  }
  
  ApplifierImpactCampaign *currentDownloadingCampaign = [self.currentDownload objectForKey:kApplifierImpactCacheCampaignKey];
  if ([currentDownloadingCampaign.id isEqualToString:campaign.id]) {
    existsInQueue = YES;
  }
  
  if (existsInQueue) {
    AILOG_DEBUG(@"Campaign '%@' exists in downloadQueue.", campaign.id);
  }
	
	return existsInQueue;
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
	AIAssert( ! [NSThread isMainThread]);
	
	if (self.currentDownload != nil) {
		NSURLConnection *connection = [self.currentDownload objectForKey:kApplifierImpactCacheConnectionKey];
		[connection cancel];
		[self.fileHandle closeFile];
		self.fileHandle = nil;
		self.currentDownload = nil;
	}
	
	[self.downloadQueue removeAllObjects];
  _downloadQueue = nil;
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSHTTPURLResponse *httpResponse = nil;
	
  if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
    httpResponse = (NSHTTPURLResponse *)response;
  }

	NSString *resumeStatus = [self.currentDownload objectForKey:kApplifierImpactCacheResumeKey];
	BOOL resumeExpected = [resumeStatus isEqualToString:kApplifierImpactCacheDownloadResumeExpected];
  
	if (resumeExpected && [httpResponse statusCode] == 200) {
		AILOG_DEBUG(@"Resume expected but got status code 200, restarting download.");
		
		[self.fileHandle truncateFileAtOffset:0];
	}
	else if ([httpResponse statusCode] == 206) {
		AILOG_DEBUG(@"Resuming download.");
	}
	
	NSNumber *contentLength = [[httpResponse allHeaderFields] objectForKey:@"Content-Length"];
	if (contentLength != nil) {
		long long size = [contentLength longLongValue];
		[self _saveCurrentlyDownloadingCampaignToIndexWithFilesize:size];
		NSDictionary *fsAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[self _cachePath] error:nil];
		
    if (fsAttributes != nil) {
			long long freeSpace = [[fsAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
			
      if (size > freeSpace) {
				AILOG_DEBUG(@"Not enough space, canceling download. (%lld needed, %lld free)", size, freeSpace);
				[connection cancel];
				[self _downloadFinishedWithFailure:YES];
			}
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [self.fileHandle writeData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self _downloadFinishedWithFailure:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	AILOG_DEBUG(@"%@", error);
	[self _downloadFinishedWithFailure:YES];
}

@end