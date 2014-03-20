//
//  ApplifierImpactViewStateOfferScreen.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/4/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewStateOfferScreen.h"

#import "../ApplifierImpactWebView/ApplifierImpactWebAppController.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"
#import "../ApplifierImpactItem/ApplifierImpactRewardItem.h"
#import "../ApplifierImpactView/ApplifierImpactMainViewController.h"
#import "../ApplifierImpact.h"

#import "../ApplifierImpactZone/ApplifierImpactZoneManager.h"
#import "../ApplifierImpactZone/ApplifierImpactIncentivizedZone.h"

@implementation ApplifierImpactViewStateOfferScreen

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
  id currentZone = [[ApplifierImpactZoneManager sharedInstance] getCurrentZone];
  if([currentZone isIncentivized]) {
    id itemManager = [((ApplifierImpactIncentivizedZone *)currentZone) itemManager];
    [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeStart data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIOpen, kApplifierImpactWebViewDataParamZoneKey: [currentZone getZoneId], kApplifierImpactItemKeyKey:[itemManager getCurrentItem].key}];
  } else {
    [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeStart data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIOpen, kApplifierImpactWebViewDataParamZoneKey: [currentZone getZoneId]}];
  }
  
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
