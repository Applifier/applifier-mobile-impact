//
//  ApplifierImpactCampaignManager.m
//  ImpactProto
//
//  Created by Johan Halin on 5.9.2012.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactCampaignManager.h"
#import "ApplifierImpactSBJSONParser.h"
#import "ApplifierImpactCampaign.h"
#import "ApplifierImpactRewardItem.h"
#import "ApplifierImpactCache.h"
#import "ApplifierImpact.h"

NSString * const kApplifierImpactBackendURL = @"https://impact.applifier.com/mobile/campaigns";

NSString * const kCampaignEndScreenKey = @"endScreen";
NSString * const kCampaignClickURLKey = @"clickUrl";
NSString * const kCampaignPictureKey = @"picture";
NSString * const kCampaignTrailerDownloadableKey = @"trailerDownloadable";
NSString * const kCampaignTrailerStreamingKey = @"trailerStreaming";
NSString * const kCampaignGameIDKey = @"gameId";
NSString * const kCampaignGameNameKey = @"gameName";
NSString * const kCampaignIDKey = @"id";
NSString * const kCampaignTaglineKey = @"tagline";
NSString * const kCampaignStoreIDKey = @"itunesID";

NSString * const kRewardItemKey = @"itemKey";
NSString * const kRewardNameKey = @"name";
NSString * const kRewardPictureKey = @"picture";

NSString * const kGamerIDKey = @"gamerId";

@interface ApplifierImpactCampaignManager () <NSURLConnectionDelegate, ApplifierImpactCacheDelegate>
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *campaignDownloadData;
@property (nonatomic, strong) ApplifierImpactCache *cache;
@property (nonatomic, strong) NSArray *campaigns;
@property (nonatomic, strong) ApplifierImpactRewardItem *rewardItem;
@property (nonatomic, strong) NSString *gamerID;
@property (nonatomic, strong) NSString *campaignJSON;
@end

@implementation ApplifierImpactCampaignManager

#pragma mark - Private

- (id)_JSONValueFromData:(NSData *)data
{
	if (data == nil)
	{
		AILOG_DEBUG(@"Input is nil.");
		return nil;
	}
	
	ApplifierImpactSBJsonParser *parser = [[ApplifierImpactSBJsonParser alloc] init];
	NSError *error = nil;
	NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if ([jsonString isEqualToString:self.campaignJSON])
		return nil;
	
	id repr = [parser objectWithString:jsonString error:&error];
	if (repr == nil)
	{
		AILOG_DEBUG(@"-JSONValue failed. Error is: %@", error);
		AILOG_DEBUG(@"String value: %@", jsonString);

		return nil;
	}
	
	self.campaignJSON = jsonString;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.delegate campaignManager:self updatedJSON:jsonString];
	});
	
	return repr;
}

