//
// BurstlyAdInterstitialProtocol.h
// Burstly SDK
//
// Copyright 2013 Burstly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BurstlyAdInterstitialDelegate.h"

/**
 Set of methods to be implemented to act as ad interstitial.
 */
@protocol BurstlyAdInterstitialProtocol <NSObject>

@required

/**
* Gets or sets ad interstitial delegate.
*/
@property (nonatomic, assign) id <BurstlyAdInterstitialDelegate> delegate;

/**
* Starts ad loading on a background thread and immediately returns control.
*/
- (void)loadInterstitialInBackground;

/**
* Cancels ad loading.
*/
- (void)cancelInterstitialLoading;

/**
* Tries to presents loaded ad interstitial to user.
*
*/
- (void)presentInterstitial;

@end
