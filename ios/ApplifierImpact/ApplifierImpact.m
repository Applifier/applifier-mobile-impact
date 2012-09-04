//
//  ApplifierImpact.m
//  ApplifierImpact
//
//  Created by Johan Halin on 9/4/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpact.h"

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

@implementation ApplifierImpact

@synthesize applifierID = _applifierID;
@synthesize delegate = _delegate;

#pragma mark - Private

- (id)initApplifierInstance
{
	if ((self = [super init]))
	{
	}
	
	return self;
}

#pragma mark - Public

static ApplifierImpact *sharedApplifierInstance = nil;

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
}

+ (id)sharedInstance
{
	@synchronized(self)
	{
		if (sharedApplifierInstance == nil)
			sharedApplifierInstance = [[self alloc] initApplifierInstance];
	}
	
	return sharedApplifierInstance;
}

- (void)startWithApplifierID:(NSString *)applifierID
{
	if ( ! [self respondsToSelector:@selector(autoContentAccessingProxy)]) // check if we're on at least iOS 4.0
		return;
	
	self.applifierID = applifierID;
}

- (BOOL)showImpact
{
	if (self.applifierID == nil)
		return NO;
	
	return YES;
}

- (BOOL)hasCampaigns
{
	if (self.applifierID == nil)
		return NO;
	
	return NO;
}

- (void)stopAll
{
	if (self.applifierID == nil)
		return;
}

@end
