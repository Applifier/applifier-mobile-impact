//
//  ApplifierImpactViewStateNoWebViewEndScreen.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/11/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewStateNoWebViewEndScreen.h"
#import "../ApplifierImpactView/ApplifierImpactNoWebViewEndScreenViewController.h"

@interface ApplifierImpactViewStateNoWebViewEndScreen ()
  @property (nonatomic, strong) ApplifierImpactNoWebViewEndScreenViewController *endScreenController;
@end

@implementation ApplifierImpactViewStateNoWebViewEndScreen

- (ApplifierImpactViewStateType)getStateType {
  return kApplifierImpactViewStateTypeEndScreen;
}

- (void)enterState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  
  [super enterState:options];
  
  if (self.endScreenController == nil) {
    [self createEndScreenController];
  }
  
  [[ApplifierImpactMainViewController sharedInstance] presentViewController:self.endScreenController animated:NO completion:nil];
  /*
  [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeCompleted data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIActionVideoStartedPlaying, kApplifierImpactItemKeyKey:[[ApplifierImpactCampaignManager sharedInstance] getCurrentRewardItem].key, kApplifierImpactWebViewEventDataCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
   */
}

- (void)exitState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  
  [super exitState:options];
  [[ApplifierImpactMainViewController sharedInstance] dismissViewControllerAnimated:NO completion:nil];

  // FIX: Doesn't always work right with rewatch (setView:None (null))
  if ([options objectForKey:kApplifierImpactWebViewEventDataRewatchKey] == nil || [[options valueForKey:kApplifierImpactWebViewEventDataRewatchKey] boolValue] == false) {
    //[[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeNone data:@{}];
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
  
  if ([options objectForKey:kApplifierImpactNativeEventShowSpinner] != nil) {
    //[[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowSpinner data:[options objectForKey:kApplifierImpactNativeEventShowSpinner]];
  }
  else if ([options objectForKey:kApplifierImpactNativeEventHideSpinner] != nil) {
    //[[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventHideSpinner data:[options objectForKey:kApplifierImpactNativeEventHideSpinner]];
  }
  else if ([options objectForKey:kApplifierImpactWebViewEventDataClickUrlKey] != nil) {
    [self openAppStoreWithData:options];
  }
}

#pragma mark - Private controller handling

- (void)createEndScreenController {
  AILOG_DEBUG(@"");
  self.endScreenController = [[ApplifierImpactNoWebViewEndScreenViewController alloc] initWithNibName:nil bundle:nil];
}

@end
