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
  @property (nonatomic, strong) ApplifierImpactDialog *dialog;
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
  }
  else {
    [self.endScreenController updateViewData];
  }
  
  [[ApplifierImpactMainViewController sharedInstance] presentViewController:self.endScreenController animated:NO completion:nil];
}

- (void)exitState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  
  [super exitState:options];
  self.endScreenController = nil;
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
    [self showDialog];
  }
  else if ([options objectForKey:kApplifierImpactNativeEventHideSpinner] != nil) {
    [self hideDialog];
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

- (void)showDialog {
  if (self.dialog == nil) {
    int dialogWidth = 230;
    int dialogHeight = 76;
    
    CGRect newRect = CGRectMake((self.endScreenController.view.bounds.size.width / 2) - (dialogWidth / 2), (self.endScreenController.view.bounds.size.height / 2) - (dialogHeight / 2), dialogWidth, dialogHeight);
    
    self.dialog = [[ApplifierImpactDialog alloc] initWithFrame:newRect useSpinner:true useLabel:true useButton:false];
    self.dialog.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.dialog.label setText:@"Loading..."];
  }
  
  if (self.dialog.superview == nil) {
    [self.endScreenController.view addSubview:self.dialog];
  }
}

- (void)hideDialog {
  if (self.dialog != nil) {
    if (self.dialog.superview != nil) {
      [self.dialog removeFromSuperview];
    }
    
    self.dialog = nil;
  }
}

@end
