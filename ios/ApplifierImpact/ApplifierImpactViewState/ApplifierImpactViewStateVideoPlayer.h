//
//  ApplifierImpactViewStateVideoPlayer.h
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/11/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewState.h"
#import "../ApplifierImpactVideo/ApplifierImpactVideoViewController.h"
#import "../ApplifierImpactView/ApplifierImpactMainViewController.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "../ApplifierImpact.h"

@interface ApplifierImpactViewStateVideoPlayer : ApplifierImpactViewState
  @property (nonatomic, strong) ApplifierImpactVideoViewController *videoController;
  @property (nonatomic, assign) BOOL checkIfWatched;

- (void)destroyVideoController;
- (void)createVideoController:(id)targetDelegate;
- (void)dismissVideoController;
- (BOOL)canViewSelectedCampaign;
- (void)startVideoPlayback:(BOOL)createVideoController withDelegate:(id)videoControllerDelegate;
@end
