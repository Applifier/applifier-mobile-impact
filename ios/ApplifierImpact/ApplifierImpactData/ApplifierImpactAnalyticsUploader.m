//
//  ApplifierImpactAnalyticsUploader.m
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactAnalyticsUploader.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "../ApplifierImpact.h"
#import "../ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "../ApplifierImpactDevice/ApplifierImpactDevice.h"

NSString * const kApplifierImpactTrackingPath = @"gamers/";
NSString * const kApplifierImpactInstallTrackingPath = @"games/";
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
@property (nonatomic, assign) dispatch_queue_t analyticsQueue;
@property (nonatomic, strong) NSThread *backgroundThread;
@end

@implementation ApplifierImpactAnalyticsUploader


#pragma mark - Private

- (void)_backgroundRunLoop:(id)dummy {
	@autoreleasepool
	{
		NSPort *port = [[NSPort alloc] init];
		[port scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		while([[NSThread currentThread] isCancelled] == NO)
		{
			@autoreleasepool
			{
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
			}
		}
	}
}


#pragma mark - Upload queing

- (BOOL)_startNextUpload {
	if (self.currentUpload != nil || [self.uploadQueue count] == 0)
		return NO;
	
	self.currentUpload = [self.uploadQueue objectAtIndex:0];
	
	NSURLConnection *connection = [self.currentUpload objectForKey:kApplifierImpactAnalyticsUploaderConnectionKey];
	[connection start];
	
	[self.uploadQueue removeObjectAtIndex:0];
	
	return YES;
}

- (void)_queueURL:(NSURL *)url body:(NSData *)body httpMethod:(NSString *)httpMethod {
	if (url == nil) {
		AILOG_DEBUG(@"Invalid input.");
		return;
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

	if (request == nil) {
		AILOG_ERROR(@"Could not create request with url '%@'.", url);
		return;
	}
	
	[request setHTTPMethod:httpMethod];
	if (body != nil)
		[request setHTTPBody:body];
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	NSDictionary *uploadDictionary = @{ kApplifierImpactAnalyticsUploaderRequestKey : request, kApplifierImpactAnalyticsUploaderConnectionKey : connection };
	[self.uploadQueue addObject:uploadDictionary];
	  
	if ([self.uploadQueue count] == 1)
		[self _startNextUpload];
}

- (void)_queueWithURLString:(NSString *)urlString queryString:(NSString *)queryString httpMethod:(NSString *)httpMethod {
	NSURL *url = [NSURL URLWithString:urlString];
	NSData *body = nil;
	if (queryString != nil)
		body = [queryString dataUsingEncoding:NSUTF8StringEncoding];
  
	[self _queueURL:url body:body httpMethod:httpMethod];
}


#pragma mark - Public

static ApplifierImpactAnalyticsUploader *sharedImpactAnalyticsUploader = nil;

+ (id)sharedInstance {
	@synchronized(self) {
		if (sharedImpactAnalyticsUploader == nil)
      sharedImpactAnalyticsUploader = [[ApplifierImpactAnalyticsUploader alloc] init];
	}
	
	return sharedImpactAnalyticsUploader;
}

- (id)init {
	if ((self = [super init])) {
		_uploadQueue = [NSMutableArray array];
    self.analyticsQueue = dispatch_queue_create("com.applifier.impact.analytics", NULL);
    self.backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(_backgroundRunLoop:) object:nil];
		[self.backgroundThread start];
	}
	
	return self;
}

- (void)dealloc {
  dispatch_release(self.analyticsQueue);
}


#pragma mark - Click track

- (void)sendOpenAppStoreRequest:(ApplifierImpactCampaign *)campaign {
  if (campaign != nil) {
    NSString *query = [NSString stringWithFormat:@"gameId=%@&type=%@&trackingId=%@&providerId=%@", [[ApplifierImpactProperties sharedInstance] impactGameId], @"openAppStore", [[ApplifierImpactProperties sharedInstance] gamerId], campaign.id];
    
    [self performSelector:@selector(sendAnalyticsRequestWithQueryString:) onThread:self.backgroundThread withObject:query waitUntilDone:NO];
  }
}


#pragma mark - Video analytics

- (void)logVideoAnalyticsWithPosition:(VideoAnalyticsPosition)videoPosition campaign:(ApplifierImpactCampaign *)campaign {
	if (campaign == nil) {
		AILOG_DEBUG(@"Campaign is nil.");
		return;
	}
	
	dispatch_async(self.analyticsQueue, ^{
		NSString *positionString = nil;
		NSString *trackingString = nil;
    
		if (videoPosition == kVideoAnalyticsPositionStart) {
			positionString = @"video_start";
			trackingString = @"start";
		}
		else if (videoPosition == kVideoAnalyticsPositionFirstQuartile)
			positionString = @"first_quartile";
		else if (videoPosition == kVideoAnalyticsPositionMidPoint)
			positionString = @"mid_point";
		else if (videoPosition == kVideoAnalyticsPositionThirdQuartile)
			positionString = @"third_quartile";
		else if (videoPosition == kVideoAnalyticsPositionEnd) {
			positionString = @"video_end";
			trackingString = @"view";
		}
		
    NSString *query = [NSString stringWithFormat:@"gameId=%@&type=%@&trackingId=%@&providerId=%@", [[ApplifierImpactProperties sharedInstance] impactGameId], positionString, [[ApplifierImpactProperties sharedInstance] gamerId], campaign.id];
    
    [self performSelector:@selector(sendAnalyticsRequestWithQueryString:) onThread:self.backgroundThread withObject:query waitUntilDone:NO];
     
     if (trackingString != nil) {
       NSString *trackingQuery = [NSString stringWithFormat:@"%@/%@/%@?gameId=%@", [[ApplifierImpactProperties sharedInstance] gamerId], trackingString, campaign.id, [[ApplifierImpactProperties sharedInstance] impactGameId]];
       [self performSelector:@selector(sendTrackingCallWithQueryString:) onThread:self.backgroundThread withObject:trackingQuery waitUntilDone:NO];
     }
	});
}

- (void)sendAnalyticsRequestWithQueryString:(NSString *)queryString {
	AIAssert(![NSThread isMainThread]);
	
	if (queryString == nil || [queryString length] == 0) {
		AILOG_DEBUG(@"Invalid input.");
		return;
	}

  AILOG_DEBUG(@"View report: %@?%@", [[ApplifierImpactProperties sharedInstance] analyticsBaseUrl], queryString);
	[self _queueWithURLString:[[ApplifierImpactProperties sharedInstance] analyticsBaseUrl] queryString:queryString httpMethod:@"POST"];
}

- (void)sendTrackingCallWithQueryString:(NSString *)queryString {
	AIAssert(![NSThread isMainThread]);
	
	if (queryString == nil || [queryString length] == 0) {
		AILOG_DEBUG(@"Invalid input.");
		return;
	}
  
  AILOG_DEBUG(@"Tracking report: %@%@", [[ApplifierImpactProperties sharedInstance] impactBaseUrl], queryString);
  
	[self _queueWithURLString:[NSString stringWithFormat:@"%@%@", [[ApplifierImpactProperties sharedInstance] impactBaseUrl], kApplifierImpactTrackingPath] queryString:queryString httpMethod:@"GET"];
}


#pragma mark - Install tracking

- (void)sendInstallTrackingCallWithQueryDictionary:(NSDictionary *)queryDictionary {
	AIAssert( ! [NSThread isMainThread]);
	
	if (queryDictionary == nil) {
		AILOG_DEBUG(@"Invalid input.");
		return;
	}
	
	NSString *query = [queryDictionary objectForKey:kApplifierImpactQueryDictionaryQueryKey];
	NSString *body = [queryDictionary objectForKey:kApplifierImpactQueryDictionaryBodyKey];
	
	if (query == nil || [query length] == 0 || body == nil || [body length] == 0) {
		AILOG_DEBUG(@"Invalid parameters in query dictionary.");
		return;
	}
	
  [self _queueWithURLString:[NSString stringWithFormat:@"%@%@", [[ApplifierImpactProperties sharedInstance] impactBaseUrl], kApplifierImpactInstallTrackingPath] queryString:nil httpMethod:@"GET"];
}

- (void)sendManualInstallTrackingCall {
	if ([[ApplifierImpactProperties sharedInstance] impactGameId] == nil) {
		return;
	}
	
  dispatch_async(self.analyticsQueue, ^{
    NSString *queryString = [NSString stringWithFormat:@"%@/install", [[ApplifierImpactProperties sharedInstance] impactGameId]];
    NSString *bodyString = [NSString stringWithFormat:@"deviceId=%@", [ApplifierImpactDevice md5DeviceId]];
		NSDictionary *queryDictionary = @{ kApplifierImpactQueryDictionaryQueryKey : queryString, kApplifierImpactQueryDictionaryBodyKey : bodyString };
    [self performSelector:@selector(sendInstallTrackingCallWithQueryDictionary:) onThread:self.backgroundThread withObject:queryDictionary waitUntilDone:NO];
	});
}


#pragma mark - Error handling

- (void)retryFailedUploads {
	AIAssert( ! [NSThread isMainThread]);
	
	NSArray *uploads = [[NSUserDefaults standardUserDefaults] arrayForKey:kApplifierImpactAnalyticsSavedUploadsKey];
	if (uploads != nil) {
		for (NSDictionary *upload in uploads) {
			NSString *url = [upload objectForKey:kApplifierImpactAnalyticsSavedUploadURLKey];
			NSString *body = [upload objectForKey:kApplifierImpactAnalyticsSavedUploadBodyKey];
			NSString *httpMethod = [upload objectForKey:kApplifierImpactAnalyticsSavedUploadHTTPMethodKey];
			[self _queueURL:[NSURL URLWithString:url] body:[body dataUsingEncoding:NSUTF8StringEncoding] httpMethod:httpMethod];
		}
		
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kApplifierImpactAnalyticsSavedUploadsKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)_saveFailedUpload:(NSDictionary *)upload {
	if (upload == nil) {
		AILOG_DEBUG(@"Input is nil.");
		return;
	}
	
	NSMutableArray *existingFailedUploads = [[[NSUserDefaults standardUserDefaults] arrayForKey:kApplifierImpactAnalyticsSavedUploadsKey] mutableCopy];
	
	if (existingFailedUploads == nil) {
    existingFailedUploads = [NSMutableArray array];
  }
  
	NSURLRequest *request = [upload objectForKey:kApplifierImpactAnalyticsUploaderRequestKey];
	NSMutableDictionary *failedUpload = [NSMutableDictionary dictionary];
	
  if ([request URL] != nil) {
		[failedUpload setObject:[[request URL] absoluteString] forKey:kApplifierImpactAnalyticsSavedUploadURLKey];
		
		if ([request HTTPBody] != nil) {
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


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	AILOG_DEBUG(@"analytics upload finished");
	
	self.currentUpload = nil;	
	[self _startNextUpload];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	AILOG_DEBUG(@"%@", error);
	
	[self _saveFailedUpload:self.currentUpload];
	self.currentUpload = nil;
	[self _startNextUpload];
}

@end