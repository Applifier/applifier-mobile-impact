//
//  ApplifierImpactIncentivizedZone.h
//  ApplifierImpact
//
//  Created by Ville Orkas on 10/1/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApplifierImpactZone.h"
#import "ApplifierImpactItemManager.h"

@interface ApplifierImpactIncentivizedZone : ApplifierImpactZone

- (id)initWithData:(NSDictionary *)options;

- (ApplifierImpactItemManager *)itemManager;

@end
