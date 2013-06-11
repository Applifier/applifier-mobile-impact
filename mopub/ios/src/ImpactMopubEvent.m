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

static NSString *DEVICE_ORIENTATION_KEY = @"deviceOrientation";
static NSString *MUTE_SOUNDS_KEY = @"muteSounds";

@synthesize delegate;
@synthesize muteSoundsOption;
@synthesize deviceOrientationOption;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    [[ApplifierImpact sharedInstance] startWithGameId:[info objectForKey:@"gameId"]];
    [[ApplifierImpact sharedInstance] setDelegate:self];
    
    // Default options
    self.muteSoundsOption = @false;
    self.deviceOrientationOption = @false;
    
    // Parse the options, if we have any
    NSEnumerator *keySet = [info keyEnumerator];
    for(NSObject *key in keySet) {
        if([key isKindOfClass:[NSString class]]) {
            if([MUTE_SOUNDS_KEY isEqualToString:(NSString*)key]) {
                if([@"true" isEqualToString:(NSString *)[info objectForKey:MUTE_SOUNDS_KEY]]) {
                    self.muteSoundsOption = @true;
                }
            }
            if([DEVICE_ORIENTATION_KEY isEqualToString:(NSString*)key]) {
                if([@"true" isEqualToString:(NSString *)[info objectForKey:DEVICE_ORIENTATION_KEY]]) {
                    self.deviceOrientationOption = @true;
                }                
            }
            
        }
    }
    
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    if([[ApplifierImpact sharedInstance] canShowCampaigns]) {
        [[ApplifierImpact sharedInstance] setViewController:rootViewController showImmediatelyInNewController:NO];
        [[ApplifierImpact sharedInstance] showImpact:
         @{kApplifierImpactOptionNoOfferscreenKey:@true,
             kApplifierImpactOptionMuteVideoSounds:self.muteSoundsOption,
             kApplifierImpactOptionVideoUsesDeviceOrientation:self.deviceOrientationOption}];
    }
}

- (void)applifierImpact:(ApplifierImpact *)applifierImpact completedVideoWithRewardItemKey:(NSString *)rewardItemKey {
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
