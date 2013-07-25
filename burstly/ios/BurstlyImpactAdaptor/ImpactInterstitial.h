//
//  ImpactInterstitial.h
//  BurstlySampleCL
//
//  Created by Ville Orkas on 7/22/13.
//
//

#import <Foundation/Foundation.h>

#import "BurstlyImpactAdaptor.h"
#import <ApplifierImpact/ApplifierImpact.h>

@interface ImpactInterstitial : NSObject <BurstlyAdInterstitialProtocol, ApplifierImpactDelegate> {
    id<BurstlyAdInterstitialDelegate> _delegate;
    NSMutableDictionary *_params;
}

- (id)initWithParams:(NSDictionary *)params;

@end
