//
//  ApplifierImpactIncentivizedZone.m
//  ApplifierImpact
//
//  Created by Ville Orkas on 10/1/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactIncentivizedZone.h"
#import "ApplifierImpactConstants.h"
#import "ApplifierImpactRewardItem.h"

@interface ApplifierImpactIncentivizedZone ()

@property (nonatomic, strong) ApplifierImpactRewardItemManager *_itemManager;

@end

@implementation ApplifierImpactIncentivizedZone

- (id)initWithData:(NSDictionary *)options {
  self = [super initWithData:options];
  if(self) {
    id items = [options objectForKey:kApplifierImpactZoneRewardItemsKey];
    NSMutableDictionary * itemsDictionary = [[NSMutableDictionary alloc] init];
    [items enumerateObjectsUsingBlock:^(id rawItem, NSUInteger idx, BOOL *stop) {
      id item = [[ApplifierImpactRewardItem alloc] initWithData:rawItem];
      [itemsDictionary setObject:item forKey:[item key]];
    }];
    id defaultItem = [[ApplifierImpactRewardItem alloc] initWithData:[options objectForKey:kApplifierImpactZoneDefaultRewardItemKey]];
    self._itemManager = [[ApplifierImpactRewardItemManager alloc] initWithItems:itemsDictionary defaultItem:defaultItem];
  }
  return self;
}

- (BOOL)isIncentivized {
  return TRUE;
}

- (ApplifierImpactRewardItemManager *)itemManager {
  return self._itemManager;
}

@end
