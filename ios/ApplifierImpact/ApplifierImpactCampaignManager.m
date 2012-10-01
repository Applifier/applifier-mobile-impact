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
NSString * const kCampaignTaglineKey = @"tagLine";
NSString * const kCampaignStoreIDKey = @"iTunesId";

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
	AIAssertV(data != nil, nil);
	
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
			
			NSString *endScreenURLString = [campaignDictionary objectForKey:kCampaignEndScreenKey];
			AIAssertV([endScreenURLString isKindOfClass:[NSString class]], nil);
			NSURL *endScreenURL = [NSURL URLWithString:endScreenURLString];
			AIAssertV(endScreenURL != nil, nil);
			campaign.endScreenURL = endScreenURL;
			
			NSString *clickURLString = [campaignDictionary objectForKey:kCampaignClickURLKey];
			AIAssertV([clickURLString isKindOfClass:[NSString class]], nil);
			NSURL *clickURL = [NSURL URLWithString:clickURLString];
			AIAssertV(clickURL != nil, nil);
			campaign.clickURL = clickURL;
			
			NSString *pictureURLString = [campaignDictionary objectForKey:kCampaignPictureKey];
			AIAssertV([pictureURLString isKindOfClass:[NSString class]], nil);
			NSURL *pictureURL = [NSURL URLWithString:pictureURLString];
			AIAssertV(pictureURL != nil, nil);
			campaign.pictureURL = pictureURL;
			
			NSString *trailerDownloadableURLString = [campaignDictionary objectForKey:kCampaignTrailerDownloadableKey];
			AIAssertV([trailerDownloadableURLString isKindOfClass:[NSString class]], nil);
			NSURL *trailerDownloadableURL = [NSURL URLWithString:trailerDownloadableURLString];
			AIAssertV(trailerDownloadableURL != nil, nil);
			campaign.trailerDownloadableURL = trailerDownloadableURL;
			
			NSString *trailerStreamingURLString = [campaignDictionary objectForKey:kCampaignTrailerStreamingKey];
			AIAssertV([trailerStreamingURLString isKindOfClass:[NSString class]], nil);
			NSURL *trailerStreamingURL = [NSURL URLWithString:trailerStreamingURLString];
			AIAssertV(trailerStreamingURL != nil, nil);
			campaign.trailerStreamingURL = trailerStreamingURL;
			
			id gameIDValue = [campaignDictionary objectForKey:kCampaignGameIDKey];
			AIAssertV(gameIDValue != nil && ([gameIDValue isKindOfClass:[NSString class]] || [gameIDValue isKindOfClass:[NSNumber class]]), nil);
			NSString *gameID = [gameIDValue isKindOfClass:[NSNumber class]] ? [gameIDValue stringValue] : gameIDValue;
			AIAssertV(gameID != nil && [gameID length] > 0, nil);
			campaign.gameID = gameID;
			
			id gameNameValue = [campaignDictionary objectForKey:kCampaignGameNameKey];
			AIAssertV(gameNameValue != nil && ([gameNameValue isKindOfClass:[NSString class]] || [gameNameValue isKindOfClass:[NSNumber class]]), nil);
			NSString *gameName = [gameNameValue isKindOfClass:[NSNumber class]] ? [gameNameValue stringValue] : gameNameValue;
			AIAssertV(gameName != nil && [gameName length] > 0, nil);
			campaign.gameName = gameName;
			
			id idValue = [campaignDictionary objectForKey:kCampaignIDKey];
			AIAssertV(idValue != nil && ([idValue isKindOfClass:[NSString class]] || [idValue isKindOfClass:[NSNumber class]]), nil);
			NSString *idString = [idValue isKindOfClass:[NSNumber class]] ? [idValue stringValue] : idValue;
			AIAssertV(idString != nil && [idString length] > 0, nil);
			campaign.id = idString;
			
			id tagLineValue = [campaignDictionary objectForKey:kCampaignTaglineKey];
			AIAssertV(tagLineValue != nil && ([tagLineValue isKindOfClass:[NSString class]] || [tagLineValue isKindOfClass:[NSNumber class]]), nil);
			NSString *tagline = [tagLineValue isKindOfClass:[NSNumber class]] ? [tagLineValue stringValue] : tagLineValue;
			AIAssertV(tagline != nil && [tagline length] > 0, nil);
			campaign.tagLine = tagline;
			
			id itunesIDValue = [campaignDictionary objectForKey:kCampaignStoreIDKey];
			AIAssertV(itunesIDValue != nil && ([itunesIDValue isKindOfClass:[NSString class]] || [itunesIDValue isKindOfClass:[NSNumber class]]), nil);
			NSString *itunesID = [itunesIDValue isKindOfClass:[NSNumber class]] ? [itunesIDValue stringValue] : itunesIDValue;
			AIAssertV(itunesID != nil && [itunesID length] > 0, nil);
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
	AIAssertV([itemDictionary isKindOfClass:[NSDictionary class]], nil);
	
	ApplifierImpactRewardItem *item = [[ApplifierImpactRewardItem alloc] init];

	id keyValue = [itemDictionary objectForKey:kRewardItemKey];
	AIAssertV(keyValue != nil && ([keyValue isKindOfClass:[NSString class]] || [keyValue isKindOfClass:[NSNumber class]]), nil);
	NSString *key = [keyValue isKindOfClass:[NSNumber class]] ? [keyValue stringValue] : keyValue;
	AIAssertV(key != nil && [key length] > 0, nil);
	item.key = key;
	
	id nameValue = [itemDictionary objectForKey:kRewardNameKey];
	AIAssertV(nameValue != nil && ([nameValue isKindOfClass:[NSString class]] || [nameValue isKindOfClass:[NSNumber class]]), nil);
	NSString *name = [nameValue isKindOfClass:[NSNumber class]] ? [nameValue stringValue] : nameValue;
	AIAssertV(name != nil && [name length] > 0, nil);
	item.name = name;
	
	NSString *pictureURLString = [itemDictionary objectForKey:kRewardPictureKey];
	AIAssertV([pictureURLString isKindOfClass:[NSString class]], nil);
	NSURL *pictureURL = [NSURL URLWithString:pictureURLString];
	AIAssertV(pictureURL != nil, nil);
	item.pictureURL = pictureURL;
	
	return item;
}

