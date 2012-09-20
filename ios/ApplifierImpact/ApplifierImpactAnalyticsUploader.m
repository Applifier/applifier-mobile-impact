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
NSString * const kApplifierImpactAnalyticsSavedUploadURLKey = @"kApplifierImpactAnalyticsSavedUploadURLKey";
NSString * const kApplifierImpactAnalyticsSavedUploadBodyKey = @"kApplifierImpactAnalyticsSavedUploadBodyKey";

@interface ApplifierImpactAnalyticsUploader () <NSURLConnectionDelegate>
@property (nonatomic, strong) NSMutableArray *uploadQueue;
@property (nonatomic, strong) NSDictionary *currentUpload;
@end

@implementation ApplifierImpactAnalyticsUploader

#pragma mark - Private

- (void)_saveFailedUpload:(NSDictionary *)upload
{
	if (upload == nil)
	{
		AILOG_DEBUG(@"Input is nil.");
		return;
	}
	
	NSMutableArray *existingFailedUploads = [[[NSUserDefaults standardUserDefaults] arrayForKey:kApplifierImpactAnalyticsSavedUploadsKey] mutableCopy];
	
	if (existingFailedUploads == nil)
		existingFailedUploads = [NSMutableArray array];
	
	NSURLRequest *request = [upload objectForKey:kApplifierImpactAnalyticsUploaderRequestKey];
	NSMutableDictionary *failedUpload = [NSMutableDictionary dictionary];
	if ([request URL] != nil && [request HTTPBody] != nil)
	{
		[failedUpload setObject:[[request URL] absoluteString] forKey:kApplifierImpactAnalyticsSavedUploadURLKey];
		NSString *bodyString = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
		[failedUpload setObject:bodyString forKey:kApplifierImpactAnalyticsSavedUploadBodyKey];
		[existingFailedUploads addObject:failedUpload];
		
		AILOG_DEBUG(@"%@", existingFailedUploads);
		[[NSUserDefaults standardUserDefaults] setObject:existingFailedUploads forKey:kApplifierImpactAnalyticsSavedUploadsKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
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

- (void)_queueURL:(NSURL *)url body:(NSData *)body
{
	if (url == nil || body == nil)
	{
		AILOG_DEBUG(@"Invalid input.");
		return;
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

	if (request == nil)
	{
		AILOG_DEBUG(@"Could not create request.");
		return;
	}
	
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:body];
	
	AILOG_DEBUG(@"queueing %@", [request URL]);
	
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

- (void)sendViewReportWithQueryString:(NSString *)queryString
{
	if ([NSThread isMainThread])
	{
		AILOG_ERROR(@"Cannot be run on main thread.");
		return;
	}
	
	if (queryString == nil || [queryString length] == 0)
	{
		AILOG_DEBUG(@"Invalid input.");
		return;
	}
	
	NSURL *url = [NSURL URLWithString:kApplifierImpactAnalyticsURL];
	[self _queueURL:url body:[queryString dataUsingEncoding:NSUTF8StringEncoding]];
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
		for (NSDictionary *upload in uploads)
		{
			NSString *url = [upload objectForKey:kApplifierImpactAnalyticsSavedUploadURLKey];
			NSString *body = [upload objectForKey:kApplifierImpactAnalyticsSavedUploadBodyKey];
			[self _queueURL:[NSURL URLWithString:url] body:[body dataUsingEncoding:NSUTF8StringEncoding]];
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
