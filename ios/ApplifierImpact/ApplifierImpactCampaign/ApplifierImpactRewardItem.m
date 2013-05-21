//
//  ApplifierImpactRewardItem.m
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactRewardItem.h"

#import "../ApplifierImpact.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"

@implementation ApplifierImpactRewardItem

- (id)initWithData:(NSDictionary *)data {
  self = [super init];
  if (self) {
    self.isValidRewardItem = false;
    [self setupFromData:data];
  }
  return self;
}

- (void)setupFromData:(NSDictionary *)data {
  BOOL failedData = false;
  
  AIAssertV([data isKindOfClass:[NSDictionary class]], nil);
	  
	id keyValue = [data objectForKey:kApplifierImpactRewardItemKeyKey];
  if (keyValue == nil) failedData = true;
	AIAssertV(keyValue != nil && ([keyValue isKindOfClass:[NSString class]] || [keyValue isKindOfClass:[NSNumber class]]), nil);
	NSString *key = [keyValue isKindOfClass:[NSNumber class]] ? [keyValue stringValue] : keyValue;
	AIAssertV(key != nil && [key length] > 0, nil);
  if (key == nil || [key length] == 0) failedData = true;
	self.key = key;
	
	id nameValue = [data objectForKey:kApplifierImpactRewardNameKey];
  if (nameValue == nil) failedData = true;
	AIAssertV(nameValue != nil && ([nameValue isKindOfClass:[NSString class]] || [nameValue isKindOfClass:[NSNumber class]]), nil);
	NSString *name = [nameValue isKindOfClass:[NSNumber class]] ? [nameValue stringValue] : nameValue;
	AIAssertV(name != nil && [name length] > 0, nil);
  if (name == nil || [name length] == 0) failedData = true;
	self.name = name;
	
	NSString *pictureURLString = [data objectForKey:kApplifierImpactRewardPictureKey];
  if (pictureURLString == nil) failedData = true;
	AIAssertV([pictureURLString isKindOfClass:[NSString class]], nil);
	NSURL *pictureURL = [NSURL URLWithString:pictureURLString];
	AIAssertV(pictureURL != nil, nil);
  if (pictureURL == nil) failedData = true;
	self.pictureURL = pictureURL;
  
  if (!failedData) {
    self.isValidRewardItem = true;
  }
}

@end
