//
//  ApplifierImpactItemManager.m
//  ApplifierImpact
//
//  Created by Ville Orkas on 10/1/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactItemManager.h"

@interface ApplifierImpactItemManager ()

@property (nonatomic, strong) NSDictionary * _items;
@property (nonatomic, strong) ApplifierImpactItem * _defaultItem;

@end

@implementation ApplifierImpactItemManager

- (id)initWithItems:(NSDictionary *)items defaultItem:(ApplifierImpactItem *)defaultItem {
  self = [super init];
  if(self) {
    self._items = [NSDictionary dictionaryWithDictionary:items];
    self._defaultItem = defaultItem;
  }
  return self;
}

- (ApplifierImpactItem *)getItem:(NSString *)key {
  return [self._items objectForKey:key];
}

- (ApplifierImpactItem *)getDefaultItem {
  return self._defaultItem;
}

@end
