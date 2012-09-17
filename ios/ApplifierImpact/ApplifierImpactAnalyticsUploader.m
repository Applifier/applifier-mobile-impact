//
//  ApplifierImpactAnalyticsUploader.m
//  ImpactProto
//
//  Created by Johan Halin on 13.9.2012.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactAnalyticsUploader.h"
#import "ApplifierImpactCampaign.h"

NSString * const kApplifierImpactTestAnalyticsURL = @"http://quake.everyplay.fi/~bluesun/impact/manifest.json";
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
	NSMutableArray *existingFailedUploads = [[[NSUserDefaults standardUserDefaults] arrayForKey:kApplifierImpactAnalyticsSavedUploadsKey] mutableCopy];
	
	if (existingFailedUploads == nil)
		existingFailedUploads = [NSMutableArray array];
	
	NSURLRequest *request = [download objectForKey:kApplifierImpactAnalyticsUploaderRequestKey];
	NSString *urlString = [[request URL] absoluteString];
	[existingFailedUploads addObject:urlString];
	NSLog(@"%@", existingFailedUploads);
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
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	if (request == nil)
	{
		NSLog(@"Request could not be created.");
		return;
	}
	
	NSLog(@"queueing %@", url);
	
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
		NSLog(@"Cannot be run on main thread.");
		return;
	}
	
	NSString *urlString = [kApplifierImpactTestAnalyticsURL stringByAppendingFormat:@"?d={\"did\":\"%@\",\"c\":\"%@\",\"pos\":\"%@\"}", @"test", campaign.id, positionString];
	[self _queueURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

- (void)retryFailedUploads
{
	if ([NSThread isMainThread])
	{
		NSLog(@"Cannot be run on main thread.");
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
	NSLog(@"analytics upload finished");
	
	self.currentUpload = nil;
	
	[self _startNextUpload];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"didFailWithError: %@", error);
	
	[self _saveFailedUpload:self.currentUpload];

	self.currentUpload = nil;
	
	[self _startNextUpload];
}

@end
