//
//  ApplifierImpactViewStateNoWebViewEndScreen.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/11/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewStateNoWebViewEndScreen.h"
#import "../ApplifierImpactView/ApplifierImpactNoWebViewEndScreenViewController.h"
#import "../ApplifierImpactView/ApplifierImpactDialog.h"
#import "../ApplifierImpactView/ApplifierImpactNativeSpinner.h"


@interface ApplifierImpactViewStateNoWebViewEndScreen ()
  @property (nonatomic, strong) ApplifierImpactNoWebViewEndScreenViewController *endScreenController;
@end

@implementation ApplifierImpactViewStateNoWebViewEndScreen

- (ApplifierImpactViewStateType)getStateType {
  return kApplifierImpactViewStateTypeEndScreen;
}

- (void)enterState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  
  [super enterState:options];
  
  if (self.endScreenController == nil) {
    [self createEndScreenController];
    [self showSpinnerDialog];
  }
  
  [[ApplifierImpactMainViewController sharedInstance] presentViewController:self.endScreenController animated:NO completion:nil];
}

- (void)exitState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  
  [super exitState:options];
  [[ApplifierImpactMainViewController sharedInstance] dismissViewControllerAnimated:NO completion:nil];
}

- (void)willBeShown {
  [super willBeShown];
}

- (void)wasShown {
  [super wasShown];
}

- (void)applyOptions:(NSDictionary *)options {
  [super applyOptions:options];
  
  if ([options objectForKey:kApplifierImpactNativeEventShowSpinner] != nil) {
    //[[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowSpinner data:[options objectForKey:kApplifierImpactNativeEventShowSpinner]];
  }
  else if ([options objectForKey:kApplifierImpactNativeEventHideSpinner] != nil) {
    //[[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventHideSpinner data:[options objectForKey:kApplifierImpactNativeEventHideSpinner]];
  }
  else if ([options objectForKey:kApplifierImpactWebViewEventDataClickUrlKey] != nil) {
    [self openAppStoreWithData:options inViewController:self.endScreenController];
  }
}

#pragma mark - Private controller handling

- (void)createEndScreenController {
  AILOG_DEBUG(@"");
  self.endScreenController = [[ApplifierImpactNoWebViewEndScreenViewController alloc] initWithNibName:nil bundle:nil];
}

- (void)showSpinnerDialog {
  int dialogWidth = 230;
  int dialogHeight = 76;
  
  CGRect newRect = CGRectMake(([[ApplifierImpactMainViewController sharedInstance] view].window.bounds.size.width / 2) - (dialogWidth / 2), ([[ApplifierImpactMainViewController sharedInstance] view].window.bounds.size.height / 2) - (dialogHeight / 2), dialogWidth, dialogHeight);
  
  ApplifierImpactDialog *spinnerDialog = [[ApplifierImpactDialog alloc] initWithFrame:newRect useSpinner:false useLabel:true useButton:true];
  spinnerDialog.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
   
  [self.endScreenController.view addSubview:spinnerDialog];
}

@end
