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

NSString * const kApplifierImpactTestBackendURL = @"https://impact.applifier.com/campaigns/mobile";

NSString * const kCampaignEndScreenKey = @"endScreen";
NSString * const kCampaignClickURLKey = @"clickUrl";
NSString * const kCampaignPictureKey = @"picture";
NSString * const kCampaignTrailerDownloadableKey = @"trailerDownloadable";
NSString * const kCampaignTrailerStreamingKey = @"trailerStreaming";
NSString * const kCampaignGameIDKey = @"gameId";
NSString * const kCampaignGameNameKey = @"gameName";
NSString * const kCampaignIDKey = @"id";
NSString * const kCampaignTaglineKey = @"tagline";

NSString * const kRewardItemKey = @"itemKey";
NSString * const kRewardNameKey = @"name";
NSString * const kRewardPictureKey = @"picture";

/*
 VideoPlan (for dev / testing purposes)
 The data requested from backend that contains the campaigns that should be used at this time http://quake.everyplay.fi/~bluesun/impact/manifest.json? d={"did":"DEVICE_ID","c":["ARRAY", “OF”, “CACHED”, “CAMPAIGN”, “ID S”]}
 
 ViewReport (for dev / testing purposes)
 Reporting the current position (view) of video, watch to the Backend
 http://quake.everyplay.fi/~bluesun/impact/manifest.json?
 v={"did":"DEVICE_ID","c":”VIEWED_CAMPAIGN_ID”, “pos”:”POSITION_ OPTION”}
 Position options are: start, first_quartile, mid_point, third_quartile,
 end
 */

@interface ApplifierImpactCampaignManager () <NSURLConnectionDelegate, ApplifierImpactCacheDelegate>
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *campaignDownloadData;
@property (nonatomic, strong) ApplifierImpactCache *cache;
@property (nonatomic, strong) NSArray *campaigns;
@property (nonatomic, strong) ApplifierImpactRewardItem *rewardItem;
@end

@implementation ApplifierImpactCampaignManager

@synthesize delegate = _delegate;
@synthesize urlConnection = _urlConnection;
@synthesize campaignDownloadData = _campaignDownloadData;
@synthesize cache = _cache;
@synthesize campaigns = _campaigns;
@synthesize rewardItem = _rewardItem;

#pragma mark - Private

- (id)_JSONValueFromData:(NSData *)data
{
	ApplifierImpactSBJsonParser *parser = [[ApplifierImpactSBJsonParser alloc] init];
	NSError *error = nil;
	__block NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	id repr = [parser objectWithString:jsonString error:&error];
	if (repr == nil)
	{
		NSLog(@"-JSONValue failed. Error is: %@", error);
		NSLog(@"String value: %@", jsonString);
	}
	
	if ([self.delegate respondsToSelector:@selector(campaignManager:downloadedJSON:)])
	{
		__block ApplifierImpactCampaignManager *blockSelf = self;
		
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[blockSelf.delegate campaignManager:blockSelf downloadedJSON:jsonString];
		}];
	}
	
	return repr;
}

