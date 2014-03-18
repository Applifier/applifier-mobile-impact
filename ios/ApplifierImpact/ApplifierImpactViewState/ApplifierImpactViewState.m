//
//  ApplifierImpactViewState.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/4/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewState.h"
#import "../ApplifierImpactData/ApplifierImpactAnalyticsUploader.h"
#import "ApplifierImpactAppSheetManager.h"

@implementation ApplifierImpactViewState

- (id)init {
  self = [super init];
  self.waitingToBeShown = false;
  return self;
}

- (void)enterState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
}

- (void)exitState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  self.waitingToBeShown = false;
}

- (void)willBeShown {
  AILOG_DEBUG(@"");
  self.waitingToBeShown = true;
}

- (void)wasShown {
  AILOG_DEBUG(@"");
  self.waitingToBeShown = false;
}

- (void)applyOptions:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  
  if ([options objectForKey:kApplifierImpactNativeEventShowSpinner] != nil) {
    [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowSpinner data:[options objectForKey:kApplifierImpactNativeEventShowSpinner]];
  }
  else if ([options objectForKey:kApplifierImpactNativeEventHideSpinner] != nil) {
    [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventHideSpinner data:[options objectForKey:kApplifierImpactNativeEventHideSpinner]];
  }
}

- (ApplifierImpactViewStateType)getStateType {
  return kApplifierImpactViewStateTypeInvalid;
}

- (void)openAppStoreWithData:(NSDictionary *)data inViewController:(UIViewController *)targetViewController {
  AILOG_DEBUG(@"");
  
  BOOL bypassAppSheet = false;
  NSString *iTunesId = nil;
  NSString *clickUrl = nil;
  
  if (data != nil) {
    if ([data objectForKey:kApplifierImpactWebViewEventDataBypassAppSheetKey] != nil) {
      bypassAppSheet = [[data objectForKey:kApplifierImpactWebViewEventDataBypassAppSheetKey] boolValue];
    }
    if ([data objectForKey:kApplifierImpactCampaignStoreIDKey] != nil && [[data objectForKey:kApplifierImpactCampaignStoreIDKey] isKindOfClass:[NSString class]]) {
      iTunesId = [data objectForKey:kApplifierImpactCampaignStoreIDKey];
    }
    if ([data objectForKey:kApplifierImpactWebViewEventDataClickUrlKey] != nil && [[data objectForKey:kApplifierImpactWebViewEventDataClickUrlKey] isKindOfClass:[NSString class]]) {
      clickUrl = [data objectForKey:kApplifierImpactWebViewEventDataClickUrlKey];
    }
  }
  
  if (iTunesId != nil && !bypassAppSheet && [ApplifierImpactAppSheetManager canOpenStoreProductViewController]) {
    AILOG_DEBUG(@"Opening Appstore in AppSheet: %@", iTunesId);
    [self openAppSheetWithId:iTunesId toViewController:targetViewController];
  }
  else if (clickUrl != nil) {
    AILOG_DEBUG(@"Opening Appstore with clickUrl: %@", clickUrl);
    [self openAppStoreWithUrl:clickUrl];
  }
}

- (void)openAppSheetWithId:(NSString *)iTunesId toViewController:(UIViewController *)targetViewController {
  [self applyOptions:@{kApplifierImpactNativeEventShowSpinner:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyLoading}}];
  id storeController = [[ApplifierImpactAppSheetManager sharedInstance] getAppSheetController:iTunesId];
  if(storeController != nil) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self applyOptions:@{kApplifierImpactNativeEventHideSpinner:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyLoading}}];
      [targetViewController presentViewController:storeController animated:YES completion:nil];
      ApplifierImpactCampaign *campaign = [[ApplifierImpactCampaignManager sharedInstance] getCampaignWithITunesId:iTunesId];
      if (campaign != nil) {
        [[ApplifierImpactAnalyticsUploader sharedInstance] sendOpenAppStoreRequest:campaign];
      }
    });
  } else {
    [[ApplifierImpactAppSheetManager sharedInstance] openAppSheetWithId:iTunesId toViewController:targetViewController withCompletionBlock:^(BOOL result, NSError *error) {
      [self applyOptions:@{kApplifierImpactNativeEventHideSpinner:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyLoading}}];
    }];
  }
}

- (void)openAppStoreWithUrl:(NSString *)clickUrl {
  if (clickUrl == nil) return;
  
  ApplifierImpactCampaign *campaign = [[ApplifierImpactCampaignManager sharedInstance] getCampaignWithClickUrl:clickUrl];
  
  if (campaign != nil) {
    [[ApplifierImpactAnalyticsUploader sharedInstance] sendOpenAppStoreRequest:campaign];
  }
  
  if (self.delegate != nil) {
    [self.delegate stateNotification:kApplifierImpactStateActionWillLeaveApplication];
  }
  
  // DOES NOT INITIALIZE WEBVIEW
  [[ApplifierImpactWebAppController sharedInstance] openExternalUrl:clickUrl];
  return;
}

@end
