//
//  Copyright 2013 Burstly LLC.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

//
//  BurstlyAdInterstitial.h
//  Burstly
//

/**
 Getting Started:
 
 There are 5 major classes that you need to get familiar with prior to writing adapters in order to plug in to Burstly Mediation Platform.
 
 BurstlyAdNetworkAdapterProtocol: Begin by conforming to and implementing this protocol that includes factory methods invoked when a publisher initializes the Burstly SDK and requests ads. You would return a reference to your adapter object. The adapter object should serve as a liason by implementing the BurstlyAdBannerProtocol and/or the BurstlyAdInterstitialProtocol depending on the ad type(s) your SDK supports.
 
 BurstlyAdBannerProtocol: Your adapter must implement this protocol if your SDK supports banner ads. You would need these callbacks fired by the Burstly SDK in order to cache, load and display ads via your adapter.
 
 BurstlyAdInterstitialProtocol: Your adapter must implement this protocol if your SDK supports full screen ads. You would need these callbacks fired by the Burstly SDK in order to cache, load and display ads via your adapter. Ensure that you've identified your placement type based on the parameters passed via the adPlacementTypeFor: method.
 
 BurstlyAdBannerDelegate/BurstlyAdInterstitialDelegate: These protocols enable your adapter to communicate ad events back to the publisher via the Burstly SDK. Use these callbacks to notify the SDK that an ad did/failed to load or that an ad is about to take over the publisher's screen.
 */

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
