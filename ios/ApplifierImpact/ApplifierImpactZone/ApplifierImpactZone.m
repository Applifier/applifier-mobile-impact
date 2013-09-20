//
//  ApplifierImpactZone.m
//  ApplifierImpact
//
//  Created by Ville Orkas on 9/17/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactZone.h"
#import "ApplifierImpactConstants.h"

@interface ApplifierImpactZone ()

@property (nonatomic, strong) NSMutableDictionary *_options;

@end

@implementation ApplifierImpactZone

- (id)initWithData:(NSDictionary *)options {
  self = [super init];
  if(self) {
    self._options = [NSMutableDictionary dictionaryWithDictionary:options];
  }
  return self;
}

- (NSString *)getZoneId {
  return [self._options valueForKey:kApplifierImpactZoneIdKey];
}

- (BOOL)allowsOverride:(NSString *)option {
  id allowOverrides = [self._options objectForKey:kApplifierImpactZoneAllowOverrides];
  return [allowOverrides indexOfObject:option] != NSNotFound;
}

- (void)mergeOptions:(NSDictionary *)options {
  [options enumerateKeysAndObjectsUsingBlock:^(id optionKey, id optionValue, BOOL *stop) {
    if([self allowsOverride:optionKey]) {
      [self._options setObject:optionValue forKey:optionKey];
    }
  }];
}

@end
