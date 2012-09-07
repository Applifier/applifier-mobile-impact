//
//  ApplifierImpactCache.m
//  ImpactProto
//
//  Created by Johan Halin on 9/6/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactCache.h"
#import "ApplifierImpactCampaign.h"

NSString const * kApplifierImpactCacheCampaignKey = @"kApplifierImpactCacheCampaignKey";
NSString const * kApplifierImpactCacheConnectionKey = @"kApplifierImpactCacheConnectionKey";
NSString const * kApplifierImpactCacheFilePathKey = @"kApplifierImpactCacheFilePathKey";

@interface ApplifierImpactCache () <NSURLConnectionDelegate>
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSMutableArray *downloadQueue;
@property (nonatomic, strong) NSDictionary *currentDownload;
@end

@implementation ApplifierImpactCache

@synthesize fileHandle = _fileHandle;
@synthesize downloadQueue = _downloadQueue;
@synthesize currentDownload = _currentDownload;

#pragma mark - Private

- (NSString *)_cachePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	if (paths == nil || [paths count] == 0)
		return nil;
	
	return [[paths objectAtIndex:0] stringByAppendingString:@"/"];
}

- (void)_queueCampaignDownload:(ApplifierImpactCampaign *)campaign;
{
	if (campaign == nil)
	{
		NSLog(@"Campaign cannot be nil.");
		return;
	}
	
	NSLog(@"Queueing %@, id %@", campaign.trailerDownloadableURL, campaign.id);
	
	NSString *filePath = [[self _cachePath] stringByAppendingString:[NSString stringWithFormat:@"%@.mp4", campaign.id]];		
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:campaign.trailerDownloadableURL];
	NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	NSDictionary *downloadDictionary = @{ kApplifierImpactCacheCampaignKey : campaign, kApplifierImpactCacheConnectionKey : urlConnection, kApplifierImpactCacheFilePathKey : filePath };
	[self.downloadQueue addObject:downloadDictionary];
	[self _startNextDownloadInQueue];
}

- (BOOL)_startNextDownloadInQueue
{
	if (self.currentDownload != nil)
		return NO;
	
	if ([self.downloadQueue count] > 0)
	{
		self.currentDownload = [self.downloadQueue objectAtIndex:0];
		[self.downloadQueue removeObjectAtIndex:0];
		
		NSString *filePath = [self.currentDownload objectForKey:kApplifierImpactCacheFilePathKey];
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
		{
			NSLog(@"TODO: file exists"); // e.g., resume or what
		}
		else
			[[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];

		self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];

		NSURLConnection *connection = [self.currentDownload objectForKey:kApplifierImpactCacheConnectionKey];
		[connection start];
	}
	else
		return NO;
	
	NSLog(@"starting download %@", self.currentDownload);

	return YES;
}

- (void)_downloadFinishedWithFailure:(BOOL)failure
{
	NSLog(@"download finished with failure: %@", failure ? @"yes" : @"no");
	
	[self.fileHandle closeFile];
	self.fileHandle = nil;
	
	if (failure)
	{
		ApplifierImpactCampaign *campaign = [self.currentDownload objectForKey:kApplifierImpactCacheCampaignKey];
		[self _queueCampaignDownload:campaign];
	}
	
	self.currentDownload = nil;
	
	[self _startNextDownloadInQueue];
}

#pragma mark - Public

- (id)init
{
	if ((self = [super init]))
	{
		_downloadQueue = [NSMutableArray array];
	}
	
	return self;
}

- (void)cacheCampaigns:(NSArray *)campaigns
{
	// TODO: check queue for existing downloads that should be cancelled
	
	for (ApplifierImpactCampaign *campaign in campaigns)
	{
		[self _queueCampaignDownload:campaign];
	}
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"didReceiveResponse: %@", response);
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
	NSLog(@"didFailWithError: %@", error);
	
	[self _downloadFinishedWithFailure:YES];
}

@end
