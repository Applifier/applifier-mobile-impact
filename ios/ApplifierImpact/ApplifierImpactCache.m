//
//  ApplifierImpactCache.m
//  ImpactProto
//
//  Created by Johan Halin on 9/6/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpact.h"
#import "ApplifierImpactCache.h"
#import "ApplifierImpactCampaign.h"

NSString * const kApplifierImpactCacheCampaignKey = @"kApplifierImpactCacheCampaignKey";
NSString * const kApplifierImpactCacheConnectionKey = @"kApplifierImpactCacheConnectionKey";
NSString * const kApplifierImpactCacheFilePathKey = @"kApplifierImpactCacheFilePathKey";
NSString * const kApplifierImpactCacheURLRequestKey = @"kApplifierImpactCacheURLRequestKey";
NSString * const kApplifierImpactCacheIndexKey = @"kApplifierImpactCacheIndexKey";

NSString * const kApplifierImpactCacheEntryCampaignIDKey = @"kApplifierImpactCacheEntryCampaignIDKey";
NSString * const kApplifierImpactCacheEntryFilenameKey = @"kApplifierImpactCacheEntryFilenameKey";

@interface ApplifierImpactCache () <NSURLConnectionDelegate>
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSMutableArray *downloadQueue;
@property (nonatomic, strong) NSMutableDictionary *currentDownload;
@end

@implementation ApplifierImpactCache

@synthesize delegate = _delegate;
@synthesize fileHandle = _fileHandle;
@synthesize downloadQueue = _downloadQueue;
@synthesize currentDownload = _currentDownload;

#pragma mark - Private

- (NSString *)_cachePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	if (paths == nil || [paths count] == 0)
		return nil;
	
	return [[paths objectAtIndex:0] stringByAppendingString:@"/applifier/"];
}

- (NSString *)_videoFilenameForCampaign:(ApplifierImpactCampaign *)campaign
{
	return [NSString stringWithFormat:@"%@-%@", campaign.id, [campaign.trailerDownloadableURL lastPathComponent]];
}

- (NSString *)_videoPathForCampaign:(ApplifierImpactCampaign *)campaign
{
	return [[self _cachePath] stringByAppendingString:[self _videoFilenameForCampaign:campaign]];
}

- (void)_queueCampaignDownload:(ApplifierImpactCampaign *)campaign;
{
	if (campaign == nil)
	{
		AILOG_DEBUG(@"Campaign cannot be nil.");
		return;
	}
	
	AILOG_DEBUG(@"Queueing %@, id %@", campaign.trailerDownloadableURL, campaign.id);
	
	NSString *filePath = [self _videoPathForCampaign:campaign];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:campaign.trailerDownloadableURL];
	NSMutableDictionary *downloadDictionary = [NSMutableDictionary dictionary];
	[downloadDictionary setObject:request forKey:kApplifierImpactCacheURLRequestKey];
	[downloadDictionary setObject:campaign forKey:kApplifierImpactCacheCampaignKey];
	[downloadDictionary setObject:filePath forKey:kApplifierImpactCacheFilePathKey];
	[self.downloadQueue addObject:downloadDictionary];
	[self _startDownload];
}

- (BOOL)_startNextDownloadInQueue
{
	if (self.currentDownload != nil)
		return NO;
	
	if ([self.downloadQueue count] > 0)
	{
		self.currentDownload = [self.downloadQueue objectAtIndex:0];
		
		NSMutableURLRequest *request = [self.currentDownload objectForKey:kApplifierImpactCacheURLRequestKey];
		NSString *filePath = [self.currentDownload objectForKey:kApplifierImpactCacheFilePathKey];
		long long rangeStart = 0;
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
		{
			NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
			rangeStart = [attributes fileSize];
		}
		else
		{
			if ( ! [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil])
			{
				AILOG_DEBUG(@"Unable to create file at %@", filePath);
				self.currentDownload = nil;
				return NO;
			}
		}
		
		self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
		if (rangeStart > 0)
		{
			[self.fileHandle seekToEndOfFile];
			[request setValue:[NSString stringWithFormat:@"bytes=%qi-", rangeStart] forHTTPHeaderField:@"Range"];
		}
		
		NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
		[self.currentDownload setObject:urlConnection forKey:kApplifierImpactCacheConnectionKey];
		[urlConnection start];

		[self.downloadQueue removeObjectAtIndex:0];
	}
	else
		return NO;
	
	AILOG_DEBUG(@"starting download %@", self.currentDownload);

	return YES;
}

- (void)_startDownload
{
	BOOL downloadStarted = [self _startNextDownloadInQueue];
	if ( ! downloadStarted && self.currentDownload == nil && [self.downloadQueue count] > 0)
		[self performSelector:@selector(_startDownload) withObject:self afterDelay:3.0];
}

