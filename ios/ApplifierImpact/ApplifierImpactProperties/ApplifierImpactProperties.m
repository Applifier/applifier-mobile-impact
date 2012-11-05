//
//  ApplifierImpactProperties.m
//  ApplifierImpact
//
//  Created by bluesun on 11/2/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactProperties.h"

@implementation ApplifierImpactProperties

static ApplifierImpactProperties *sharedImpactProperties = nil;

+ (id)sharedInstance
{
	@synchronized(self)
	{
		if (sharedImpactProperties == nil)
      sharedImpactProperties = [[ApplifierImpactProperties alloc] init];
	}
	
	return sharedImpactProperties;
}

-(ApplifierImpactProperties *)init {
  if (self = [super init]) {
    [self setCampaignDataUrl:@"https://impact.applifier.com/mobile/campaigns"];
  }
  
  return self;
}

@end