- (NSArray *)_deserializeCampaigns:(NSArray *)campaignArray
{
	if (campaignArray == nil || [campaignArray count] == 0)
	{
		AILOG_DEBUG(@"Input empty or nil.");
		return nil;
	}
	
	NSMutableArray *campaigns = [NSMutableArray array];
	
	for (id campaignDictionary in campaignArray)
	{
		if ([campaignDictionary isKindOfClass:[NSDictionary class]])
		{
			ApplifierImpactCampaign *campaign = [[ApplifierImpactCampaign alloc] init];
			NSURL *endScreenURL = [NSURL URLWithString:[campaignDictionary objectForKey:kCampaignEndScreenKey]];
			if (endScreenURL == nil)
			{
				AILOG_DEBUG(@"Campaign end screen URL is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.endScreenURL = endScreenURL;
			
			NSURL *clickURL = [NSURL URLWithString:[campaignDictionary objectForKey:kCampaignClickURLKey]];
			if (clickURL == nil)
			{
				AILOG_DEBUG(@"Campaign click URL is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.clickURL = clickURL;
			
			NSURL *pictureURL = [NSURL URLWithString:[campaignDictionary objectForKey:kCampaignPictureKey]];
			if (pictureURL == nil)
			{
				AILOG_DEBUG(@"Campaign picture URL is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.pictureURL = pictureURL;
			
			NSURL *trailerDownloadableURL = [NSURL URLWithString:[campaignDictionary objectForKey:kCampaignTrailerDownloadableKey]];
			if (trailerDownloadableURL == nil)
			{
				AILOG_DEBUG(@"Campaign downloadable trailer URL is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.trailerDownloadableURL = trailerDownloadableURL;
			
			NSURL *trailerStreamingURL = [NSURL URLWithString:[campaignDictionary objectForKey:kCampaignTrailerStreamingKey]];
			if (trailerStreamingURL == nil)
			{
				AILOG_DEBUG(@"Campaign streaming trailer URL is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.trailerStreamingURL = trailerStreamingURL;
			
			NSString *gameID = [NSString stringWithFormat:@"%@", [campaignDictionary objectForKey:kCampaignGameIDKey]];
			if (gameID == nil || [gameID length] == 0)
			{
				AILOG_DEBUG(@"Campaign game ID  is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.gameID = gameID;
			
			NSString *gameName = [NSString stringWithFormat:@"%@", [campaignDictionary objectForKey:kCampaignGameNameKey]];
			if (gameName == nil || [gameName length] == 0)
			{
				AILOG_DEBUG(@"Campaign game name is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.gameName = gameName;
			
			NSString *id = [NSString stringWithFormat:@"%@", [campaignDictionary objectForKey:kCampaignIDKey]];
			if (id == nil || [id length] == 0)
			{
				AILOG_DEBUG(@"Campaign ID is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.id = id;
			
			NSString *tagline = [NSString stringWithFormat:@"%@", [campaignDictionary objectForKey:kCampaignTaglineKey]];
			if (tagline == nil || [tagline length] == 0)
			{
				AILOG_DEBUG(@"Campaign tagline is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.tagline = tagline;
			
			NSString *itunesID = [NSString stringWithFormat:@"%@", [campaignDictionary objectForKey:kCampaignStoreIDKey]];
			if (itunesID == nil || [itunesID length] == 0)
			{
				AILOG_DEBUG(@"iTunes ID is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.itunesID = itunesID;
			
			[campaigns addObject:campaign];
		}
		else
		{
			AILOG_DEBUG(@"Unexpected value in campaign dictionary list. %@, %@", [campaignDictionary class], campaignDictionary);
			
			continue;
		}
	}
	
	return campaigns;
}

- (id)_deserializeRewardItem:(NSDictionary *)itemDictionary
{
	if ([itemDictionary isKindOfClass:[NSDictionary class]])
	{
		ApplifierImpactRewardItem *item = [[ApplifierImpactRewardItem alloc] init];
		NSString *key = [NSString stringWithFormat:@"%@", [itemDictionary objectForKey:kRewardItemKey]];
		if (key == nil || [key length] == 0)
		{
			AILOG_DEBUG(@"Item key is empty. %@", itemDictionary);
			return nil;
		}
		item.key = key;
		
		NSString *name = [NSString stringWithFormat:@"%@", [itemDictionary objectForKey:kRewardNameKey]];
		if (name == nil || [name length] == 0)
		{
			AILOG_DEBUG(@"Item name is empty. %@", itemDictionary);
			return nil;
		}
		item.name = name;

		NSURL *pictureURL = [NSURL URLWithString:[itemDictionary objectForKey:kRewardPictureKey]];
		if (pictureURL == nil)
		{
			AILOG_DEBUG(@"Item picture URL is empty or invalid. %@", itemDictionary);
			return nil;
		}
		item.pictureURL = pictureURL;
		
		return item;
	}
	else
	{
		AILOG_DEBUG(@"Unknown data type for reward item dictionary: %@", [itemDictionary class]);
		
		return nil;
	}
}

- (void)_processCampaignDownloadData
{
	id json = [self _JSONValueFromData:self.campaignDownloadData];
	if ([json isKindOfClass:[NSDictionary class]])
	{
		NSDictionary *jsonDictionary = [(NSDictionary *)json objectForKey:@"data"];
		self.campaigns = [self _deserializeCampaigns:[jsonDictionary objectForKey:@"campaigns"]];
		self.rewardItem = [self _deserializeRewardItem:[jsonDictionary objectForKey:@"item"]];
		
		NSString *gamerID = [jsonDictionary objectForKey:kGamerIDKey];
		if (gamerID == nil)
		{
			AILOG_DEBUG(@"Gamer ID is nil.");
			return;
		}
		self.gamerID = gamerID;
				
		[self.cache cacheCampaigns:self.campaigns];
	}
	else
		AILOG_DEBUG(@"JSON not changed or unknown data type for JSON: %@", [json class]);
}

#pragma mark - Public

- (id)init
{
	AIAssertV( ! [NSThread isMainThread], nil);
	
	if ((self = [super init]))
	{
		_cache = [[ApplifierImpactCache alloc] init];
		_cache.delegate = self;
	}
	
	return self;
}

- (void)updateCampaigns
{
	AIAssert( ! [NSThread isMainThread]);
	
	NSString *urlString = kApplifierImpactBackendURL;
	if (self.queryString != nil)
		urlString = [urlString stringByAppendingString:self.queryString];
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	[self.urlConnection start];
}

- (NSURL *)videoURLForCampaign:(ApplifierImpactCampaign *)campaign
{
	@synchronized (self)
	{
		if (campaign == nil)
		{
			AILOG_DEBUG(@"Input is nil.");
			return nil;
		}
		
		NSURL *videoURL = [self.cache localVideoURLForCampaign:campaign];
		if (videoURL == nil)
			videoURL = campaign.trailerStreamingURL;

		return videoURL;
	}
}

- (void)cancelAllDownloads
{
	AIAssert( ! [NSThread isMainThread]);
	
	[self.urlConnection cancel];
	self.urlConnection = nil;
	
	[self.cache cancelAllDownloads];
}

- (void)dealloc
{
	self.cache.delegate = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self.campaignDownloadData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.campaignDownloadData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self _processCampaignDownloadData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	AILOG_DEBUG(@"didFailWithError: %@", error);
}

#pragma mark - ApplifierImpactCacheDelegate

- (void)cache:(ApplifierImpactCache *)cache finishedCachingCampaign:(ApplifierImpactCampaign *)campaign
{
}

- (void)cacheFinishedCachingCampaigns:(ApplifierImpactCache *)cache
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.delegate campaignManager:self updatedWithCampaigns:self.campaigns rewardItem:self.rewardItem gamerID:self.gamerID];
	});
}

@end
