//
// BurstlyAdInterstitialDelegate.h
// Burstly SDK
//
// Copyright 2013 Burstly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BurstlyAdInterstitialProtocol;

/**
 Set of methods to be implemented to act as ad interstitial delegate.
 */
@protocol BurstlyAdInterstitialDelegate <NSObject>

@required

/**
* Notifies delegate that interstitial successfully loaded ad.
*
* @param interstitial Ad interstitial calling this method.
*/
- (void)interstitialDidLoadAd: (id<BurstlyAdInterstitialProtocol>)interstitial;

/**
* Notifies delegate that interstitial failed to load ad.
*
* @param interstitial Ad interstitial calling this method.
* @param error Error describing the problem.
*/
- (void)interstitial: (id<BurstlyAdInterstitialProtocol>)interstitial didFailToLoadAdWithError: (NSError *)error;

/**
* Notifies delegate that interstitial will present full screen ad.
*
* @param interstitial Ad interstitial calling this method.
*/
- (void)interstitialWillPresentFullScreen: (id<BurstlyAdInterstitialProtocol>)interstitial;

/**
* Notifies delegate that interstitial is about to present full screen ad. Note that ad impression will be tracked here.
*
* @param interstitial Ad interstitial calling this method.
*/
- (void)interstitialDidPresentFullScreen: (id<BurstlyAdInterstitialProtocol>)interstitial;

/**
* Notifies delegate that interstitial did fail to present full screen ad.
*
* @param interstitial Ad interstitial calling this method.
* @param error Error describing the problem.
*/
- (void)interstitial: (id <BurstlyAdInterstitialProtocol>)interstitial didFailToPresentFullScreenWithError: (NSError *)error;

/**
* Notifies delegate that interstitial did dismiss fullscreen ad.
*
* @param interstitial Ad interstitial calling this method.
*/
- (void)interstitialDidDismissFullScreen: (id<BurstlyAdInterstitialProtocol>)interstitial;

/**
* Notifies delegate that interstitial ad was clicked.
*
* @param interstitial Ad interstitial calling this method.
*/
- (void)interstitialWasClicked: (id<BurstlyAdInterstitialProtocol>)interstitial;

/**
* Notifies delegate that interstitial will leave application.
*
* @param interstitial Ad interstitial calling this method.
*/
- (void)interstitialWillLeaveApplication: (id<BurstlyAdInterstitialProtocol>)interstitial;

/**
* Returns whether full screen ad should autorotate to specified user interface orientation.
*
* @param orientation User interface orientation.
* @returns YES if full screen ad should autorotate to specified user interface orientation; otherwise returns NO.
*/
- (BOOL)respondsToInterfaceOrientation: (UIInterfaceOrientation)orientation;

/**
* Returns current orientation of the application user interface.
*
* @returns Current orientation of the application user interface.
*/
- (UIInterfaceOrientation)currentInterfaceOrientation;

/**
* Returns view controller will be used to present modal user interface.
*
* @returns view controller will be used to present modal user interface.
*/
- (UIViewController *)viewControllerForModalPresentation;

/**
* Returns view will be used to present modal user interface.
*
* @returns view will be used to present modal user interface.
*/
- (UIView *)viewForModalPresentation;

@end
