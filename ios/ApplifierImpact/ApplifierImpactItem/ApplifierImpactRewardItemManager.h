//
//  ApplifierImpactItemManager.h
//  ApplifierImpact
//
//  Created by Ville Orkas on 10/1/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApplifierImpactRewardItem.h"

@interface ApplifierImpactRewardItemManager : NSObject

- (id)initWithItems:(NSDictionary *)items defaultItem:(ApplifierImpactRewardItem *)defaultItem;

- (ApplifierImpactRewardItem *)getItem:(NSString *)key;
- (ApplifierImpactRewardItem *)getDefaultItem;
- (ApplifierImpactRewardItem *)getCurrentItem;
- (BOOL)setCurrentItem:(NSString *)rewardItemKey;

- (NSArray *)allItems;
- (int)itemCount;

@end