- (void)_processCampaignDownloadData
{
	id json = [self _JSONValueFromData:self.campaignDownloadData];

	AIAssert([json isKindOfClass:[NSDictionary class]]);
	
	NSDictionary *jsonDictionary = [(NSDictionary *)json objectForKey:@"data"];
	self.campaigns = [self _deserializeCampaigns:[jsonDictionary objectForKey:@"campaigns"]];
	self.rewardItem = [self _deserializeRewardItem:[jsonDictionary objectForKey:@"item"]];
	
	NSString *gamerID = [jsonDictionary objectForKey:kGamerIDKey];
	AIAssert(gamerID != nil);
	self.gamerID = gamerID;
	
	[self.cache cacheCampaigns:self.campaigns];
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
	
    AILOG_DEBUG(@"UrlString %@", urlString);
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
	self.campaignDownloadData = nil;
	self.urlConnection = nil;
	
	NSInteger errorCode = [error code];
	if (errorCode != NSURLErrorNotConnectedToInternet &&
		errorCode != NSURLErrorCannotFindHost &&
		errorCode != NSURLErrorCannotConnectToHost &&
		errorCode != NSURLErrorResourceUnavailable &&
		errorCode != NSURLErrorFileDoesNotExist &&
		errorCode != NSURLErrorNoPermissionsToReadFile)
	{
		AILOG_DEBUG(@"Retrying campaign download.");
		[self updateCampaigns];
	}
	else
		AILOG_DEBUG(@"Not retrying campaign download.");
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
