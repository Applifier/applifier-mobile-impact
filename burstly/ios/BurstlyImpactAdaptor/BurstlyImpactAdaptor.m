//  BurstlyImpactAdaptor.m
//  BurstlySampleCL
//
//  Created by Tuomas Rinta on 6/28/13.
//
//

#import "BurstlyImpactAdaptor.h"

@implementation BurstlyImpactAdaptor

/**
 * Initializes ad network adaptor
 *
 * @param params Ad network adaptor parameters.
 *
 * @returns Initialized ad network adaptor.
 */
- (id)initAdNetworkWithParams: (NSDictionary *)params {
    NSString* gameId = [params objectForKey:@"gameId"];
    if(gameId != nil) {
        NSString *testModeValue = [params objectForKey:@"testMode"];
        BOOL testMode = testModeValue != nil && [testModeValue isEqual: @true] ? YES : NO;
        [[ApplifierImpact sharedInstance] setTestMode:testMode];
        [[ApplifierImpact sharedInstance] setDebugMode:testMode];
        [[ApplifierImpact sharedInstance] startWithGameId:gameId];
        return self;
    }
    return nil;
}

/**
 * Returns adaptor version.
 *
 * @returns Adaptor version. It can be used to target parameters in case of incompatibility between different versions of the same adaptor.
 */
- (NSString *)version {
    return [ApplifierImpact getSDKVersion];
}

/**
 * Returns whether user interface idiom is supported by ad network.
 *
 * @param idiom User interface idiom.
 *
 * @returns YES if user interface idiom is supported, otherwise returns NO.
 */
- (BOOL)isIdiomSupported: (UIUserInterfaceIdiom)idiom {
    return (idiom == UIUserInterfaceIdiomPad || idiom == UIUserInterfaceIdiomPhone);
}

/**
 * Returns ad placement type of the parameters provided.
 *
 * @param params Ad parameters used to determine ad placement type.
 * @returns Ad placement type. @see BurstlyAdPlacementType
 */
- (BurstlyAdPlacementType)adPlacementTypeFor: (NSDictionary *)params {
    // We don't do anything except interstitials
    return BurstlyAdPlacementTypeInterstitial;
}

/**
 * Creates and initializes ad banner.
 *
 * @param params Ad banner parameters.
 * @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 *
 * @returns Initialized instance of ad banner. Returned instance is NOT autoreleased.
 */
- (id<BurstlyAdBannerProtocol>)newBannerAdWithParams: (NSDictionary *)params andError: (NSError **)error {
    error = nil;
    return nil;
}

/**
 * Creates and initializes ad interstitial.
 *
 * @param params Ad interstitial parameters.
 * @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 *
 * @returns Initialized instance of ad interstitial. Returned instance is NOT autoreleased.
 */
- (id<BurstlyAdInterstitialProtocol>)newInterstitialAdWithParams: (NSDictionary *)params andError: (NSError **)error {
    error = nil;
    ImpactInterstitial *interstitial = [[ImpactInterstitial alloc] initWithParams:params];
    [[ApplifierImpact sharedInstance] setDelegate:interstitial];
    return interstitial;
}

@end
