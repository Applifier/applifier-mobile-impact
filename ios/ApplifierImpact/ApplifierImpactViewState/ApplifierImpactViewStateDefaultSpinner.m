//
//  ApplifierImpactViewStateDefaultSpinner.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/4/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewStateDefaultSpinner.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"
#import "../ApplifierImpactView/ApplifierImpactMainViewController.h"
#import "../ApplifierImpact.h"

@implementation ApplifierImpactViewStateDefaultSpinner

- (ApplifierImpactViewStateType)getStateType {
  return kApplifierImpactViewStateTypeSpinner;
}

- (void)enterState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  
  [super enterState:options];
  
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowSpinner data:options];

}

- (void)exitState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  
  [super exitState:options];
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventHideSpinner data:options];
}

- (void)willBeShown {
  [super willBeShown];
}

- (void)wasShown {
  [super wasShown];
}

@end
