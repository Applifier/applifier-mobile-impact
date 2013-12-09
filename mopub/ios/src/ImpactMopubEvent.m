/*
 * Copyright 2013, Applifier Oy
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ImpactMopubEvent.h"

@implementation ImpactMopubEvent

static NSString const * const kApplifierImpactOptionZoneIdKey = @"zoneId";

@synthesize delegate;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
  [[ApplifierImpact sharedInstance] setDebugMode:YES];
  [[ApplifierImpact sharedInstance] startWithGameId:[info objectForKey:@"gameId"]];
  [[ApplifierImpact sharedInstance] setDelegate:self];
  
  // Parse the options, if we have any
  _params = [[NSMutableDictionary alloc] init];
  _zoneId = [info objectForKey:kApplifierImpactOptionZoneIdKey];
  
  NSString *noOfferScreenValue = [info objectForKey:kApplifierImpactOptionNoOfferscreenKey];
  NSString *openAnimatedValue = [info objectForKey:kApplifierImpactOptionOpenAnimatedKey];
  NSString *gamerSidValue = [info objectForKey:kApplifierImpactOptionGamerSIDKey];
  NSString *muteVideoSoundsValue = [info objectForKey:kApplifierImpactOptionMuteVideoSounds];
  NSString *videoUsesDeviceOrientationValue = [info objectForKey:kApplifierImpactOptionVideoUsesDeviceOrientation];
  
  if(noOfferScreenValue != nil) {
    [_params setObject:noOfferScreenValue forKey:kApplifierImpactOptionNoOfferscreenKey];
  }
  if(openAnimatedValue != nil) {
    [_params setObject:openAnimatedValue forKey:kApplifierImpactOptionOpenAnimatedKey];
  }
  if(gamerSidValue != nil) {
    [_params setObject:gamerSidValue forKey:kApplifierImpactOptionGamerSIDKey];
  }
  if(muteVideoSoundsValue != nil) {
    [_params setObject:muteVideoSoundsValue forKey:kApplifierImpactOptionMuteVideoSounds];
  }
  if(videoUsesDeviceOrientationValue != nil) {
    [_params setObject:videoUsesDeviceOrientationValue forKey:kApplifierImpactOptionVideoUsesDeviceOrientation];
  }
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    if([[ApplifierImpact sharedInstance] canShowCampaigns]) {
      [self.delegate interstitialCustomEvent:self didLoadAd:nil];
    }
  });
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
  if([[ApplifierImpact sharedInstance] canShowCampaigns]) {
    [[ApplifierImpact sharedInstance] setViewController:rootViewController showImmediatelyInNewController:NO];
    [[ApplifierImpact sharedInstance] setZone:_zoneId];
    [[ApplifierImpact sharedInstance] showImpact:_params];
  }
}

- (void)applifierImpact:(ApplifierImpact *)applifierImpact completedVideoWithRewardItemKey:(NSString *)rewardItemKey videoWasSkipped:(BOOL)skipped {
  // Ignored, as no support for incentivised ads via Mopub
}

- (void)applifierImpactCampaignsAreAvailable:(ApplifierImpact *)applifierImpact {
  [self.delegate interstitialCustomEvent:self didLoadAd:nil];
}

- (void)applifierImpactCampaignsFetchFailed:(ApplifierImpact *)applifierImpact {
  NSMutableDictionary* details = [NSMutableDictionary dictionary];
  [details setValue:@"No ads available" forKey:NSLocalizedDescriptionKey];
  [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:@"impact_sdk" code:404 userInfo:details]];
}

- (void)applifierImpactDidClose:(ApplifierImpact *)applifierImpact {
  [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)applifierImpactDidOpen:(ApplifierImpact *)applifierImpact {
  [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)applifierImpactVideoStarted:(ApplifierImpact *)applifierImpact {
  // Ignored
}

- (void)applifierImpactWillClose:(ApplifierImpact *)applifierImpact {
  [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)applifierImpactWillOpen:(ApplifierImpact *)applifierImpact {
  [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)applifierImpactWillLeaveApplication:(ApplifierImpact *)applifierImpact {
  [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

@end
