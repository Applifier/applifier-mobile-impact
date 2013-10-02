//
//  ApplifierImpactCampaignManager.m
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactCampaignManager.h"
#import "ApplifierImpactCampaign.h"
#import "ApplifierImpactRewardItem.h"
#import "../ApplifierImpact.h"
#import "../ApplifierImpactSBJSON/ApplifierImpactSBJsonParser.h"
#import "../ApplifierImpactData/ApplifierImpactCache.h"
#import "../ApplifierImpactSBJSON/NSObject+ApplifierImpactSBJson.h"
#import "../ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"
#import "ApplifierImpactZoneParser.h"
#import "ApplifierImpactZoneManager.h"

@interface ApplifierImpactCampaignManager () <NSURLConnectionDelegate, ApplifierImpactCacheDelegate>
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *campaignDownloadData;
@property (nonatomic, strong) ApplifierImpactCache *cache;
@end

@implementation ApplifierImpactCampaignManager

@synthesize campaignDownloadData = _campaignDownloadData;

static ApplifierImpactCampaignManager *sharedImpactCampaignManager = nil;

+ (id)sharedInstance {
	@synchronized(self) {
		if (sharedImpactCampaignManager == nil)
      sharedImpactCampaignManager = [[ApplifierImpactCampaignManager alloc] init];
	}
	
	return sharedImpactCampaignManager;
}


#pragma mark - Private

- (void)_campaignDataReceived {
  [self _processCampaignDownloadData];
}

- (NSArray *)deserializeCampaigns:(NSArray *)campaignArray {
	if (campaignArray == nil || [campaignArray count] == 0) {
		AILOG_DEBUG(@"Input empty or nil.");
		return nil;
	}
	
	NSMutableArray *campaigns = [NSMutableArray array];
	
	for (id campaignDictionary in campaignArray) {
		if ([campaignDictionary isKindOfClass:[NSDictionary class]]) {
			ApplifierImpactCampaign *campaign = [[ApplifierImpactCampaign alloc] initWithData:campaignDictionary];
      
      if (campaign.isValidCampaign) {
        [campaigns addObject:campaign];
      }
		}
		else {
			AILOG_DEBUG(@"Unexpected value in campaign dictionary list. %@, %@", [campaignDictionary class], campaignDictionary);
			continue;
		}
	}
	
	return campaigns;
}

- (void)_processCampaignDownloadData {

  if (self.campaignDownloadData == nil) {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      [self.delegate campaignManagerCampaignDataFailed];
    });
    AILOG_DEBUG(@"Campaign download data is NULL!");
    return;
  }
  
  NSString *jsonString = [[NSString alloc] initWithData:self.campaignDownloadData encoding:NSUTF8StringEncoding];
  _campaignData = [jsonString JSONValue];
  
  if (_campaignData == nil) {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      [self.delegate campaignManagerCampaignDataFailed];
    });
    AILOG_DEBUG(@"Campaigndata is NULL!");
    return;
  }
  
  AILOG_DEBUG(@"%@", [_campaignData JSONRepresentation]);
	AIAssert([_campaignData isKindOfClass:[NSDictionary class]]);
	
  if (_campaignData != nil && [_campaignData isKindOfClass:[NSDictionary class]]) {
    NSDictionary *jsonDictionary = [(NSDictionary *)_campaignData objectForKey:kApplifierImpactJsonDataRootKey];
    BOOL validData = YES;
    
    if ([jsonDictionary objectForKey:kApplifierImpactWebViewUrlKey] == nil) validData = NO;
    if ([jsonDictionary objectForKey:kApplifierImpactAnalyticsUrlKey] == nil) validData = NO;
    if ([jsonDictionary objectForKey:kApplifierImpactUrlKey] == nil) validData = NO;
    if ([jsonDictionary objectForKey:kApplifierImpactGamerIDKey] == nil) validData = NO;
    if ([jsonDictionary objectForKey:kApplifierImpactCampaignsKey] == nil) validData = NO;
    if ([jsonDictionary objectForKey:kApplifierImpactZonesRootKey] == nil) validData = NO;
    
    id zoneManager = [ApplifierImpactZoneManager sharedInstance];
    [zoneManager clearZones];
    int addedZones = [zoneManager addZones:[ApplifierImpactZoneParser parseZones:[jsonDictionary objectForKey:kApplifierImpactZonesRootKey]]];
    if(addedZones == 0) validData = NO;
    
    self.campaigns = [self deserializeCampaigns:[jsonDictionary objectForKey:kApplifierImpactCampaignsKey]];
    if (self.campaigns == nil || [self.campaigns count] == 0) validData = NO;
    
    if (validData) {
      [[ApplifierImpactProperties sharedInstance] setWebViewBaseUrl:(NSString *)[jsonDictionary objectForKey:kApplifierImpactWebViewUrlKey]];
      [[ApplifierImpactProperties sharedInstance] setAnalyticsBaseUrl:(NSString *)[jsonDictionary objectForKey:kApplifierImpactAnalyticsUrlKey]];
      [[ApplifierImpactProperties sharedInstance] setImpactBaseUrl:(NSString *)[jsonDictionary objectForKey:kApplifierImpactUrlKey]];
      
      if ([jsonDictionary objectForKey:kApplifierImpactSdkVersionKey] != nil &&
          [[jsonDictionary objectForKey:kApplifierImpactSdkVersionKey] isKindOfClass:[NSString class]]) {
        [[ApplifierImpactProperties sharedInstance] setExpectedSdkVersion:[jsonDictionary objectForKey:kApplifierImpactSdkVersionKey]];
        AILOG_DEBUG(@"Got SDK Version: %@", [[ApplifierImpactProperties sharedInstance] expectedSdkVersion]);
      }
      
      if ([jsonDictionary objectForKey:kApplifierImpactWebViewDataParamSdkIsCurrentKey] != nil) {
        [[ApplifierImpactProperties sharedInstance] setSdkIsCurrent:[[jsonDictionary objectForKey:kApplifierImpactWebViewDataParamSdkIsCurrentKey] boolValue]];
      }

      NSString *gamerId = [jsonDictionary objectForKey:kApplifierImpactGamerIDKey];
      
      [[ApplifierImpactProperties sharedInstance] setGamerId:gamerId];
      [self.cache cacheCampaigns:self.campaigns];
      
      dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.delegate campaignManagerCampaignDataReceived];
      });
    }
    else {
      dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.delegate campaignManagerCampaignDataFailed];
      });
    }
  }
  
  self.campaignDownloadData = nil;
}


