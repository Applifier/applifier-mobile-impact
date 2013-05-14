//
//  ApplifierImpactProperties.h
//  ApplifierImpact
//
//  Created by bluesun on 11/2/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../ApplifierImpactCampaign/ApplifierImpactRewardItem.h"

@interface ApplifierImpactProperties : NSObject
  @property (nonatomic, strong) NSString *webViewBaseUrl;
  @property (nonatomic, strong) NSString *analyticsBaseUrl;
  @property (nonatomic, strong) NSString *campaignDataUrl;
  @property (nonatomic, strong) NSString *impactBaseUrl;
  @property (nonatomic, strong) NSString *campaignQueryString;
  @property (nonatomic, strong) NSString *impactGameId;
  @property (nonatomic, strong) NSString *gamerId;
  @property (nonatomic) BOOL testModeEnabled;
  @property (nonatomic, assign) UIViewController *currentViewController;
  @property (nonatomic, assign) int maxNumberOfAnalyticsRetries;
  @property (nonatomic, strong) NSString *expectedSdkVersion;
  @property (nonatomic, assign) int allowVideoSkipInSeconds;
  @property (nonatomic, strong) NSString *developerId;
  @property (nonatomic, strong) NSString *optionsId;

+ (ApplifierImpactProperties *)sharedInstance;
- (void)refreshCampaignQueryString;
- (NSString *)impactVersion;

@end
