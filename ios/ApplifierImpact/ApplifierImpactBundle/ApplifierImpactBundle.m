//
//  ApplifierImpactBundle.m
//  ApplifierImpact
//
//  Created by Matti Savolainen on 5/3/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactBundle.h"

@implementation ApplifierImpactBundle

+ (NSBundle *)bundle {
  static NSBundle *resourceBundle;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    resourceBundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"ApplifierImpact" ofType:@"bundle"]];
    NSAssert(resourceBundle, @"Please move the ApplifierImpact.bundle into the Resource Directory of your Application!");
  });
  return resourceBundle;
}

+ (UIImage *)imageWithName:(NSString *)aName {
  NSBundle *bundle = [self bundle];
  NSString *path = [bundle pathForResource:aName ofType:@"png"];
  return [UIImage imageWithContentsOfFile:path];
}

+ (UIImage *)imageWithName:(NSString *)aName ofType:(NSString *)aType {
  NSBundle *bundle = [self bundle];
  NSString *path = [bundle pathForResource:aName ofType:aType];
  return [UIImage imageWithContentsOfFile:path];
}

@end
