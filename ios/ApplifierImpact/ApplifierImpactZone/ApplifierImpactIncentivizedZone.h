//
//  ApplifierImpactIncentivizedZone.h
//  ApplifierImpact
//
//  Created by Ville Orkas on 10/1/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApplifierImpactZone.h"
#import "ApplifierImpactRewardItemManager.h"

@interface ApplifierImpactIncentivizedZone : ApplifierImpactZone

- (id)initWithData:(NSDictionary *)options;

- (BOOL)isIncentivized;

- (ApplifierImpactRewardItemManager *)itemManager;

@end
