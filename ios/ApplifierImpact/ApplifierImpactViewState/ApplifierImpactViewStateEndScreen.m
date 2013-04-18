//
//  ApplifierImpactViewStateEndScreen.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/5/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewStateEndScreen.h"

@interface ApplifierImpactViewStateEndScreen ()
  @property (nonatomic, strong) UIViewController *storeController;
  @property (nonatomic, assign) UIViewController *targetController;
@end

@implementation ApplifierImpactViewStateEndScreen

#pragma mark - AppStore opening

- (BOOL)_canOpenStoreProductViewController {
  Class storeProductViewControllerClass = NSClassFromString(@"SKStoreProductViewController");
  return [storeProductViewControllerClass instancesRespondToSelector:@selector(loadProductWithParameters:completionBlock:)];
}

- (void)openAppStoreWithData:(NSDictionary *)data inViewController:(UIViewController *)targetViewController {
  AILOG_DEBUG(@"");
  
  if (![self _canOpenStoreProductViewController] || [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].bypassAppSheet == YES) {
    NSString *clickUrl = [data objectForKey:kApplifierImpactWebViewEventDataClickUrlKey];
    if (clickUrl == nil) return;
    AILOG_DEBUG(@"Cannot open store product view controller, falling back to click URL.");
    [[ApplifierImpactAnalyticsUploader sharedInstance] sendOpenAppStoreRequest:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign]];
    
    if (self.delegate != nil) {
      [self.delegate stateNotification:kApplifierImpactStateActionWillLeaveApplication];
    }
    
    // DOES NOT INITIALIZE WEBVIEW
    AILOG_DEBUG(@"CLICK_URL: %@", clickUrl);
    [[ApplifierImpactWebAppController sharedInstance] openExternalUrl:clickUrl];
    return;
  }
  
  Class storeProductViewControllerClass = NSClassFromString(@"SKStoreProductViewController");
  if ([storeProductViewControllerClass instancesRespondToSelector:@selector(loadProductWithParameters:completionBlock:)] == YES) {
    if (![[data objectForKey:kApplifierImpactCampaignStoreIDKey] isKindOfClass:[NSString class]]) return;
    NSString *gameId = nil;
    gameId = [data valueForKey:kApplifierImpactCampaignStoreIDKey];
    if (gameId == nil || [gameId length] < 1) return;
    
    /*
     FIX: This _could_ bug someday. The key @"id" is written literally (and
     not using SKStoreProductParameterITunesItemIdentifier), so that
     with some compiler options (or linker flags) you wouldn't get errors.
     
     The way this could bug someday is that Apple changes the contents of
     SKStoreProductParameterITunesItemIdentifier.
     
     HOWTOFIX: Find a way to reflect global constant SKStoreProductParameterITunesItemIdentifier
     by using string value and not the constant itself.
     */
    NSDictionary *productParams = @{@"id":gameId};
    
    self.storeController = [[storeProductViewControllerClass alloc] init];
    
    if ([self.storeController respondsToSelector:@selector(setDelegate:)]) {
      [self.storeController performSelector:@selector(setDelegate:) withObject:self];
    }
    
    void (^storeControllerComplete)(BOOL result, NSError *error) = ^(BOOL result, NSError *error) {
      AILOG_DEBUG(@"RESULT: %i", result);
      if (result) {
        dispatch_async(dispatch_get_main_queue(), ^{
          self.targetController = targetViewController;
          [targetViewController presentViewController:self.storeController animated:YES completion:nil];
          [[ApplifierImpactAnalyticsUploader sharedInstance] sendOpenAppStoreRequest:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign]];
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