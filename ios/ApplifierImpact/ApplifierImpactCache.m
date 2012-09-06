//
//  ApplifierImpactCache.m
//  ImpactProto
//
//  Created by Johan Halin on 9/6/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactCache.h"
#import "ApplifierImpactCampaign.h"

@interface ApplifierImpactCache () <NSURLConnectionDelegate>
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableArray *downloadQueue;
@end

@implementation ApplifierImpactCache

@synthesize fileHandle = _fileHandle;
@synthesize urlConnection = _urlConnection;
@synthesize downloadQueue = _downloadQueue;

#pragma mark - Private

- (NSString *)_cachePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	if (paths == nil || [paths count] == 0)
		return nil;
	
	return [[paths objectAtIndex:0] stringByAppendingString:@"/"];
}

- (void)_downloadCampaignToCache:(ApplifierImpactCampaign *)campaign;
{
	NSLog(@"Downloading %@", campaign.trailerDownloadableURL);
	
	NSString *filePath = [[self _cachePath] stringByAppendingString:[campaign.trailerDownloadableURL lastPathComponent]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		NSLog(@"TODO: file exists"); // e.g., resume or what
		
		return;
	}
	else
		[[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
	
	self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:campaign.trailerDownloadableURL];
	self.urlConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - Public

- (void)cacheCampaigns:(NSArray *)campaigns
{
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
	[self.fileHandle closeFile];
	self.fileHandle = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"didFailWithError: %@", error);
	
	[self.fileHandle closeFile];
	self.fileHandle = nil;
}

@end
