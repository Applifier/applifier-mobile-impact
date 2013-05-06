//
//  ApplifierImpactViewState.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/4/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewState.h"
#import "../ApplifierImpactData/ApplifierImpactAnalyticsUploader.h"


@interface ApplifierImpactViewState ()
  @property (nonatomic, strong) UIViewController *storeController;
  @property (nonatomic, assign) UIViewController *targetController;
@end

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
  
  if (iTunesId != nil && !bypassAppSheet && [self _canOpenStoreProductViewController]) {
    AILOG_DEBUG(@"Opening Appstore in AppSheet: %@", iTunesId);
    [self openAppSheetWithId:iTunesId toViewController:targetViewController];
  }
  else if (clickUrl != nil) {
    AILOG_DEBUG(@"Opening Appstore with clickUrl: %@", clickUrl);
    [self openAppStoreWithUrl:clickUrl];
  }
}


#pragma mark - AppStore opening

- (BOOL)_canOpenStoreProductViewController {
  Class storeProductViewControllerClass = NSClassFromString(@"SKStoreProductViewController");
  return [storeProductViewControllerClass instancesRespondToSelector:@selector(loadProductWithParameters:completionBlock:)];
}

- (void)openAppSheetWithId:(NSString *)iTunesId toViewController:(UIViewController *)targetViewController {
  Class storeProductViewControllerClass = NSClassFromString(@"SKStoreProductViewController");
  if ([storeProductViewControllerClass instancesRespondToSelector:@selector(loadProductWithParameters:completionBlock:)] == YES) {
    if (![iTunesId isKindOfClass:[NSString class]] || iTunesId == nil || [iTunesId length] < 1) return;
    
    /*
     FIX: This _could_ bug someday. The key @"id" is written literally (and
     not using SKStoreProductParameterITunesItemIdentifier), so that
     with some compiler options (or linker flags) you wouldn't get errors.
     
     The way this could bug someday is that Apple changes the contents of
     SKStoreProductParameterITunesItemIdentifier.
     
     HOWTOFIX: Find a way to reflect global constant SKStoreProductParameterITunesItemIdentifier
     by using string value and not the constant itself.
     */
    NSDictionary *productParams = @{@"id":iTunesId};
    
    self.storeController = [[storeProductViewControllerClass alloc] init];
    
    if ([self.storeController respondsToSelector:@selector(setDelegate:)]) {
      [self.storeController performSelector:@selector(setDelegate:) withObject:self];
    }
    
    void (^storeControllerComplete)(BOOL result, NSError *error) = ^(BOOL result, NSError *error) {
      AILOG_DEBUG(@"Result: %i", result);
      if (result) {
        dispatch_async(dispatch_get_main_queue(), ^{
          self.targetController = targetViewController;
          [targetViewController presentViewController:self.storeController animated:YES completion:nil];
          ApplifierImpactCampaign *campaign = [[ApplifierImpactCampaignManager sharedInstance] getCampaignWithITunesId:iTunesId];
          
          if (campaign != nil) {
            [[ApplifierImpactAnalyticsUploader sharedInstance] sendOpenAppStoreRequest:campaign];
          }
        });
      }
      else {
        AILOG_DEBUG(@"Loading product information failed: %@", error);
      }
      
      [self applyOptions:@{kApplifierImpactNativeEventHideSpinner:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyLoading}}];
    };
    
    [self applyOptions:@{kApplifierImpactNativeEventShowSpinner:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyLoading}}];
    
    SEL loadProduct = @selector(loadProductWithParameters:completionBlock:);
    if ([self.storeController respondsToSelector:loadProduct]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      [self.storeController performSelector:loadProduct withObject:productParams withObject:storeControllerComplete];
#pragma clang diagnostic pop
    }
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


#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
  AILOG_DEBUG(@"");
  if (self.targetController != nil) {
    [self.targetController dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)dealloc {
  self.targetController = nil;
  self.storeController = nil;
}

@end
