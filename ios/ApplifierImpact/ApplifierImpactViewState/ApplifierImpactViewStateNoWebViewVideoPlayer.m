//
//  ApplifierImpactViewStateNoWebViewVideoPlayer.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/11/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewStateNoWebViewVideoPlayer.h"
#import "../ApplifierImpactView/ApplifierImpactDialog.h"

@interface ApplifierImpactViewStateNoWebViewVideoPlayer ()
  @property (nonatomic, strong) ApplifierImpactDialog *spinnerDialog;
@end

@implementation ApplifierImpactViewStateNoWebViewVideoPlayer

- (ApplifierImpactViewStateType)getStateType {
  return kApplifierImpactViewStateTypeVideoPlayer;
}

- (void)willBeShown {
  [super willBeShown];
  [self showSpinner];
  
  [[ApplifierImpactCampaignManager sharedInstance] setSelectedCampaign:nil];
  ApplifierImpactCampaign *campaign = [[[ApplifierImpactCampaignManager sharedInstance] getViewableCampaigns] objectAtIndex:0];
  
  if (campaign != nil) {
    [[ApplifierImpactCampaignManager sharedInstance] setSelectedCampaign:campaign];
  }
}

- (void)wasShown {
  [super wasShown];
  
  if (self.videoController.parentViewController == nil && [[ApplifierImpactMainViewController sharedInstance] presentedViewController] != self.videoController) {
    [[ApplifierImpactMainViewController sharedInstance] presentViewController:self.videoController animated:NO completion:nil];
    [self moveSpinnerToVideoController];
  }
}

- (void)enterState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  [super enterState:options];
  [self createVideoController:self];
  [self showSpinner];
  
  if (!self.waitingToBeShown) {
    [self showPlayerAndPlaySelectedVideo];
  }
}

- (void)exitState:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  [super exitState:options];
  [self hideSpinner];
}

- (void)applyOptions:(NSDictionary *)options {
  [super applyOptions:options];
}


#pragma mark - Video

- (void)videoPlayerStartedPlaying {
  AILOG_DEBUG(@"");
  
  if (self.delegate != nil) {
    [self.delegate stateNotification:kApplifierImpactStateActionVideoStartedPlaying];
  }
  
  [self hideSpinner];

  if (!self.waitingToBeShown && [[ApplifierImpactMainViewController sharedInstance] presentedViewController] != self.videoController) {
    [[ApplifierImpactMainViewController sharedInstance] presentViewController:self.videoController animated:NO completion:nil];
  }
}

- (void)videoPlayerEncounteredError {
  AILOG_DEBUG(@"");
  [self hideSpinner];
  [self dismissVideoController];
}

- (void)videoPlayerPlaybackEnded {
  if (self.delegate != nil) {
    [self.delegate stateNotification:kApplifierImpactStateActionVideoPlaybackEnded];
  }
  
  [[ApplifierImpactMainViewController sharedInstance] changeState:kApplifierImpactViewStateTypeEndScreen withOptions:nil];
}

- (void)videoPlayerReady {
	AILOG_DEBUG(@"");
  if (![self.videoController isPlaying])
    [self showPlayerAndPlaySelectedVideo];
}


- (void)showPlayerAndPlaySelectedVideo {
	AILOG_DEBUG(@"");
  
  if (![self canViewSelectedCampaign]) return;
  [self startVideoPlayback:true withDelegate:self];
}


- (void)showSpinner {
  if (self.spinnerDialog == nil) {
    int dialogWidth = 230;
    int dialogHeight = 76;
    
    CGRect newRect = CGRectMake(([[ApplifierImpactMainViewController sharedInstance] view].bounds.size.width / 2) - (dialogWidth / 2), ([[ApplifierImpactMainViewController sharedInstance] view].bounds.size.height / 2) - (dialogHeight / 2), dialogWidth, dialogHeight);
    
    self.spinnerDialog = [[ApplifierImpactDialog alloc] initWithFrame:newRect useSpinner:true useLabel:true useButton:false];
    self.spinnerDialog.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    [[[ApplifierImpactMainViewController sharedInstance] view] addSubview:self.spinnerDialog];
  }
}

- (void)hideSpinner {
  if (self.spinnerDialog != nil) {
    [self.spinnerDialog removeFromSuperview];
    self.spinnerDialog = nil;
  }
}

- (void)moveSpinnerToVideoController {
  if (self.spinnerDialog != nil) {
    [self.spinnerDialog removeFromSuperview];
    
    int spinnerWidth = self.spinnerDialog.bounds.size.width;
    int spinnerHeight = self.spinnerDialog.bounds.size.height;
    
    CGRect newRect = CGRectMake((self.videoController.view.bounds.size.width / 2) - (spinnerWidth / 2), (self.videoController.view.bounds.size.height / 2) - (spinnerHeight / 2), spinnerWidth, spinnerHeight);
    
    [self.spinnerDialog setFrame:newRect];
    [self.videoController.view addSubview:self.spinnerDialog];
  }
}

@end