- (void)_downloadFinishedWithFailure:(BOOL)failure
{
	AILOG_DEBUG(@"download finished with failure: %@", failure ? @"yes" : @"no");
	
	[self.fileHandle closeFile];
	self.fileHandle = nil;
	
	if (failure)
	{
		ApplifierImpactCampaign *campaign = [self.currentDownload objectForKey:kApplifierImpactCacheCampaignKey];
		[self _queueCampaignDownload:campaign];
	}
	else
	{
		if ([self.delegate respondsToSelector:@selector(cache:finishedCachingCampaign:)])
			[self.delegate cache:self finishedCachingCampaign:[self.currentDownload objectForKey:kApplifierImpactCacheCampaignKey]];
	}
	
	self.currentDownload = nil;
	
	if ([self.downloadQueue count] == 0)
	{
		if ([self.delegate respondsToSelector:@selector(cacheFinishedCachingCampaigns:)])
			[self.delegate cacheFinishedCachingCampaigns:self];
	}
	
	[self _startDownload];
}

- (void)_compareCampaigns:(NSArray *)campaigns
{
	if (campaigns == nil || [campaigns count] == 0)
	{
		AILOG_DEBUG(@"No new campaigns.");
		return;
	}
	
	NSString *cachePath = [self _cachePath];
	NSArray *oldIndex = [[NSUserDefaults standardUserDefaults] arrayForKey:kApplifierImpactCacheIndexKey];

	NSMutableArray *index = [NSMutableArray array];
	for (ApplifierImpactCampaign *campaign in campaigns)
	{
		NSMutableDictionary *campaignIndexEntry = [NSMutableDictionary dictionary];
		if (campaign.id != nil && campaign.trailerDownloadableURL != nil)
		{
			[campaignIndexEntry setObject:campaign.id forKey:kApplifierImpactCacheEntryCampaignIDKey];
			[campaignIndexEntry setObject:[self _videoFilenameForCampaign:campaign] forKey:kApplifierImpactCacheEntryFilenameKey];
			[index addObject:campaignIndexEntry];
		}
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:index forKey:kApplifierImpactCacheIndexKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	for (NSDictionary *oldIndexEntry in oldIndex)
	{
		if ( ! [index containsObject:oldIndexEntry])
		{
			NSString *filename = [oldIndexEntry objectForKey:kApplifierImpactCacheEntryFilenameKey];
			NSString *filePath = [cachePath stringByAppendingString:filename];
			NSError *error = nil;
			if ( ! [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
			{
				AILOG_DEBUG(@"Unable to remove file. %@", error);
			}
		}
	}
}

#pragma mark - Public

- (id)init
{
	if ([NSThread isMainThread])
	{
		AILOG_ERROR(@"-init cannot be called from main thread.");
		return nil;
	}
	
	if ((self = [super init]))
	{
		_downloadQueue = [NSMutableArray array];
	}
	
	return self;
}

- (void)cacheCampaigns:(NSArray *)campaigns
{
	if ([NSThread isMainThread])
	{
		AILOG_ERROR(@"-cacheCampaigns: cannot be called from main thread.");
		return;
	}
	
	NSError *error = nil;
	NSString *cachePath = [self _cachePath];
	if ( ! [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error])
	{
		AILOG_DEBUG(@"Couldn't create cache path. Error: %@", error);
		return;
	}
	
	// TODO: check queue for existing downloads that should be cancelled
	
	for (ApplifierImpactCampaign *campaign in campaigns)
	{
		[self _queueCampaignDownload:campaign];
	}
	
	[self _compareCampaigns:campaigns];
}

- (NSURL *)localVideoURLForCampaign:(ApplifierImpactCampaign *)campaign
{
	@synchronized (self)
	{
		NSString *path = [self _videoPathForCampaign:campaign];
		
		return [NSURL fileURLWithPath:path];
	}
}

- (void)cancelAllDownloads
{
	if ([NSThread isMainThread])
	{
		AILOG_ERROR(@"-cancelAllDownloads cannot be called from main thread.");
		return;
	}
	
	if (self.currentDownload != nil)
	{
		NSURLConnection *connection = [self.currentDownload objectForKey:kApplifierImpactCacheConnectionKey];
		[connection cancel];
		[self.fileHandle closeFile];
		self.fileHandle = nil;
		self.currentDownload = nil;
	}
	
	[self.downloadQueue removeAllObjects];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSHTTPURLResponse *httpResponse = nil;
	if ([response isKindOfClass:[NSHTTPURLResponse class]])
		httpResponse = (NSHTTPURLResponse *)response;
	
	NSNumber *contentLength = [[httpResponse allHeaderFields] objectForKey:@"Content-Length"];
	if (contentLength != nil)
	{
		long long size = [contentLength longLongValue];
		NSDictionary *fsAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[self _cachePath] error:nil];
		if (fsAttributes != nil)
		{
			long long freeSpace = [[fsAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
			if (size > freeSpace)
			{
				AILOG_DEBUG(@"Not enough space, canceling download. (%lld needed, %lld free)", size, freeSpace);
				[connection cancel];
				[self _downloadFinishedWithFailure:YES];
			}
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.fileHandle writeData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self _downloadFinishedWithFailure:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	AILOG_DEBUG(@"%@", error);
	
	[self _downloadFinishedWithFailure:YES];
}

@end
