//
//  ApplifierImpactVideoViewController.h
//  ApplifierImpact
//
//  Created by bluesun on 11/26/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ApplifierImpactVideoPlayer.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaign.h"

@protocol ApplifierImpactVideoControllerDelegate <NSObject>

@required
- (void)videoPlayerStartedPlaying;
- (void)videoPlayerPlaybackEnded;
- (void)videoPlayerEncounteredError;
- (void)videoPlayerReady;
@end

@interface ApplifierImpactVideoViewController : UIViewController <ApplifierImpactVideoPlayerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, assign) id<ApplifierImpactVideoControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isMuted;
- (void)playCampaign:(ApplifierImpactCampaign *)campaignToPlay;
- (void)forceStopVideoPlayer;
@end
