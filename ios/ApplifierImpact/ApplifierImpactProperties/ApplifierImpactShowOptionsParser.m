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

@implementation ApplifierImpactShowOptionsParser

static ApplifierImpactShowOptionsParser *sharedOptionsParser = nil;

+ (ApplifierImpactShowOptionsParser *)sharedInstance {
	@synchronized(self) {
		if (sharedOptionsParser == nil) {
      sharedOptionsParser = [[ApplifierImpactShowOptionsParser alloc] init];
		}
	}
	
	return sharedOptionsParser;
}


- (void)parseOptions:(NSDictionary *)options {
  self.noOfferScreen = NO;
  self.openAnimated = YES;
  self.gamerSID = NULL;
  
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
  }
}

@end
