//
//  BurstlyImpactAdaptor.h
//  BurstlySampleCL
//
//  Created by Tuomas Rinta on 6/28/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BurstlyAdNetworkAdaptorProtocol.h"
#import "BurstlyAdBannerProtocol.h"
#import "BurstlyAdInterstitialProtocol.h"

#import "ImpactInterstitial.h"

#import <ApplifierImpact/ApplifierImpact.h>

@interface BurstlyImpactAdaptor : NSObject <BurstlyAdNetworkAdaptorProtocol>
@end