- (NSArray *)_deserializeCampaigns:(NSArray *)campaignArray
{
	NSMutableArray *campaigns = [NSMutableArray array];
	
	for (id campaignDictionary in campaignArray)
	{
		if ([campaignDictionary isKindOfClass:[NSDictionary class]])
		{
			ApplifierImpactCampaign *campaign = [[ApplifierImpactCampaign alloc] init];
			NSURL *endScreenURL = [NSURL URLWithString:[campaignDictionary objectForKey:kCampaignEndScreenKey]];
			if (endScreenURL == nil)
			{
				NSLog(@"Campaign end screen URL is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.endScreenURL = endScreenURL;
			
			NSURL *clickURL = [NSURL URLWithString:[campaignDictionary objectForKey:kCampaignClickURLKey]];
			if (clickURL == nil)
			{
				NSLog(@"Campaign click URL is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.clickURL = clickURL;
			
			NSURL *pictureURL = [NSURL URLWithString:[campaignDictionary objectForKey:kCampaignPictureKey]];
			if (pictureURL == nil)
			{
				NSLog(@"Campaign picture URL is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.pictureURL = pictureURL;
			
			NSURL *trailerDownloadableURL = [NSURL URLWithString:[campaignDictionary objectForKey:kCampaignTrailerDownloadableKey]];
			if (trailerDownloadableURL == nil)
			{
				NSLog(@"Campaign downloadable trailer URL is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.trailerDownloadableURL = trailerDownloadableURL;
			
			NSURL *trailerStreamingURL = [NSURL URLWithString:[campaignDictionary objectForKey:kCampaignTrailerStreamingKey]];
			if (trailerStreamingURL == nil)
			{
				NSLog(@"Campaign streaming trailer URL is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.trailerStreamingURL = trailerStreamingURL;
			
			NSString *gameID = [NSString stringWithFormat:@"%@", [campaignDictionary objectForKey:kCampaignGameIDKey]];
			if (gameID == nil || [gameID length] == 0)
			{
				NSLog(@"Campaign game ID  is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.gameID = gameID;
			
			NSString *gameName = [NSString stringWithFormat:@"%@", [campaignDictionary objectForKey:kCampaignGameNameKey]];
			if (gameName == nil || [gameName length] == 0)
			{
				NSLog(@"Campaign game name is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.gameName = gameName;
			
			NSString *id = [NSString stringWithFormat:@"%@", [campaignDictionary objectForKey:kCampaignIDKey]];
			if (id == nil || [id length] == 0)
			{
				NSLog(@"Campaign ID is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.id = id;
			
			NSString *tagline = [NSString stringWithFormat:@"%@", [campaignDictionary objectForKey:kCampaignTaglineKey]];
			if (tagline == nil || [tagline length] == 0)
			{
				NSLog(@"Campaign tagline is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.tagline = tagline;
			
			[campaigns addObject:campaign];
		}
		else
		{
			NSLog(@"Unexpected value in campaign dictionary list. %@, %@", [campaignDictionary class], campaignDictionary);
			
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
			NSLog(@"Item key is empty. %@", itemDictionary);
			return nil;
		}
		item.key = key;
		
		NSString *name = [NSString stringWithFormat:@"%@", [itemDictionary objectForKey:kRewardNameKey]];
		if (name == nil || [name length] == 0)
		{
			NSLog(@"Item name is empty. %@", itemDictionary);
			return nil;
		}
		item.name = name;

		NSURL *pictureURL = [NSURL URLWithString:[itemDictionary objectForKey:kRewardPictureKey]];
		if (pictureURL == nil)
		{
			NSLog(@"Item picture URL is empty or invalid. %@", itemDictionary);
			return nil;
		}
		item.pictureURL = pictureURL;
		
		return item;
	}
	else
	{
		NSLog(@"Unknown data type for reward item dictionary: %@", [itemDictionary class]);
		
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
		
		[self.cache cacheCampaigns:self.campaigns];
	}
	else
		NSLog(@"Unknown data type for JSON: %@", [json class]);
}

#pragma mark - Public

- (id)init
{
	if ((self = [super init]))
	{
		_cache = [[ApplifierImpactCache alloc] init];
		_cache.delegate = self;
	}
	
	return self;
}

- (void)updateCampaigns
{
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:kApplifierImpactTestBackendURL]];
	self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	[self.urlConnection start];
}

- (NSURL *)videoURLForCampaign:(ApplifierImpactCampaign *)campaign
{
	// we can provide either a remote or local video URL here
	
	@synchronized (self)
	{
		NSURL *videoURL = [self.cache localVideoURLForCampaign:campaign];
		if (videoURL == nil)
			videoURL = campaign.trailerStreamingURL;

		return videoURL;
	}
}

- (void)cancelAllDownloads
{
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
	NSLog(@"didFailWithError: %@", error);
}

#pragma mark - ApplifierImpactCacheDelegate

- (void)cache:(ApplifierImpactCache *)cache finishedCachingCampaign:(ApplifierImpactCampaign *)campaign
{
}

- (void)cacheFinishedCachingCampaigns:(ApplifierImpactCache *)cache
{
	if ([self.delegate respondsToSelector:@selector(campaignManager:updatedWithCampaigns:rewardItem:)])
	{
		__block ApplifierImpactCampaignManager *blockSelf = self;
		
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[blockSelf.delegate campaignManager:blockSelf updatedWithCampaigns:blockSelf.campaigns rewardItem:blockSelf.rewardItem];
		}];
	}
}

@end
