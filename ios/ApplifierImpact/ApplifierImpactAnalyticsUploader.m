//
//  ApplifierImpactAnalyticsUploader.m
//  ImpactProto
//
//  Created by Johan Halin on 13.9.2012.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactAnalyticsUploader.h"
#import "ApplifierImpactCampaign.h"
#import "ApplifierImpact.h"

NSString * const kApplifierImpactAnalyticsURL = @"http://log.applifier.com/videoads-tracking";
NSString * const kApplifierImpactAnalyticsUploaderRequestKey = @"kApplifierImpactAnalyticsUploaderRequestKey";
NSString * const kApplifierImpactAnalyticsUploaderConnectionKey = @"kApplifierImpactAnalyticsUploaderConnectionKey";
NSString * const kApplifierImpactAnalyticsSavedUploadsKey = @"kApplifierImpactAnalyticsSavedUploadsKey";

@interface ApplifierImpactAnalyticsUploader () <NSURLConnectionDelegate>
@property (nonatomic, strong) NSMutableArray *uploadQueue;
@property (nonatomic, strong) NSDictionary *currentUpload;
@end

@implementation ApplifierImpactAnalyticsUploader

@synthesize uploadQueue = _uploadQueue;
@synthesize currentUpload = _currentUpload;

#pragma mark - Private

- (void)_saveFailedUpload:(NSDictionary *)download
{
	if (download == nil)
	{
		AILOG_DEBUG(@"Input is nil.");
		return;
	}
	
	NSMutableArray *existingFailedUploads = [[[NSUserDefaults standardUserDefaults] arrayForKey:kApplifierImpactAnalyticsSavedUploadsKey] mutableCopy];
	
	if (existingFailedUploads == nil)
		existingFailedUploads = [NSMutableArray array];
	
	NSURLRequest *request = [download objectForKey:kApplifierImpactAnalyticsUploaderRequestKey];
	NSString *urlString = [[request URL] absoluteString];
	[existingFailedUploads addObject:urlString];
	AILOG_DEBUG(@"%@", existingFailedUploads);
	[[NSUserDefaults standardUserDefaults] setObject:existingFailedUploads forKey:kApplifierImpactAnalyticsSavedUploadsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)_startNextUpload
{
	if (self.currentUpload != nil)
		return NO;
	
	if ([self.uploadQueue count] > 0)
	{
		self.currentUpload = [self.uploadQueue objectAtIndex:0];
		
		NSURLConnection *connection = [self.currentUpload objectForKey:kApplifierImpactAnalyticsUploaderConnectionKey];
		[connection start];
		
		[self.uploadQueue removeObjectAtIndex:0];
	}
	else
		return NO;
	
	return YES;
}

- (void)_queueURL:(NSURL *)url
{
	if (url == nil)
	{
		AILOG_DEBUG(@"Input is nil.");
		return;
	}
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	if (request == nil)
	{
		AILOG_DEBUG(@"Request could not be created.");
		return;
	}
	
	AILOG_DEBUG(@"queueing %@", url);
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	NSDictionary *uploadDictionary = @{ kApplifierImpactAnalyticsUploaderRequestKey : request, kApplifierImpactAnalyticsUploaderConnectionKey : connection };
	[self.uploadQueue addObject:uploadDictionary];
	
	if ([self.uploadQueue count] == 1)
		[self _startNextUpload];
}

#pragma mark - Public

- (id)init
{
	if ((self = [super init]))
	{
		_uploadQueue = [NSMutableArray array];
	}
	
	return self;
}

- (void)sendViewReportForCampaign:(ApplifierImpactCampaign *)campaign positionString:(NSString *)positionString
{
	if ([NSThread isMainThread])
	{
		AILOG_ERROR(@"Cannot be run on main thread.");
		return;
	}
	
	if (campaign == nil || positionString == nil || [positionString length] == 0)
	{
		AILOG_DEBUG(@"Invalid input.");
		return;
	}
	
	NSString *urlString = [kApplifierImpactAnalyticsURL stringByAppendingFormat:@"?d={\"did\":\"%@\",\"c\":\"%@\",\"pos\":\"%@\"}", @"test", campaign.id, positionString];
	[self _queueURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

- (void)retryFailedUploads
{
	if ([NSThread isMainThread])
	{
		AILOG_ERROR(@"Cannot be run on main thread.");
		return;
	}

	NSArray *uploads = [[NSUserDefaults standardUserDefaults] arrayForKey:kApplifierImpactAnalyticsSavedUploadsKey];
	if (uploads != nil)
	{
		for (NSString *url in uploads)
		{
			if ([url isKindOfClass:[NSString class]])
			{
				[self _queueURL:[NSURL URLWithString:url]];
			}
		}
		
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kApplifierImpactAnalyticsSavedUploadsKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	AILOG_DEBUG(@"analytics upload finished");
	
	self.currentUpload = nil;
	
	[self _startNextUpload];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	AILOG_DEBUG(@"%@", error);
	
	[self _saveFailedUpload:self.currentUpload];

	self.currentUpload = nil;
	
	[self _startNextUpload];
}

@end
