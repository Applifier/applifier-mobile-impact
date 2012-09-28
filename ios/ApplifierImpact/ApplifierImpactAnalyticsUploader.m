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

NSString * const kApplifierImpactAnalyticsURL = @"https://log.applifier.com/videoads-tracking";
NSString * const kApplifierImpactTrackingURL = @"https://impact.applifier.com/gamers/";
NSString * const kApplifierImpactInstallTrackingURL = @"https://impact.applifier.com/games/";
NSString * const kApplifierImpactAnalyticsUploaderRequestKey = @"kApplifierImpactAnalyticsUploaderRequestKey";
NSString * const kApplifierImpactAnalyticsUploaderConnectionKey = @"kApplifierImpactAnalyticsUploaderConnectionKey";
NSString * const kApplifierImpactAnalyticsSavedUploadsKey = @"kApplifierImpactAnalyticsSavedUploadsKey";
NSString * const kApplifierImpactAnalyticsSavedUploadURLKey = @"kApplifierImpactAnalyticsSavedUploadURLKey";
NSString * const kApplifierImpactAnalyticsSavedUploadBodyKey = @"kApplifierImpactAnalyticsSavedUploadBodyKey";
NSString * const kApplifierImpactAnalyticsSavedUploadHTTPMethodKey = @"kApplifierImpactAnalyticsSavedUploadHTTPMethodKey";
NSString * const kApplifierImpactQueryDictionaryQueryKey = @"kApplifierImpactQueryDictionaryQueryKey";
NSString * const kApplifierImpactQueryDictionaryBodyKey = @"kApplifierImpactQueryDictionaryBodyKey";

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
	if ([request URL] != nil)
	{
		[failedUpload setObject:[[request URL] absoluteString] forKey:kApplifierImpactAnalyticsSavedUploadURLKey];
		
		if ([request HTTPBody] != nil)
		{
			NSString *bodyString = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
			[failedUpload setObject:bodyString forKey:kApplifierImpactAnalyticsSavedUploadBodyKey];
		}
		
		[failedUpload setObject:[request HTTPMethod] forKey:kApplifierImpactAnalyticsSavedUploadHTTPMethodKey];
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

- (void)_queueURL:(NSURL *)url body:(NSData *)body httpMethod:(NSString *)httpMethod
{
	if (url == nil)
	{
		AILOG_DEBUG(@"Invalid input.");
		return;
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

	if (request == nil)
	{
		AILOG_ERROR(@"Could not create request with url '%@'.", url);
		return;
	}
	
	[request setHTTPMethod:httpMethod];
	if (body != nil)
		[request setHTTPBody:body];
	
	AILOG_DEBUG(@"queueing %@", [request URL]);
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	NSDictionary *uploadDictionary = @{ kApplifierImpactAnalyticsUploaderRequestKey : request, kApplifierImpactAnalyticsUploaderConnectionKey : connection };
	[self.uploadQueue addObject:uploadDictionary];
	
	if ([self.uploadQueue count] == 1)
		[self _startNextUpload];
}

- (void)_queueWithURLString:(NSString *)urlString queryString:(NSString *)queryString httpMethod:(NSString *)httpMethod
{
	NSURL *url = [NSURL URLWithString:urlString];
	NSData *body = nil;
	if (queryString != nil)
		body = [queryString dataUsingEncoding:NSUTF8StringEncoding];

	[self _queueURL:url body:body httpMethod:httpMethod];
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
	AIAssert( ! [NSThread isMainThread]);
	
	if (queryString == nil || [queryString length] == 0)
	{
		AILOG_DEBUG(@"Invalid input.");
		return;
	}
	
	[self _queueWithURLString:kApplifierImpactAnalyticsURL queryString:queryString httpMethod:@"POST"];
}

- (void)sendTrackingCallWithQueryString:(NSString *)queryString
{
	AIAssert( ! [NSThread isMainThread]);
	
	if (queryString == nil || [queryString length] == 0)
	{
		AILOG_DEBUG(@"Invalid input.");
		return;
	}
	
	[self _queueWithURLString:[kApplifierImpactTrackingURL stringByAppendingString:queryString] queryString:nil httpMethod:@"GET"];
}

- (void)sendInstallTrackingCallWithQueryDictionary:(NSDictionary *)queryDictionary
{
	AIAssert( ! [NSThread isMainThread]);
	
	if (queryDictionary == nil)
	{
		AILOG_DEBUG(@"Invalid input.");
		return;
	}
	
	NSString *query = [queryDictionary objectForKey:kApplifierImpactQueryDictionaryQueryKey];
	NSString *body = [queryDictionary objectForKey:kApplifierImpactQueryDictionaryBodyKey];
	
	if (query == nil || [query length] == 0 || body == nil || [body length] == 0)
	{
		AILOG_DEBUG(@"Invalid parameters in query dictionary.");
		return;
	}
	
	[self _queueWithURLString:[kApplifierImpactInstallTrackingURL stringByAppendingString:query] queryString:body httpMethod:@"POST"];
}

- (void)retryFailedUploads
{
	AIAssert( ! [NSThread isMainThread]);
	
	NSArray *uploads = [[NSUserDefaults standardUserDefaults] arrayForKey:kApplifierImpactAnalyticsSavedUploadsKey];
	if (uploads != nil)
	{
		for (NSDictionary *upload in uploads)
		{
			NSString *url = [upload objectForKey:kApplifierImpactAnalyticsSavedUploadURLKey];
			NSString *body = [upload objectForKey:kApplifierImpactAnalyticsSavedUploadBodyKey];
			NSString *httpMethod = [upload objectForKey:kApplifierImpactAnalyticsSavedUploadHTTPMethodKey];
			[self _queueURL:[NSURL URLWithString:url] body:[body dataUsingEncoding:NSUTF8StringEncoding] httpMethod:httpMethod];
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
