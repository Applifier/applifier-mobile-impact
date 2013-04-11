//
//  ApplifierImpactViewState.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/4/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewState.h"

@implementation ApplifierImpactViewState


- (id)init {
  self = [super init];
  self.waitingToBeShown = false;
  return self;
}

- (void)enterState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
}

- (void)exitState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  self.waitingToBeShown = false;
}

- (void)willBeShown {
  AILOG_DEBUG(@"");
  self.waitingToBeShown = true;
}

- (void)wasShown {
  AILOG_DEBUG(@"");
  self.waitingToBeShown = false;
}

- (void)applyOptions:(NSDictionary *)options {
  AILOG_DEBUG(@"");
}

- (ApplifierImpactViewStateType)getStateType {
  return kApplifierImpactViewStateTypeInvalid;
}

@end
