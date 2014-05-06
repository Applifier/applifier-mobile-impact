//
//  ApplifierImpactCampaignTests.m
//  ApplifierImpact
//
//  Created by Sergey D on 4/30/14.
//  Copyright (c) 2014 Applifier. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSObject+ApplifierImpactSBJson.h"
#import "ApplifierImpactCampaign.h"
#import "ApplifierImpactConstants.h"
#import "ApplifierImpact.h"

@interface ApplifierImpactCampaignTests : SenTestCase

@end

@implementation ApplifierImpactCampaignTests

- (void)setUp
{
  [[ApplifierImpact sharedInstance] setDebugMode:YES];
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCampaignInit {
  NSError * error = nil;
  NSStringEncoding encoding = NSStringEncodingConversionAllowLossy;
  NSString * pathToResource = [[NSBundle bundleForClass:[self class]] pathForResource:@"jsonData.txt" ofType:nil];
  NSString * jsonString = [[NSString alloc] initWithContentsOfFile:pathToResource
                                                      usedEncoding:&encoding
                                                             error:&error];
  NSDictionary * jsonDataDictionary = [jsonString JSONValue];
  NSDictionary * jsonDictionary = [jsonDataDictionary objectForKey:kApplifierImpactJsonDataRootKey];
  NSArray  * campaignsDataArray = [jsonDictionary objectForKey:kApplifierImpactCampaignsKey];
  NSMutableArray *campaigns = [NSMutableArray array];
	
	for (id campaignDictionary in campaignsDataArray) {
		if ([campaignDictionary isKindOfClass:[NSDictionary class]]) {
			ApplifierImpactCampaign *campaign = [[ApplifierImpactCampaign alloc] initWithData:campaignDictionary];
      if (campaign.isValidCampaign) {
        [campaigns addObject:campaign];
      }
		}
	}  
}

@end