#pragma mark - Public

- (id)init {
	AIAssertV(![NSThread isMainThread], nil);
	
	if ((self = [super init])) {
		_cache = [[ApplifierImpactCache alloc] init];
		_cache.delegate = self;
	}
	
	return self;
}

- (void)updateCampaigns {
	AIAssert(![NSThread isMainThread]);
	
	NSString *urlString = [[ApplifierImpactProperties sharedInstance] campaignDataUrl];
	
  if ([[ApplifierImpactProperties sharedInstance] campaignQueryString] != nil)
		urlString = [urlString stringByAppendingString:[[ApplifierImpactProperties sharedInstance] campaignQueryString]];
  
  AILOG_DEBUG(@"UrlString %@", urlString);
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	[self.urlConnection start];
}

- (NSURL *)getVideoURLForCampaign:(ApplifierImpactCampaign *)campaign {
	@synchronized (self) {
		if (campaign == nil) {
			AILOG_DEBUG(@"Input is nil.");
			return nil;
		}
		
		NSURL *videoURL = [self.cache localVideoURLForCampaign:campaign];
		if (videoURL == nil || [self.cache campaignExistsInQueue:campaign] || ![campaign shouldCacheVideo] || ![self.cache isCampaignVideoCached:campaign]) {
      AILOG_DEBUG(@"Campaign is not cached!");
      videoURL = campaign.trailerStreamingURL;
    }
    
    AILOG_DEBUG(@"%@ and %i", videoURL.absoluteString, [self.cache campaignExistsInQueue:campaign]);
    
		return videoURL;
	}
}

- (ApplifierImpactCampaign *)getCampaignWithId:(NSString *)campaignId {
	AILOG_DEBUG(@"");
	AIAssertV([NSThread isMainThread], nil);
	ApplifierImpactCampaign *foundCampaign = nil;
	
	for (ApplifierImpactCampaign *campaign in self.campaigns) {
		if ([campaign.id isEqualToString:campaignId]) {
			foundCampaign = campaign;
			break;
		}
	}
	
	return foundCampaign;
}

- (ApplifierImpactCampaign *)getCampaignWithITunesId:(NSString *)iTunesId {
	AILOG_DEBUG(@"");
	AIAssertV([NSThread isMainThread], nil);
	ApplifierImpactCampaign *foundCampaign = nil;
	
	for (ApplifierImpactCampaign *campaign in self.campaigns) {
		if ([campaign.itunesID isEqualToString:iTunesId]) {
			foundCampaign = campaign;
			break;
		}
	}
	
	return foundCampaign;
}

- (ApplifierImpactCampaign *)getCampaignWithClickUrl:(NSString *)clickUrl {
	AILOG_DEBUG(@"");
	AIAssertV([NSThread isMainThread], nil);
	ApplifierImpactCampaign *foundCampaign = nil;
	
	for (ApplifierImpactCampaign *campaign in self.campaigns) {
		if ([[campaign.clickURL absoluteString] isEqualToString:clickUrl]) {
			foundCampaign = campaign;
			break;
		}
	}
	
	return foundCampaign;
}

- (NSArray *)getViewableCampaigns {
	AILOG_DEBUG(@"");
  NSMutableArray *retAr = [[NSMutableArray alloc] init];
  
  if (self.campaigns != nil) {
    for (ApplifierImpactCampaign* campaign in self.campaigns) {
      if (!campaign.viewed) {
        [retAr addObject:campaign];
      }
    }
  }
  
  return retAr;
}

- (void)cancelAllDownloads {
	AIAssert(![NSThread isMainThread]);
	
	[self.urlConnection cancel];
	self.urlConnection = nil;
	
	[self.cache cancelAllDownloads];
}

- (void)dealloc {
	self.cache.delegate = nil;
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  self.campaignDownloadData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.campaignDownloadData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  [self _campaignDataReceived];
  [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

static int retryCount = 0;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	self.campaignDownloadData = nil;
	self.urlConnection = nil;
	
	if(retryCount < kApplifierImpactWebDataMaxRetryCount) {
    ++retryCount;
    AILOG_DEBUG(@"Retrying campaign download in %d seconds.", kApplifierImpactWebDataRetryInterval);
    [NSTimer scheduledTimerWithTimeInterval:kApplifierImpactWebDataRetryInterval target:self selector:@selector(updateCampaigns) userInfo:nil repeats:NO];
  } else {
    AILOG_DEBUG(@"Not retrying campaign download.");
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.delegate campaignManagerCampaignDataFailed];
    });
  }
  
  [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


#pragma mark - ApplifierImpactCacheDelegate

- (void)cache:(ApplifierImpactCache *)cache finishedCachingCampaign:(ApplifierImpactCampaign *)campaign {
}

- (void)cacheFinishedCachingCampaigns:(ApplifierImpactCache *)cache {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.delegate campaignManager:self updatedWithCampaigns:self.campaigns gamerID:[[ApplifierImpactProperties sharedInstance] gamerId]];
	});
  
  [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
