//
// BurstlyAdBannerProtocol.h
// Burstly SDK
//
// Copyright 2013 Burstly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BurstlyAdBannerDelegate.h"

/**
 Set of methods to be implemented to act as ad banner.
 */
@protocol BurstlyAdBannerProtocol <NSObject>

@required

/**
* Gets or sets ad banner delegate.
 */
@property (nonatomic, assign) id<BurstlyAdBannerDelegate> delegate;

/**
* Starts ad loading on a background thread and immediately returns control.
 */
- (void)loadBannerInBackground;

/**
* Cancels ad loading.
 */
- (void)cancelBannerLoading;

@optional

/**
* Notifies banner that it was displayed.
 */
- (void)bannerWasDisplayed;

/**
* Notifies banner that it was hidden.
 */
- (void)bannerWasHidden;

@end
