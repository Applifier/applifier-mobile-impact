//
//  ApplifierImpactIncentivizedZone.m
//  ApplifierImpact
//
//  Created by Ville Orkas on 10/1/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactIncentivizedZone.h"
#import "ApplifierImpactConstants.h"

@interface ApplifierImpactIncentivizedZone ()

@property (nonatomic, strong) ApplifierImpactItemManager *_itemManager;

@end

@implementation ApplifierImpactIncentivizedZone

- (id)initWithData:(NSDictionary *)options {
  self = [super init];
  if(self) {
    id items = [options objectForKey:kApplifierImpactRewardItemsKey];
    id defaultItem = [options objectForKey:kApplifierImpactRewardItemKey];
    self._itemManager = [[ApplifierImpactItemManager alloc] initWithItems:items defaultItem:defaultItem];
  }
  return self;
}

- (ApplifierImpactItemManager *)itemManager {
  return self._itemManager;
}

@end
