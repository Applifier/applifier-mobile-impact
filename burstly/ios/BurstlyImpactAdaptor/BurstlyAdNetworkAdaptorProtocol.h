//
// BurstlyAdNetworkAdaptorProtocol.h
// Burstly SDK
//
// Copyright 2013 Burstly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BurstlyAdBannerProtocol.h"
#import "BurstlyAdInterstitialProtocol.h"

typedef enum {
    BurstlyAdPlacementTypeBanner,
    BurstlyAdPlacementTypeInterstitial
} BurstlyAdPlacementType;

/**
* Set of methods to be implemented to act as ad network adaptor.
*/
@protocol BurstlyAdNetworkAdaptorProtocol <NSObject>

@required

/**
* Initializes ad network adaptor
*
* @param params Ad network adaptor parameters.
*
* @returns Initialized ad network adaptor.
*/
- (id)initAdNetworkWithParams: (NSDictionary *)params;

/**
* Returns adaptor version.
*
* @returns Adaptor version. It can be used to target parameters in case of incompatibility between different versions of the same adaptor.
*/
- (NSString *)adaptorVersion;

/**
* Returns SDK version used by adaptor.
*
* @returns Version of the SDK used by adaptor.
*/
- (NSString *)sdkVersion;

/**
* Returns whether user interface idiom is supported by ad network.
*
* @param idiom User interface idiom.
*
* @returns YES if user interface idiom is supported, otherwise returns NO.
*/
- (BOOL)isIdiomSupported: (UIUserInterfaceIdiom)idiom;

/**
* Returns ad placement type of the parameters provided.
*
* @param params Ad parameters used to determine ad placement type.
* @returns Ad placement type. @see BurstlyAdPlacementType
*/
- (BurstlyAdPlacementType)adPlacementTypeFor: (NSDictionary *)params;

/**
* Creates and initializes ad banner.
*
* @param params Ad banner parameters.
* @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
*
* @returns Initialized instance of ad banner. Returned instance is NOT autoreleased.
*/
- (id<BurstlyAdBannerProtocol>)newBannerAdWithParams: (NSDictionary *)params
											andError: (NSError **)error;

/**
* Creates and initializes ad interstitial.
*
* @param params Ad interstitial parameters.
* @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
*
* @returns Initialized instance of ad interstitial. Returned instance is NOT autoreleased.
*/
- (id<BurstlyAdInterstitialProtocol>)newInterstitialAdWithParams: (NSDictionary *)params
														andError: (NSError **)error;

@end
