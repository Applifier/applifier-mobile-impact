//
//  ImpactInterstitial.m
//  BurstlySampleCL
//
//  Created by Ville Orkas on 7/22/13.
//
//

#import "ImpactInterstitial.h"

@implementation ImpactInterstitial

@synthesize delegate = _delegate;

- (id)initWithParams:(NSDictionary *)params {
    self = [super init];
    if(self != nil) {
        _params = [[NSMutableDictionary alloc] init];
                
        NSString *noOfferScreenValue = [params objectForKey:kApplifierImpactOptionNoOfferscreenKey];
        NSString *openAnimatedValue = [params objectForKey:kApplifierImpactOptionOpenAnimatedKey];
        NSString *gamerSidValue = [params objectForKey:kApplifierImpactOptionGamerSIDKey];
        NSString *muteVideoSoundsValue = [params objectForKey:kApplifierImpactOptionMuteVideoSounds];
        NSString *videoUsesDeviceOrientationValue = [params objectForKey:kApplifierImpactOptionVideoUsesDeviceOrientation];
        
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
    }
    return self;
}

- (void)dealloc {
    [_params dealloc];
    [super dealloc];
}

/**
 * Starts ad loading on a background thread and immediately returns control.
 * As long as Impact has campaigns available, call the ad loaded delegate. 
 */
- (void)loadInterstitialInBackground {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([[ApplifierImpact sharedInstance] canShowCampaigns]) {
            [[self delegate] interstitialDidLoadAd:self];
        } else {
            [[self delegate] interstitial:self didFailToLoadAdWithError:[NSError errorWithDomain:@"ApplifierImpact" code:0 userInfo:nil]];
        }
    });
}

/**
 * Cancels ad loading. Not supported by Impact.
 */
- (void)cancelInterstitialLoading {
}

/**
 * Tries to presents loaded ad interstitial to user.
 *
 */
- (void)presentInterstitial {
    AILOG_DEBUG(@"");
    [[ApplifierImpact sharedInstance] setViewController:[[self delegate] viewControllerForModalPresentation] showImmediatelyInNewController:NO];
    [[ApplifierImpact sharedInstance] showImpact:_params];
}

/*=
 * ApplifierImpact method
 *=*/

-(void)applifierImpact:(ApplifierImpact *)applifierImpact completedVideoWithRewardItemKey:(NSString *)rewardItemKey videoWasSkipped:(BOOL)skipped {
}

-(void)applifierImpactCampaignsAreAvailable:(ApplifierImpact *)applifierImpact {
    [[self delegate] interstitialDidLoadAd:self];
}

-(void)applifierImpactDidOpen:(ApplifierImpact *)applifierImpact {
    [[self delegate] interstitialWillPresentFullScreen:self];
    [[self delegate] interstitialDidPresentFullScreen:self];
}

-(void)applifierImpactDidClose:(ApplifierImpact *)applifierImpact {
    [[self delegate] interstitialDidDismissFullScreen:self];
}

-(void)applifierImpactWillLeaveApplication:(ApplifierImpact *)applifierImpact {
    [[self delegate] interstitialWillLeaveApplication:self];
}

@end
