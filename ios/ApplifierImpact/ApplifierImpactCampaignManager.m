//
//  ApplifierImpactCampaignManager.m
//  ImpactProto
//
//  Created by Johan Halin on 5.9.2012.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactCampaignManager.h"
#import "ApplifierImpactSBJSONParser.h"

NSString * const kApplifierImpactTestBackendURL = @"https://impact.applifier.com/campaigns/mobile";
NSString * const kApplifierImpactTestWebViewURL = @"http://quake.everyplay.fi/~bluesun/impact/webapp.html";

NSString const * kCampaignAppIconKey = @"appIcon";
NSString const * kCampaignClickURLKey = @"clickUrl";
NSString const * kCampaignPictureKey = @"picture";
NSString const * kCampaignTrailerDownloadableKey = @"trailerDownloadable";
NSString const * kCampaignTrailerStreamingKey = @"trailerStreaming";
NSString const * kCampaignGameIDKey = @"gameId";
NSString const * kCampaignGameNameKey = @"gameName";
NSString const * kCampaignIDKey = @"id";

NSString const * kRewardItemKey = @"itemKey";
NSString const * kRewardNameKey = @"name";
NSString const * kRewardPictureKey = @"picture";

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

@interface ApplifierImpactCampaign : NSObject
@property (nonatomic, strong) NSURL *appIconURL;
@property (nonatomic, strong) NSURL *clickURL;
@property (nonatomic, strong) NSURL *pictureURL;
@property (nonatomic, strong) NSURL *trailerDownloadableURL;
@property (nonatomic, strong) NSURL *trailerStreamingURL;
@property (nonatomic, strong) NSString *gameID;
@property (nonatomic, strong) NSString *gameName;
@property (nonatomic, strong) NSString *id;
@end

@implementation ApplifierImpactCampaign
@synthesize appIconURL = _appIconURL;
@synthesize clickURL = _clickURL;
@synthesize pictureURL = _pictureURL;
@synthesize trailerDownloadableURL = _trailerDownloadableURL;
@synthesize trailerStreamingURL = _trailerStreamingURL;
@synthesize gameID = _gameID;
@synthesize gameName = _gameName;
@synthesize id = _id;
@end

@interface ApplifierImpactRewardItem : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *pictureURL;
@end

@implementation ApplifierImpactRewardItem
@synthesize key = _key;
@synthesize name = _name;
@synthesize pictureURL = _pictureURL;
@end

@interface ApplifierImpactCampaignManager () <NSURLConnectionDelegate>
@property (nonatomic, strong) NSMutableData *campaignDownloadData;
@end

@implementation ApplifierImpactCampaignManager

@synthesize campaignDownloadData = _campaignDownloadData;

#pragma mark - Private

- (id)_JSONValueFromData:(NSData *)data
{
	ApplifierImpactSBJsonParser *parser = [[ApplifierImpactSBJsonParser alloc] init];
	NSError *error = nil;
	NSString *jsonString = [NSString stringWithUTF8String:[data bytes]];
	id repr = [parser objectWithString:jsonString error:&error];
	if (repr == nil)
	{
		NSLog(@"-JSONValue failed. Error is: %@", error);
		NSLog(@"String value: %@", jsonString);
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
			NSURL *appIconURL = [NSURL URLWithString:[campaignDictionary objectForKey:kCampaignAppIconKey]];
			if (appIconURL == nil)
			{
				NSLog(@"Campaign app icon URL is empty or invalid. %@", campaignDictionary);
				return nil;
			}
			campaign.appIconURL = appIconURL;
			
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

- (NSString *)_dataFilePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	if (paths == nil || [paths count] == 0)
		return nil;
	
	NSString *cachePath = [paths objectAtIndex:0];
	
	return [cachePath stringByAppendingString:@"/impact.plist"];
}

- (void)_processCampaignDownloadData
{
	id json = [self _JSONValueFromData:self.campaignDownloadData];
	if ([json isKindOfClass:[NSDictionary class]])
	{
		NSDictionary *jsonDictionary = [(NSDictionary *)json objectForKey:@"data"];
		NSArray *parsedCampaigns = [self _deserializeCampaigns:[jsonDictionary objectForKey:@"campaigns"]];
		ApplifierImpactRewardItem *parsedItem = [self _deserializeRewardItem:[jsonDictionary objectForKey:@"item"]];
	}
	else
		NSLog(@"Unknown data type for JSON: %@", [json class]);
}

#pragma mark - Public

- (void)updateCampaigns
{
	self.campaignDownloadData = [NSMutableData data];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:kApplifierImpactTestBackendURL]];
	[NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDelegate

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

@end
