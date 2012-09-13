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
	NSLog(@"TODO");
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
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	NSDictionary *uploadDictionary = @{ kApplifierImpactAnalyticsUploaderRequestKey : request, kApplifierImpactAnalyticsUploaderConnectionKey : connection };
	[self.uploadQueue addObject:uploadDictionary];
	
	if ([self.uploadQueue count] == 1)
		[self _startNextUpload];
}

- (void)retryFailedUploads
{
	if ([NSThread isMainThread])
	{
		NSLog(@"Cannot be run on main thread.");
		return;
	}

	NSLog(@"TODO");
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
