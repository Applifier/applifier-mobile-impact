//
//  ApplifierImpactItemManager.h
//  ApplifierImpact
//
//  Created by Ville Orkas on 10/1/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApplifierImpactItem.h"

@interface ApplifierImpactItemManager : NSObject

- (id)initWithItems:(NSDictionary *)items defaultItem:(ApplifierImpactItem *)defaultItem;

- (ApplifierImpactItem *)getItem:(NSString *)key;
- (ApplifierImpactItem *)getDefaultItem;

@end
