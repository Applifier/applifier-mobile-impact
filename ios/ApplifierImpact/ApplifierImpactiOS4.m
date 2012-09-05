//
//  ApplifierImpactiOS4.m
//  ImpactProto
//
//  Created by Johan Halin on 9/4/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactiOS4.h"
#import "ApplifierImpactCampaignManager.h"

@interface ApplifierImpact ()
@property (nonatomic, strong) NSString *applifierID;
@property (nonatomic, strong) ApplifierImpactCampaignManager *campaignManager;
@property (nonatomic, strong) UIWindow *applifierWindow;
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation ApplifierImpactiOS4

@synthesize applifierID = _applifierID;
@synthesize campaignManager = _campaignManager;
@synthesize applifierWindow = _applifierWindow;
@synthesize webView = _webView;

#pragma mark - Public

- (void)startWithApplifierID:(NSString *)applifierID
{
	if (self.campaignManager != nil)
		return;
	
	self.applifierID = applifierID;
	self.campaignManager = [[ApplifierImpactCampaignManager alloc] init];

	[self.campaignManager updateCampaigns];
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
