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
  [self placeToViewHiearchy];
}

- (void)willBeShown {
  [super willBeShown];
  [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeStart data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIOpen, kApplifierImpactRewardItemKeyKey:[[ApplifierImpact sharedInstance] getCurrentRewardItemKey], @"developerOptions":[[ApplifierImpactShowOptionsParser sharedInstance] getOptionsAsJson]}];
  
  [self placeToViewHiearchy];
}

- (void)wasShown {
  [super wasShown];
}

- (void)exitState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  
  [super exitState:options];
}

- (void)placeToViewHiearchy {
  if (![[[[ApplifierImpactWebAppController sharedInstance] webView] superview] isEqual:[[ApplifierImpactMainViewController sharedInstance] view]]) {
    [[[ApplifierImpactMainViewController sharedInstance] view] addSubview:[[ApplifierImpactWebAppController sharedInstance] webView]];
    [[[ApplifierImpactWebAppController sharedInstance] webView] setFrame:[[ApplifierImpactMainViewController sharedInstance] view].bounds];
    
    [[[ApplifierImpactMainViewController sharedInstance] view] bringSubviewToFront:[[ApplifierImpactWebAppController sharedInstance] webView]];
  }
}

- (void)applyOptions:(NSDictionary *)options {
  [super applyOptions:options];
  
  if ([options objectForKey:kApplifierImpactWebViewEventDataClickUrlKey] != nil) {
    [self openAppStoreWithData:options inViewController:[ApplifierImpactMainViewController sharedInstance]];
  }
}

@end
