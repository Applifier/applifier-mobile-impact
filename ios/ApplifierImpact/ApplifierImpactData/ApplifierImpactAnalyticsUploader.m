//
//  ApplifierImpactAnalyticsUploader.m
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactAnalyticsUploader.h"
#import "../ApplifierImpact.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "../ApplifierImpactDevice/ApplifierImpactDevice.h"
#import "../ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"

@interface ApplifierImpactAnalyticsUploader () <NSURLConnectionDelegate>
@property (nonatomic, strong) NSMutableArray *uploadQueue;
@property (nonatomic, strong) NSDictionary *currentUpload;
@property (nonatomic, assign) dispatch_queue_t analyticsQueue;
@property (nonatomic, strong) NSThread *backgroundThread;
@end

@implementation ApplifierImpactAnalyticsUploader


#pragma mark - Private

- (void)_backgroundRunLoop:(id)dummy {
	@autoreleasepool {
		NSPort *port = [[NSPort alloc] init];
		[port scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		while([[NSThread currentThread] isCancelled] == NO) {
			@autoreleasepool {
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

- (void)_queueURL:(NSURL *)url body:(NSData *)body httpMethod:(NSString *)httpMethod retries:(NSNumber *)retryCount {
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
	NSDictionary *uploadDictionary = @{kApplifierImpactAnalyticsUploaderRequestKey:request, kApplifierImpactAnalyticsUploaderConnectionKey:connection, kApplifierImpactAnalyticsUploaderRetriesKey:retryCount};
	[self.uploadQueue addObject:uploadDictionary];
	  
	if ([self.uploadQueue count] == 1)
		[self _startNextUpload];
}

- (void)_queueWithURLString:(NSString *)urlString queryString:(NSString *)queryString httpMethod:(NSString *)httpMethod retries:(NSNumber *)retryCount {
	NSURL *url = [NSURL URLWithString:urlString];
	NSData *body = nil;
	if (queryString != nil)
		body = [queryString dataUsingEncoding:NSUTF8StringEncoding];
  
	[self _queueURL:url body:body httpMethod:httpMethod retries:retryCount];
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
    NSString *query = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@", kApplifierImpactAnalyticsQueryParamGameIdKey, [[ApplifierImpactProperties sharedInstance] impactGameId], kApplifierImpactAnalyticsQueryParamEventTypeKey, kApplifierImpactAnalyticsEventTypeOpenAppStore, kApplifierImpactAnalyticsQueryParamTrackingIdKey, [[ApplifierImpactProperties sharedInstance] gamerId], kApplifierImpactAnalyticsQueryParamProviderIdKey, campaign.id, kApplifierImpactAnalyticsQueryParamRewardItemKey, [[ApplifierImpactCampaignManager sharedInstance] currentRewardItemKey]];
    
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
			positionString = kApplifierImpactAnalyticsEventTypeVideoStart;
			trackingString = kApplifierImpactTrackingEventTypeVideoStart;
		}
		else if (videoPosition == kVideoAnalyticsPositionFirstQuartile)
			positionString = kApplifierImpactAnalyticsEventTypeVideoFirstQuartile;
		else if (videoPosition == kVideoAnalyticsPositionMidPoint)
			positionString = kApplifierImpactAnalyticsEventTypeVideoMidPoint;
		else if (videoPosition == kVideoAnalyticsPositionThirdQuartile)
			positionString = kApplifierImpactAnalyticsEventTypeVideoThirdQuartile;
		else if (videoPosition == kVideoAnalyticsPositionEnd) {
			positionString = kApplifierImpactAnalyticsEventTypeVideoEnd;
			trackingString = kApplifierImpactTrackingEventTypeVideoEnd;
		}
		
    NSString *query = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@", kApplifierImpactAnalyticsQueryParamGameIdKey, [[ApplifierImpactProperties sharedInstance] impactGameId], kApplifierImpactAnalyticsQueryParamEventTypeKey, positionString, kApplifierImpactAnalyticsQueryParamTrackingIdKey, [[ApplifierImpactProperties sharedInstance] gamerId], kApplifierImpactAnalyticsQueryParamProviderIdKey, campaign.id, kApplifierImpactAnalyticsQueryParamRewardItemKey, [[ApplifierImpactCampaignManager sharedInstance] currentRewardItemKey]];
    
    [self performSelector:@selector(sendAnalyticsRequestWithQueryString:) onThread:self.backgroundThread withObject:query waitUntilDone:NO];
     
     if (trackingString != nil) {
       NSString *trackingQuery = [NSString stringWithFormat:@"%@/%@/%@?%@=%@&%@=%@", [[ApplifierImpactProperties sharedInstance] gamerId], trackingString, campaign.id, kApplifierImpactAnalyticsQueryParamGameIdKey, [[ApplifierImpactProperties sharedInstance] impactGameId],kApplifierImpactAnalyticsQueryParamRewardItemKey, [[ApplifierImpactCampaignManager sharedInstance] currentRewardItemKey]];
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
	[self _queueWithURLString:[[ApplifierImpactProperties sharedInstance] analyticsBaseUrl] queryString:queryString httpMethod:@"POST" retries:[NSNumber numberWithInt:0]];
}

- (void)sendTrackingCallWithQueryString:(NSString *)queryString {
	AIAssert(![NSThread isMainThread]);
	
	if (queryString == nil || [queryString length] == 0) {
		AILOG_DEBUG(@"Invalid input.");
		return;
	}
  
  AILOG_DEBUG(@"Tracking report: %@%@%@", [[ApplifierImpactProperties sharedInstance] impactBaseUrl], kApplifierImpactAnalyticsTrackingPath, queryString);
  
  [self _queueWithURLString:[NSString stringWithFormat:@"%@%@%@", [[ApplifierImpactProperties sharedInstance] impactBaseUrl], kApplifierImpactAnalyticsTrackingPath,queryString] queryString:nil httpMethod:@"GET" retries:[NSNumber numberWithInt:0]];
}


#pragma mark - Install tracking

- (void)sendInstallTrackingCallWithQueryDictionary:(NSDictionary *)queryDictionary {
	AIAssert( ! [NSThread isMainThread]);
	
	if (queryDictionary == nil) {
		AILOG_DEBUG(@"Invalid input.");
		return;
	}
	
	NSString *query = [queryDictionary objectForKey:kApplifierImpactAnalyticsQueryDictionaryQueryKey];
	NSString *body = [queryDictionary objectForKey:kApplifierImpactAnalyticsQueryDictionaryBodyKey];
	
	if (query == nil || [query length] == 0 || body == nil || [body length] == 0) {
		AILOG_DEBUG(@"Invalid parameters in query dictionary.");
		return;
	}
	
  [self _queueWithURLString:[NSString stringWithFormat:@"%@%@", [[ApplifierImpactProperties sharedInstance] impactBaseUrl], kApplifierImpactAnalyticsInstallTrackingPath] queryString:nil httpMethod:@"GET" retries:[NSNumber numberWithInt:0]];
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
      NSNumber *retries = 0;
      
      if ([upload objectForKey:kApplifierImpactAnalyticsUploaderRetriesKey] != nil) {
        retries = [upload objectForKey:kApplifierImpactAnalyticsUploaderRetriesKey];
        retries = [NSNumber numberWithInt:[retries intValue] + 1];
      }
      
      // Check if too many retries
      if ([retries intValue] > [[ApplifierImpactProperties sharedInstance] maxNumberOfAnalyticsRetries]) {
        continue;
      }
      
      [self _queueURL:[NSURL URLWithString:url] body:[body dataUsingEncoding:NSUTF8StringEncoding] httpMethod:httpMethod retries:retries];
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
    
    NSNumber *retries = 0;
    if ([upload objectForKey:kApplifierImpactAnalyticsUploaderRetriesKey] != nil)
      retries = [upload objectForKey:kApplifierImpactAnalyticsUploaderRetriesKey];
      
		[failedUpload setObject:retries forKey:kApplifierImpactAnalyticsUploaderRetriesKey];
    
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
	AILOG_DEBUG(@"");
  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
  
  if ([httpResponse statusCode] >= 400) {
    AILOG_DEBUG(@"ERROR FECTHING URL: %i", [httpResponse statusCode]);
    [self _saveFailedUpload:self.currentUpload];
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	AILOG_DEBUG(@"");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	AILOG_DEBUG(@"");
	self.currentUpload = nil;	
	[self _startNextUpload];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	AILOG_DEBUG(@"Analytics upload connection error: %@", error);
	
	[self _saveFailedUpload:self.currentUpload];
	self.currentUpload = nil;
	[self _startNextUpload];
}

@end