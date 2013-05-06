//
//  ApplifierImpactViewStateDefaultEndScreen.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/4/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewStateDefaultEndScreen.h"

#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"
#import "../ApplifierImpactCampaign/ApplifierImpactRewardItem.h"

@implementation ApplifierImpactViewStateDefaultEndScreen

- (ApplifierImpactViewStateType)getStateType {
  return kApplifierImpactViewStateTypeEndScreen;
}

- (void)enterState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  
  [super enterState:options];
  
  [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeCompleted data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIActionVideoStartedPlaying, kApplifierImpactItemKeyKey:[[ApplifierImpactCampaignManager sharedInstance] getCurrentRewardItem].key, kApplifierImpactWebViewEventDataCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
  
  if (![[[[ApplifierImpactWebAppController sharedInstance] webView] superview] isEqual:[[ApplifierImpactMainViewController sharedInstance] view]]) {
    [[[ApplifierImpactMainViewController sharedInstance] view] addSubview:[[ApplifierImpactWebAppController sharedInstance] webView]];
    [[[ApplifierImpactWebAppController sharedInstance] webView] setFrame:[[ApplifierImpactMainViewController sharedInstance] view].bounds];
    
    [[[ApplifierImpactMainViewController sharedInstance] view] bringSubviewToFront:[[ApplifierImpactWebAppController sharedInstance] webView]];
  }
}

- (void)exitState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  
  [super exitState:options];
  
  if ([options objectForKey:kApplifierImpactWebViewEventDataRewatchKey] == nil || [[options valueForKey:kApplifierImpactWebViewEventDataRewatchKey] boolValue] == false) {
    [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeNone data:@{}];
  }
}

- (void)willBeShown {
  [super willBeShown];
}

- (void)wasShown {
  [super wasShown];
}

- (void)applyOptions:(NSDictionary *)options {
  [super applyOptions:options];
  
  if ([options objectForKey:kApplifierImpactWebViewEventDataClickUrlKey] != nil) {
    [self openAppStoreWithData:options inViewController:[ApplifierImpactMainViewController sharedInstance]];
  }
}

@end
