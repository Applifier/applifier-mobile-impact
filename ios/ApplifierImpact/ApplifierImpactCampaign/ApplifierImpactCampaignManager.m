//
//  ApplifierImpactCampaignManager.m
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactCampaignManager.h"
#import "ApplifierImpactCampaign.h"
#import "ApplifierImpactRewardItem.h"
#import "ApplifierImpact.h"
#import "ApplifierImpactSBJsonParser.h"
#import "ApplifierImpactCacheManager.h"
#import "NSObject+ApplifierImpactSBJson.h"
#import "ApplifierImpactProperties.h"
#import "ApplifierImpactConstants.h"
#import "ApplifierImpactZoneParser.h"
#import "ApplifierImpactZoneManager.h"

@interface ApplifierImpactCampaignManager () <NSURLConnectionDelegate, ApplifierImpactCacheManagerDelegate>
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *campaignDownloadData;
@property (nonatomic, strong) ApplifierImpactCacheManager *cacheManager;
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
      [self.cacheManager cache:ResourceTypeTrailerVideo forCampaign:self.campaigns[0]];
      
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
		_cacheManager = [[ApplifierImpactCacheManager alloc] init];
		_cacheManager.delegate = self;
	}
	
	return self;
}

- (void)updateCampaigns {
	AIAssert(![NSThread isMainThread]);
	
	NSString *urlString = [[ApplifierImpactProperties sharedInstance] campaignDataUrl];
	
  if ([[ApplifierImpactProperties sharedInstance] campaignQueryString] != nil)
		urlString = [urlString stringByAppendingString:[[ApplifierImpactProperties sharedInstance] campaignQueryString]];
  
  AILOG_DEBUG(@"UrlString %@", urlString);
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
	self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	[self.urlConnection start];
}

- (NSURL *)getVideoURLForCampaign:(ApplifierImpactCampaign *)campaign {
	@synchronized (self) {
		if (campaign == nil) {
			AILOG_DEBUG(@"Input is nil.");
			return nil;
		}
		
		NSURL *videoURL = [self.cacheManager localURLFor:ResourceTypeTrailerVideo ofCampaign:campaign];
    if ([self.cacheManager campaignExistsInQueue:campaign withResourceType:ResourceTypeTrailerVideo]) {
      AILOG_DEBUG(@"Cancel caching video for campaign %@", campaign.id);
      [self.cacheManager cancelCacheForCampaign:campaign withResourceType:ResourceTypeTrailerVideo];
    }
		if (![self.cacheManager is:ResourceTypeTrailerVideo cachedForCampaign:campaign])
    {
      AILOG_DEBUG(@"Choosing streaming URL for campaign %@", campaign.id);
      videoURL = campaign.trailerStreamingURL;
    }
    AILOG_DEBUG(@"Choosing trailer URL for campaign %@", campaign.id);
		return videoURL;
	}
}

- (void)cacheNextCampaignAfter:(ApplifierImpactCampaign *)currentCampaign {
  __block NSUInteger currentIndex = 0;
  [self.campaigns enumerateObjectsUsingBlock:^(ApplifierImpactCampaign *campaign, NSUInteger idx, BOOL *stop) {
    if ([campaign.id isEqualToString:currentCampaign.id]) {
      currentIndex = idx + 1;
      *stop = YES;
    }
  }];
  
  if (currentIndex <= self.campaigns.count - 1) {
    [self.cacheManager cache:ResourceTypeTrailerVideo forCampaign:self.campaigns[currentIndex]];
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
	
	[self.cacheManager cancelAllDownloads];
}

- (void)dealloc {
	self.cacheManager.delegate = nil;
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
}


#pragma mark - ApplifierImpactCacheDelegate

- (void)cache:(ApplifierImpactCacheManager *)cacheManager finishedCachingCampaign:(ApplifierImpactCampaign *)campaign {
  dispatch_async(dispatch_get_main_queue(), ^{
		[self.delegate campaignManager:self updatedWithCampaigns:self.campaigns gamerID:[[ApplifierImpactProperties sharedInstance] gamerId]];
	});
}

@end
