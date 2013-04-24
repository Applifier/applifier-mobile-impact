//
//  ApplifierImpactViewStateDefaultOffers.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/4/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewStateDefaultOffers.h"

#import "../ApplifierImpactWebView/ApplifierImpactWebAppController.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"
#import "../ApplifierImpactCampaign/ApplifierImpactRewardItem.h"
#import "../ApplifierImpactView/ApplifierImpactMainViewController.h"
#import "../ApplifierImpact.h"
#import "../ApplifierImpactProperties/ApplifierImpactShowOptionsParser.h"

@implementation ApplifierImpactViewStateDefaultOffers

- (ApplifierImpactViewStateType)getStateType {
  return kApplifierImpactViewStateTypeOfferScreen;
}

- (void)enterState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  
  [super enterState:options];
  
  [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeStart data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIOpen, kApplifierImpactItemKeyKey:[[ApplifierImpactCampaignManager sharedInstance] getCurrentRewardItem].key, kApplifierImpactWebViewAPIDeveloperOptions:[[ApplifierImpactShowOptionsParser sharedInstance] getOptionsAsJson]}];
  
  if (![[[[ApplifierImpactWebAppController sharedInstance] webView] superview] isEqual:[[ApplifierImpactMainViewController sharedInstance] view]]) {
    [[[ApplifierImpactMainViewController sharedInstance] view] addSubview:[[ApplifierImpactWebAppController sharedInstance] webView]];
    [[[ApplifierImpactWebAppController sharedInstance] webView] setFrame:[[ApplifierImpactMainViewController sharedInstance] view].bounds];
  }
}

- (void)willBeShown {
  [super willBeShown];
}

- (void)wasShown {
  [super wasShown];
}

- (void)exitState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  
  [super exitState:options];
}


@end
