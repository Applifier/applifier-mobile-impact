//
//  ApplifierImpactiOS4.m
//  ImpactProto
//
//  Created by Johan Halin on 9/4/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactiOS4.h"

NSString * const kApplifierImpactTestBackendURL = @"http://quake.everyplay.fi/~bluesun/impact/manifest.json";
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

@interface ApplifierImpact ()
@property (nonatomic, strong) NSString *applifierID;
@end

@implementation ApplifierImpactiOS4

@synthesize applifierID = _applifierID;

#pragma mark - Public

- (void)startWithApplifierID:(NSString *)applifierID
{
	self.applifierID = applifierID;
}

- (BOOL)showImpact
{
	return YES;
}

- (BOOL)hasCampaigns
{
	return YES;
}

- (void)stopAll
{
}

@end
