//
//  ApplifierImpactItem.m
//  ApplifierImpact
//
//  Created by Ville Orkas on 10/1/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactItem.h"

#import "ApplifierImpact.h"
#import "ApplifierImpactConstants.h"

@implementation ApplifierImpactItem

- (id)initWithData:(NSDictionary *)data {
  self = [super init];
  if (self) {
    @try {
      [self setupFromData:data];
    } @catch (NSException *exception) {
      return nil;
    }
  }
  return self;
}

- (void)setupFromData:(NSDictionary *)data {
	id keyValue = [data objectForKey:kApplifierImpactRewardItemKeyKey];
	NSString *key = [keyValue isKindOfClass:[NSNumber class]] ? [keyValue stringValue] : keyValue;
  if (key == nil || [key length] == 0) {
    [NSException raise:@"itemKeyException" format:@"Item key is invalid"];
  }
	self.key = key;
	
	id nameValue = [data objectForKey:kApplifierImpactRewardNameKey];
	NSString *name = [nameValue isKindOfClass:[NSNumber class]] ? [nameValue stringValue] : nameValue;
  if (name == nil || [name length] == 0) {
    [NSException raise:@"itemNameException" format:@"Item name is invalid"];
  }
	self.name = name;
	
	NSString *pictureURLString = [data objectForKey:kApplifierImpactRewardPictureKey];
	NSURL *pictureURL = [NSURL URLWithString:pictureURLString];
  if (pictureURL == nil) {
    [NSException raise:@"itemPictureException" format:@"Item picture is invalid"];
  }
	self.pictureURL = pictureURL;
}

@end
