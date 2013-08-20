//
// BurstlyAdBannerDelegate.h
// Burstly SDK
//
// Copyright 2013 Burstly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BurstlyAdBannerProtocol;

/**
* Set of methods to be implemented to act as ad banner delegate.
 */
@protocol BurstlyAdBannerDelegate <NSObject>

@required

/**
* Notifies delegate that banner successfully loaded ad.
*
* @param banner Ad banner calling this method.
* @param adView Ad view with loaded ad.
*/
- (void)banner: (id <BurstlyAdBannerProtocol>)banner didLoadAd: (UIView *)adView;

/**
* Notifies delegate that banner failed to load ad.
*
* @param banner Ad banner calling this method.
* @param error Error describing the problem.
*/
- (void)banner: (id <BurstlyAdBannerProtocol>)banner didFailToLoadAdWithError: (NSError *)error;

/**
* Notifies delegate that banner changed size.
*
* @param banner Ad banner calling this method.
* @param adView Ad view changed size.
* @param size New ad banner size.
*/
- (void) banner: (id <BurstlyAdBannerProtocol>)banner
didChangeAdView: (UIView *)adView
           size: (CGSize)size;

/**
* Notifies delegate that banner did hide ad.
*
* @param banner Ad banner calling this method.
* @param adView Hidden ad view.
*/
- (void)banner: (id<BurstlyAdBannerProtocol>)banner
 didHideAdView: (UIView *)adView;

/**
* Notifies delegate that banner will present full screen ad.
*
* @param banner Ad banner calling this method.
*/
- (void)bannerWillPresentFullScreen: (id <BurstlyAdBannerProtocol>)banner;

/**
* Notifies delegate that banner did dismiss fullscreen ad.
*
* @param banner Ad banner calling this method.
*/
- (void)bannerDidDismissFullScreen: (id <BurstlyAdBannerProtocol>)banner;

/**
* Notifies delegate that banner ad was clicked.
*
* @param banner Ad banner calling this method.
*/
- (void)bannerWasClicked: (id <BurstlyAdBannerProtocol>)banner;

/**
* Notifies delegate that interstitial will leave application.
*
* @param interstitial Ad interstitial calling this method.
*/
- (void)bannerWillLeaveApplication: (id <BurstlyAdBannerProtocol>)banner;

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
