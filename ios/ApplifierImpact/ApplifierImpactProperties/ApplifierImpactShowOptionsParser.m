//
//  ApplifierImpactShowOptionsParser.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/4/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactShowOptionsParser.h"
#import "../ApplifierImpact.h"
#import "../ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "../ApplifierImpactSBJSON/ApplifierImpactSBJsonWriter.h"
#import "../ApplifierImpactSBJSON/NSObject+ApplifierImpactSBJson.h"

@implementation ApplifierImpactShowOptionsParser

static ApplifierImpactShowOptionsParser *sharedOptionsParser = nil;

+ (ApplifierImpactShowOptionsParser *)sharedInstance {
	@synchronized(self) {
		if (sharedOptionsParser == nil) {
      sharedOptionsParser = [[ApplifierImpactShowOptionsParser alloc] init];
      [sharedOptionsParser resetToDefaults];
		}
	}
	
	return sharedOptionsParser;
}


- (void)parseOptions:(NSDictionary *)options {
  [self resetToDefaults];
  
  if (options != NULL) {
    if ([options objectForKey:kApplifierImpactOptionNoOfferscreenKey] != nil && [[options objectForKey:kApplifierImpactOptionNoOfferscreenKey] boolValue] == YES) {
      self.noOfferScreen = YES;
    }
    
    if ([options objectForKey:kApplifierImpactOptionOpenAnimatedKey] != nil && [[options objectForKey:kApplifierImpactOptionOpenAnimatedKey] boolValue] == NO) {
      self.openAnimated = NO;
    }
    
    if ([options objectForKey:kApplifierImpactOptionGamerSIDKey] != nil) {
      self.gamerSID = [options objectForKey:kApplifierImpactOptionGamerSIDKey];
    }
    
    if ([options objectForKey:kApplifierImpactOptionMuteVideoSounds] != nil && [[options objectForKey:kApplifierImpactOptionMuteVideoSounds] boolValue] == YES) {
      self.muteVideoSounds = YES;
    }

  }
}

- (NSString *)getOptionsAsJson {
  NSDictionary *options = @{kApplifierImpactOptionNoOfferscreenKey:[NSNumber numberWithBool:self.noOfferScreen], kApplifierImpactOptionOpenAnimatedKey:[NSNumber numberWithBool:self.openAnimated], kApplifierImpactOptionGamerSIDKey:self.gamerSID};
  
  return [options JSONRepresentation];
}

- (void)resetToDefaults {
  self.noOfferScreen = NO;
  self.openAnimated = YES;
  self.gamerSID = NULL;
  self.muteVideoSounds = NO;
}

@end
