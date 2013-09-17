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

@property (nonatomic, strong) NSDictionary *options;

@end

@implementation ApplifierImpactZone

- (id)initWithData:(NSDictionary *)options {
  self = [super init];
  if(self) {
    self.options = options;
  }
  return self;
}

- (NSString *)getZoneId {
  return [self.options valueForKey:kApplifierImpactZoneIdKey];
}

@end
