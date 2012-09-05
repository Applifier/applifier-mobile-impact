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

- (NSArray *)_parseCampaigns:(NSArray *)campaignArray
{
	NSMutableArray *campaigns = [NSMutableArray array];
	
	for (id campaignDictionary in campaignArray)
	{
		if ([campaignDictionary isKindOfClass:[NSDictionary class]])
		{
			ApplifierImpactCampaign *campaign = [[ApplifierImpactCampaign alloc] init];
			campaign.appIconURL = [NSURL URLWithString:[campaignDictionary objectForKey:@"appIcon"]];
			campaign.clickURL = [NSURL URLWithString:[campaignDictionary objectForKey:@"clickUrl"]];
			campaign.pictureURL = [NSURL URLWithString:[campaignDictionary objectForKey:@"picture"]];
			campaign.trailerDownloadableURL = [NSURL URLWithString:[campaignDictionary objectForKey:@"trailerDownloadable"]];
			campaign.trailerStreamingURL = [NSURL URLWithString:[campaignDictionary objectForKey:@"trailerStreaming"]];
			campaign.gameID = [NSString stringWithFormat:@"%@", [campaignDictionary objectForKey:@"gameId"]];
			campaign.gameName = [NSString stringWithFormat:@"%@", [campaignDictionary objectForKey:@"gameName"]];
			campaign.id = [NSString stringWithFormat:@"%@", [campaignDictionary objectForKey:@"id"]];
			
			[campaigns addObject:campaign];
		}
		else
		{
			NSLog(@"Unexpected value in campaign list. %@, %@", [campaignDictionary class], campaignDictionary);
			
			continue;
		}
	}
	
	return campaigns;
}

- (id)_parseItem:(NSDictionary *)itemDictionary
{
	if ([itemDictionary isKindOfClass:[NSDictionary class]])
	{
		ApplifierImpactRewardItem *item = [[ApplifierImpactRewardItem alloc] init];
		item.key = [NSString stringWithFormat:@"%@", [itemDictionary objectForKey:@"itemKey"]];
		item.name = [NSString stringWithFormat:@"%@", [itemDictionary objectForKey:@"name"]];
		item.pictureURL = [NSURL URLWithString:[itemDictionary objectForKey:@"picture"]];
		
		return item;
	}
	else
	{
		NSLog(@"Unknown data type for reward item dictionary: %@", [itemDictionary class]);
		
		return nil;
	}
}

- (void)_saveCampaigns:(NSArray *)campaigns rewardItem:(ApplifierImpactRewardItem *)rewardItem
{
	if (campaigns == nil || rewardItem == nil)
	{
		NSLog(@"Both campaigns and reward items must be non-nil.");
		
		return;
	}
	
	// TODO: save to disk
}

- (void)_processCampaignDownloadData
{
	id json = [self _JSONValueFromData:self.campaignDownloadData];
	if ([json isKindOfClass:[NSDictionary class]])
	{
		NSDictionary *jsonDictionary = [(NSDictionary *)json objectForKey:@"data"];
		NSArray *parsedCampaigns = [self _parseCampaigns:[jsonDictionary objectForKey:@"campaigns"]];
		ApplifierImpactRewardItem *parsedItem = [self _parseItem:[jsonDictionary objectForKey:@"item"]];
		[self _saveCampaigns:parsedCampaigns rewardItem:parsedItem];
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
